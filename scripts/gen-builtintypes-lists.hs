{-# LANGUAGE RecordWildCards #-}
-- | Script that generates 'Internal.Gen.ListElem', which is mostly a
-- bunch of tedious 'ListElem'/'MutListElem' instances.
module Main where

header = unlines
    [ "{-# LANGUAGE TypeFamilies #-}"
    , "{-# LANGUAGE FlexibleInstances #-}"
    , "{-# LANGUAGE MultiParamTypeClasses #-}"
    , "module Internal.Gen.ListElem where"
    , "-- This module is auto-generated by gen-builtintypes-lists.hs; DO NOT EDIT."
    , ""
    , "import Data.Int"
    , "import Data.ReinterpretCast"
    , "import Data.Word"
    , ""
    , "import Codec.Capnp (ListElem(..), MutListElem(..))"
    , ""
    , "import qualified Data.Capnp.Untyped.Generic as GU"
    , ""
    ]

data InstanceParams = P
    { to      :: String
    , from    :: String
    , typed   :: String
    , untyped :: String
    }


genInstance P{..} = concat
    [ "instance ListElem msg ", typed, " where\n"
    , "    newtype List msg ", typed, " = List", typed, " (GU.ListOf msg ", untyped, ")\n"
    , "    length (List", typed, " l) = GU.length l\n"
    , "    index i (List", typed, " l) = ", from, " <$> GU.index i l\n"
    , "instance MutListElem s ", typed, " where\n"
    , "    setIndex elt i (", dataCon, " l) = GU.setIndex (", to, " elt) i l\n"
    ]
  where
    dataCon = "List" ++ typed

sizes = [8, 16, 32, 64]

intInstance size = P
    { to = "fromIntegral"
    , from = "fromIntegral"
    , typed = "Int" ++ show size
    , untyped = "Word" ++ show size
    }

wordInstance size = P
    { to = "id"
    , from = "id"
    , typed = "Word" ++ show size
    , untyped = "Word" ++ show size
    }

instances =
    (map intInstance sizes) ++
    (map wordInstance sizes) ++
    [ P { to = "floatToWord"
        , from = "wordToFloat"
        , typed = "Float"
        , untyped = "Word32"
        }
    , P { to = "doubleToWord"
        , from = "wordToDouble"
        , typed = "Double"
        , untyped = "Word64"
        }
    , P { to = "id"
        , from = "id"
        , typed = "Bool"
        , untyped = "Bool"
        }
    ]

main = writeFile "lib/Internal/Gen/ListElem.hs" $
    header ++ concatMap genInstance instances