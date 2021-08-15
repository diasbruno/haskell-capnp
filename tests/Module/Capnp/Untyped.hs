{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE OverloadedLabels      #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE RecordWildCards       #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TypeApplications      #-}
{-# LANGUAGE TypeFamilies          #-}
-- The tests have a number of cases where we do stuff like:
--
-- let 4 = ...
--
-- Letting pattern-match failure fail the test. GHC warns about this,
-- let's shut off that warning:
{-# OPTIONS_GHC -Wno-unused-pattern-binds #-}
module Module.Capnp.Untyped (untypedTests) where

import Prelude hiding (length)

import Test.Hspec

import Data.Word

import Control.Monad           (forM_, when)
import Control.Monad.Primitive (RealWorld)
import Data.Foldable           (traverse_)
import Data.Function           ((&))
import Data.Text               (Text)
import GHC.Float               (castDoubleToWord64, castWord64ToDouble)
import Test.QuickCheck         (property)
import Test.QuickCheck.IO      (propertyIO)
import Text.Heredoc            (here)

import qualified Data.ByteString as BS
import qualified Data.Vector     as V

import Capnp.Untyped
import Util

import Capnp.Mutability     (freeze, thaw)
import Capnp.New
    (createPure, def, encode, msgToParsed, newRoot, setField)
import Capnp.TraversalLimit (LimitT, evalLimitT, execLimitT)

import Instances ()

import Capnp.Gen.Capnp.Schema.New

import qualified Capnp.Message as M
import qualified Capnp.Repr    as R

untypedTests :: Spec
untypedTests = describe "low-level untyped API tests" $ do
    readTests
    modifyTests
    farPtrTest
    otherMessageTest

readTests :: Spec
readTests = describe "read tests" $
    it "Should agree with `capnp decode`" $ do
        msg <- encodeValue
                    aircraftSchemaSrc
                    "Aircraft"
                    [here|(f16 = (base = (
                       name = "bob",
                       homes = [],
                       rating = 7,
                       canFly = true,
                       capacity = 5173,
                       maxSpeed = 12.0
                    )))|]
        endQuota <- execLimitT 128 $ do
            root <- rootPtr msg
            -- Aircraft just has the union tag, nothing else in it's data
            -- section.
            let 1 = structWordCount root
            3 <- getData 0 root -- tag for F16
            let 1 = structPtrCount root
            Just (PtrStruct f16) <- getPtr 0 root
            let 0 = structWordCount f16
            let 0 = structByteCount f16
            let 1 = structPtrCount f16
            Just (PtrStruct base) <- getPtr 0 f16
            let 4 = structWordCount base -- Except canFly, each field is 1 word, and
                                         -- canFly is aligned such that it ends up
                                         -- consuming a whole word.
            let 32 = structByteCount base -- 32 = 4 * 8
            let 2 = structPtrCount base -- name, homes

            -- Walk the data section:
            7 <- getData 0 base -- rating
            1 <- getData 1 base -- canFly
            5173 <- getData 2 base -- capacity
            12.0 <- castWord64ToDouble <$> getData 3 base

            -- ...and the pointer section:
            Just (PtrList (List8 name)) <- getPtr 0 base
            -- Text values have a NUL terminator, which is included in the
            -- length on the wire. The spec says that this shouldn't be
            -- included in the length reported to the caller, but that needs
            -- to be dealt with by schema-aware code, so this is the length of
            -- "bob\0"
            let 4 = length name

            forM_ (zip [0..3] (BS.unpack "bob\0")) $ \(i, c) -> do
                c' <- index i name
                when (c /= c') $
                    error ("index " ++ show i ++ ": " ++ show c ++ " /= " ++ show c')
            Just (PtrList (List16 homes)) <- getPtr 1 base
            let 0 = length homes
            return ()
        endQuota `shouldBe` 117

data ModTest = ModTest
    { testIn   :: String
    , testMod  :: Struct ('M.Mut RealWorld) -> LimitT IO ()
    , testOut  :: String
    , testType :: String
    }

modifyTests :: Spec
modifyTests = describe "modification tests" $ traverse_ testCase
    -- tests for setIndex
    [ ModTest
        { testIn = "(year = 2018, month = 6, day = 20)\n"
        , testType = "Zdate"
        , testOut = "(year = 0, month = 0, day = 0)\n"
        , testMod = setData 0 0
        }
    , ModTest
        { testIn = "(text = \"Hello, World!\")\n"
        , testType = "Z"
        , testOut = "(text = \"hEllo, world!\")\n"
        , testMod = \struct -> do
            Just (PtrList (List8 list)) <- getPtr 0 struct
            setIndex (fromIntegral (fromEnum 'h')) 0 list
            setIndex (fromIntegral (fromEnum 'E')) 1 list
            setIndex (fromIntegral (fromEnum 'w')) 7 list
        }
    , ModTest
        { testIn = "(boolvec = [true, true, false, true])\n"
        , testType = "Z"
        , testOut = "( boolvec = [false, true, true, false] )\n"
        , testMod = \struct -> do
            Just (PtrList (List1 list)) <- getPtr 0 struct
            setIndex False 0 list
            setIndex True 2 list
            setIndex False 3 list
        }
    , ModTest
        { testIn = "(f64 = 2.0)\n"
        , testType = "Z"
        , testOut = "(f64 = 7.2)\n"
        , testMod = setData (castDoubleToWord64 7.2) 1
        }
    , ModTest
        { testIn = unlines
            [ "( size = 4,"
            , "  words = \"Hello, World!\","
            , "  wordlist = [\"apples\", \"oranges\"] )"
            ]
        , testType = "Counter"
        , testOut = unlines
            [ "( size = 4,"
            , "  words = \"oranges\","
            , "  wordlist = [\"apples\", \"Hello, World!\"] )"
            ]
        , testMod = \struct -> do
            Just (PtrList (ListPtr list)) <- getPtr 1 struct
            helloWorld <- getPtr 0 struct
            oranges <- index 1 list
            setPtr oranges 0 struct
            setIndex helloWorld 1 list
        }
    , ModTest
        { testIn = unlines
            [ "( aircraftvec = ["
            , "    ( f16 = ("
            , "        base = ("
            , "          name = \"alice\","
            , "          homes = [],"
            , "          rating = 7,"
            , "          canFly = true,"
            , "          capacity = 4,"
            , "          maxSpeed = 100 ) ) ),"
            , "    ( b737 = ("
            , "        base = ("
            , "          name = \"bob\","
            , "          homes = [],"
            , "          rating = 2,"
            , "          canFly = false,"
            , "          capacity = 9,"
            , "          maxSpeed = 50 ) ) ) ] )"
            ]
        , testType = "Z"
        , testOut = unlines
            [ "( aircraftvec = ["
            , "    ( f16 = ("
            , "        base = ("
            , "          name = \"alice\","
            , "          homes = [],"
            , "          rating = 7,"
            , "          canFly = true,"
            , "          capacity = 4,"
            , "          maxSpeed = 100 ) ) ),"
            , "    ( f16 = ("
            , "        base = ("
            , "          name = \"alice\","
            , "          homes = [],"
            , "          rating = 7,"
            , "          canFly = true,"
            , "          capacity = 4,"
            , "          maxSpeed = 100 ) ) ) ] )"
            ]
        , testMod = \struct -> do
            Just (PtrList (ListStruct list)) <- getPtr 0 struct
            src <- index 0 list
            setIndex src 1 list
        }
    -- tests for allocation functions
    , ModTest
        { testIn = "()"
        , testType = "StackingRoot"
        , testOut = "( aWithDefault = (num = 6400),\n  a = (num = 65, b = (num = 90000)) )\n"

        , testMod = \struct -> do
            when (structPtrCount struct /= 2) $
                error "struct's pointer section is unexpedly small"

            let msg = message @Struct struct
            a <- allocStruct msg 1 1
            aWithDefault <- allocStruct msg 1 1
            b <- allocStruct msg 1 0
            setPtr (Just (PtrStruct b)) 0 a
            setPtr (Just (PtrStruct aWithDefault)) 0 struct
            setPtr (Just (PtrStruct a)) 1 struct
            setData 65 0 a
            setData 6400 0 aWithDefault
            setData 90000 0 b
        }
    , ModTest
        { testIn = "()"
        , testType = "HoldsVerTwoTwoList"
        , testOut = "( mylist = [(val = 0, duo = 70), (val = 0, duo = 71), (val = 0, duo = 72), (val = 0, duo = 73)] )\n"
        , testMod = \struct -> do
            mylist <- allocCompositeList (message @Struct struct) 2 2 4
            forM_ [0..3] $ \i ->
                index i mylist >>= setData (70 + fromIntegral i) 1
            setPtr (Just $ PtrList $ ListStruct mylist) 0 struct
        }
    , allocNormalListTest "u64vec" 21 allocList64 List64
    , allocNormalListTest "u32vec" 22 allocList32 List32
    , allocNormalListTest "u16vec" 23 allocList16 List16
    , allocNormalListTest "u8vec"  24 allocList8  List8
    , ModTest
        { testIn = "()"
        , testType = "Z"
        , testOut = "( boolvec = [true, false, true] )\n"
        , testMod = \struct -> do
            setData 39 0 struct -- Set the union tag.
            boolvec <- allocList1 (message @Struct struct) 3
            forM_ [0..2] $ \i ->
                setIndex (even i) i boolvec
            setPtr (Just $ PtrList $ List1 boolvec) 0 struct
        }
    ]
  where
    -- generate a ModTest for a (normal) list allocation function.
    --
    -- parameters:
    --
    -- * tagname   - the name of the union variant
    -- * tagvalue  - the numeric value of the tag for this variant
    -- * allocList - the allocation function
    -- * dataCon   - the data constructor for 'List' to use.
    --
    allocNormalListTest
        :: (ListItem ('Data sz), Num (UntypedData sz))
        => String
        -> Word64
        -> (M.Message ('M.Mut RealWorld) -> Int -> LimitT IO (ListOf ('Data sz) ('M.Mut RealWorld)))
        -> (ListOf ('Data sz) ('M.Mut RealWorld) -> List ('M.Mut RealWorld))
        -> ModTest
    allocNormalListTest tagname tagvalue allocList dataCon =
        ModTest
            { testIn = "()"
            , testType = "Z"
            , testOut = "(" ++ tagname ++ " = [0, 1, 2, 3, 4])\n"
            , testMod = \struct -> do
                setData tagvalue 0 struct
                vec <- allocList (message @Struct struct) 5
                forM_ [0..4] $ \i -> setIndex (fromIntegral i) i vec
                setPtr (Just $ PtrList $ dataCon vec) 0 struct
            }
    testCase ModTest{..} =
        it ("Should satisfy: " ++ show testIn ++ " : " ++ testType ++ " == " ++ show testOut) $ do
            msg <- thaw =<< encodeValue aircraftSchemaSrc testType testIn
            evalLimitT 128 $ rootPtr msg >>= testMod
            actualOut <- decodeValue aircraftSchemaSrc testType =<< freeze msg
            actualOut `shouldBe` testOut


farPtrTest :: Spec
farPtrTest = describe "Setting cross-segment pointers shouldn't crash" $ do
    -- I(zenhack) am disappointed in hindsight that we only check for crashes
    -- here; we should make these more thorough, actually checking validity
    -- somehow.
    it "Should work when setting the root pointer" $ do
        pure () :: IO () -- Not sure why ghc needs this hint, but it does.
        msg <- M.newMessage Nothing
        -- The allocator always allocates new objects in the last segment, so
        -- if we create a new segment, the call to allocStruct below should
        -- allocate there:
        (1, _) <- M.newSegment msg 16
        struct <- allocStruct msg 3 4
        setRoot struct :: IO ()
    it "Should work when setting a field in a struct" $ do
        pure () :: IO () -- Not sure why ghc needs this hint, but it does.
        evalLimitT maxBound $ do
            msg <- M.newMessage Nothing
            srcStruct <- allocStruct msg 4 4
            (1, _) <- M.newSegment msg 10
            dstStruct <- allocStruct msg 2 2
            let ptr = R.toPtr @('Just 'R.Struct) dstStruct
            setPtr ptr 0 srcStruct

otherMessageTest :: Spec
otherMessageTest = describe "Setting pointers in other messages" $
    it "Should copy them if needed." $
        property $ \(name :: Text) (params :: V.Vector (Parsed Node'Parameter)) (brand :: Parsed Brand) ->
            propertyIO $ do
                let expected = def
                        { name = name
                        , implicitParameters = params
                        , paramBrand = brand
                        }
                msg :: M.Message 'M.Const <- createPure maxBound $ do
                        methodMsg <- M.newMessage Nothing
                        nameMsg <- M.newMessage Nothing
                        paramsMsg <- M.newMessage Nothing
                        brandMsg <- M.newMessage Nothing

                        methodCerial <- newRoot @Method () methodMsg
                        nameCerial <- encode nameMsg name
                        brandCerial <- encode brandMsg brand
                        paramsCerial <- encode paramsMsg params

                        methodCerial & setField #name nameCerial
                        methodCerial & setField #implicitParameters paramsCerial
                        methodCerial & setField #paramBrand brandCerial

                        pure methodMsg
                actual <- evalLimitT maxBound $ msgToParsed msg
                actual `shouldBe` expected
