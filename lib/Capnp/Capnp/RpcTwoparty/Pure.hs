{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}
module Capnp.Capnp.RpcTwoparty.Pure where

-- Code generated by capnpc-haskell. DO NOT EDIT.
-- Generated from schema file: capnp/rpc-twoparty.capnp

import Data.Int
import Data.Word

import Data.Capnp.Untyped.Pure (List)
import Data.Capnp.Basics.Pure (Data, Text)
import Control.Monad.Catch (MonadThrow)
import Data.Capnp.TraversalLimit (MonadLimit)

import qualified Data.Capnp.Message as M'
import qualified Data.Capnp.Untyped.Pure as PU'
import qualified Codec.Capnp as C'

import qualified Capnp.ById.Xa184c7885cdaf2a1
import qualified Capnp.ById.Xbdf87d7bb8304e81.Pure
import qualified Capnp.ById.Xbdf87d7bb8304e81

data JoinKeyPart
    = JoinKeyPart
        { joinId :: Word32
        , partCount :: Word16
        , partNum :: Word16
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xa184c7885cdaf2a1.JoinKeyPart M'.ConstMsg) JoinKeyPart where
    decerialize raw = JoinKeyPart
            <$> (Capnp.ById.Xa184c7885cdaf2a1.get_JoinKeyPart'joinId raw >>= C'.decerialize)
            <*> (Capnp.ById.Xa184c7885cdaf2a1.get_JoinKeyPart'partCount raw >>= C'.decerialize)
            <*> (Capnp.ById.Xa184c7885cdaf2a1.get_JoinKeyPart'partNum raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMsg JoinKeyPart where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xa184c7885cdaf2a1.JoinKeyPart M'.ConstMsg)

data JoinResult
    = JoinResult
        { joinId :: Word32
        , succeeded :: Bool
        , cap :: Maybe (PU'.PtrType)
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xa184c7885cdaf2a1.JoinResult M'.ConstMsg) JoinResult where
    decerialize raw = JoinResult
            <$> (Capnp.ById.Xa184c7885cdaf2a1.get_JoinResult'joinId raw >>= C'.decerialize)
            <*> (Capnp.ById.Xa184c7885cdaf2a1.get_JoinResult'succeeded raw >>= C'.decerialize)
            <*> (Capnp.ById.Xa184c7885cdaf2a1.get_JoinResult'cap raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMsg JoinResult where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xa184c7885cdaf2a1.JoinResult M'.ConstMsg)

data Side
    = Side'server
    | Side'client
    | Side'unknown' (Word16)
    deriving(Show, Read, Eq)

instance C'.Decerialize Capnp.ById.Xa184c7885cdaf2a1.Side Side where
    decerialize raw = case raw of

        Capnp.ById.Xa184c7885cdaf2a1.Side'server -> pure Side'server
        Capnp.ById.Xa184c7885cdaf2a1.Side'client -> pure Side'client
        Capnp.ById.Xa184c7885cdaf2a1.Side'unknown' val -> Side'unknown' <$> C'.decerialize val

data ProvisionId
    = ProvisionId
        { joinId :: Word32
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xa184c7885cdaf2a1.ProvisionId M'.ConstMsg) ProvisionId where
    decerialize raw = ProvisionId
            <$> (Capnp.ById.Xa184c7885cdaf2a1.get_ProvisionId'joinId raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMsg ProvisionId where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xa184c7885cdaf2a1.ProvisionId M'.ConstMsg)

data VatId
    = VatId
        { side :: Side
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xa184c7885cdaf2a1.VatId M'.ConstMsg) VatId where
    decerialize raw = VatId
            <$> (Capnp.ById.Xa184c7885cdaf2a1.get_VatId'side raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMsg VatId where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xa184c7885cdaf2a1.VatId M'.ConstMsg)

