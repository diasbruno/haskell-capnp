{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE RecordWildCards #-}
module Module.Capnp.Gen.Capnp.Schema (schemaTests) where

import Test.Hspec

import Control.Monad.Primitive (RealWorld)
import Data.Foldable           (traverse_)

import Capnp.Gen.Capnp.Schema

import Capnp                (newRoot)
import Capnp.TraversalLimit (LimitT, evalLimitT)
import Data.Mutable         (Thaw (..))
import Util                 (decodeValue, schemaSchemaSrc)

import qualified Capnp.Message as M

data BuildTest = BuildTest
    { typeName :: String
    , expected :: String
    , builder  :: M.Message ('M.Mut RealWorld) -> LimitT IO ()
    }

schemaTests :: Spec
schemaTests = describe "tests for typed setters" $ traverse_ testCase
    [ BuildTest
        { typeName = "Field"
        , expected = concat
            [ "( codeOrder = 4,\n"
            , "  discriminantValue = 6,\n"
            , "  group = (typeId = 322),\n"
            , "  ordinal = (explicit = 22) )\n"
            ]
        , builder = \msg -> do
            field <- newRoot msg
            set_Field'codeOrder field 4
            set_Field'discriminantValue field 6
            group <- set_Field'group field
            set_Field'group'typeId group 322
            ordinal <- get_Field'ordinal field
            set_Field'ordinal'explicit ordinal 22
        }
    ]
  where
    testCase BuildTest{..} = it ("Should build " ++ expected) $ do
        msg <- M.newMessage Nothing
        evalLimitT maxBound $ builder msg
        constMsg <- freeze msg
        actual <- decodeValue schemaSchemaSrc typeName constMsg
        actual `shouldBe` expected
