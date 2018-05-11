{-# LANGUAGE DuplicateRecordFields #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}
module Data.Capnp.ById.Xb8630836983feed7.Pure where

-- generated from /usr/include/capnp/persistent.capnp

import Data.Int
import Data.Word

import Data.Capnp.Untyped.Pure (Text, Data, List)

import qualified Data.Capnp.Untyped.Pure
import qualified Codec.Capnp

import qualified Data.Capnp.ById.Xbdf87d7bb8304e81.Pure

data Persistent'SaveResults
    = Persistent'SaveResults
        { sturdyRef :: Maybe (Data.Capnp.Untyped.Pure.PtrType)
        }
    deriving(Show, Read, Eq)

data Persistent'SaveParams
    = Persistent'SaveParams
        { sealFor :: Maybe (Data.Capnp.Untyped.Pure.PtrType)
        }
    deriving(Show, Read, Eq)

