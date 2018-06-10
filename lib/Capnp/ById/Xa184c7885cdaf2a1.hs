{-# OPTIONS_GHC -Wno-unused-imports #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE KindSignatures #-}
module Capnp.ById.Xa184c7885cdaf2a1 where

-- Code generated by capnpc-haskell. DO NOT EDIT.
-- Generated from schema file: capnp/rpc-twoparty.capnp

import Data.Int
import Data.Word
import qualified Data.Bits
import qualified Data.Maybe
import qualified Codec.Capnp
import qualified Data.Capnp.BuiltinTypes
import qualified Data.Capnp.TraversalLimit
import qualified Data.Capnp.Untyped

import qualified Capnp.ById.Xbdf87d7bb8304e81

newtype JoinKeyPart (m :: * -> *) = JoinKeyPart (Data.Capnp.Untyped.Struct m)

instance Data.Capnp.Untyped.ReadCtx m => Codec.Capnp.IsStruct m (JoinKeyPart m) where
    fromStruct = pure . JoinKeyPart
instance Data.Capnp.Untyped.ReadCtx m => Codec.Capnp.IsPtr m (JoinKeyPart m) where
    fromPtr = Codec.Capnp.structPtr

instance Data.Capnp.Untyped.ReadCtx m => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m (JoinKeyPart m)) where
    fromPtr = Codec.Capnp.structListPtr
get_JoinKeyPart'joinId :: Data.Capnp.Untyped.ReadCtx m => JoinKeyPart m -> m Word32
get_JoinKeyPart'joinId (JoinKeyPart struct) = Codec.Capnp.getWordField struct 0 0 0

has_JoinKeyPart'joinId :: Data.Capnp.Untyped.ReadCtx m => JoinKeyPart m -> m Bool
has_JoinKeyPart'joinId(JoinKeyPart struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_JoinKeyPart'partCount :: Data.Capnp.Untyped.ReadCtx m => JoinKeyPart m -> m Word16
get_JoinKeyPart'partCount (JoinKeyPart struct) = Codec.Capnp.getWordField struct 0 32 0

has_JoinKeyPart'partCount :: Data.Capnp.Untyped.ReadCtx m => JoinKeyPart m -> m Bool
has_JoinKeyPart'partCount(JoinKeyPart struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_JoinKeyPart'partNum :: Data.Capnp.Untyped.ReadCtx m => JoinKeyPart m -> m Word16
get_JoinKeyPart'partNum (JoinKeyPart struct) = Codec.Capnp.getWordField struct 0 48 0

has_JoinKeyPart'partNum :: Data.Capnp.Untyped.ReadCtx m => JoinKeyPart m -> m Bool
has_JoinKeyPart'partNum(JoinKeyPart struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
newtype JoinResult (m :: * -> *) = JoinResult (Data.Capnp.Untyped.Struct m)

instance Data.Capnp.Untyped.ReadCtx m => Codec.Capnp.IsStruct m (JoinResult m) where
    fromStruct = pure . JoinResult
instance Data.Capnp.Untyped.ReadCtx m => Codec.Capnp.IsPtr m (JoinResult m) where
    fromPtr = Codec.Capnp.structPtr

instance Data.Capnp.Untyped.ReadCtx m => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m (JoinResult m)) where
    fromPtr = Codec.Capnp.structListPtr
get_JoinResult'joinId :: Data.Capnp.Untyped.ReadCtx m => JoinResult m -> m Word32
get_JoinResult'joinId (JoinResult struct) = Codec.Capnp.getWordField struct 0 0 0

has_JoinResult'joinId :: Data.Capnp.Untyped.ReadCtx m => JoinResult m -> m Bool
has_JoinResult'joinId(JoinResult struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_JoinResult'succeeded :: Data.Capnp.Untyped.ReadCtx m => JoinResult m -> m Bool
get_JoinResult'succeeded (JoinResult struct) = Codec.Capnp.getWordField struct 0 32 0

has_JoinResult'succeeded :: Data.Capnp.Untyped.ReadCtx m => JoinResult m -> m Bool
has_JoinResult'succeeded(JoinResult struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_JoinResult'cap :: Data.Capnp.Untyped.ReadCtx m => JoinResult m -> m (Maybe (Data.Capnp.Untyped.Ptr m))
get_JoinResult'cap (JoinResult struct) =
    Data.Capnp.Untyped.getPtr 0 struct
    >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct)


has_JoinResult'cap :: Data.Capnp.Untyped.ReadCtx m => JoinResult m -> m Bool
has_JoinResult'cap(JoinResult struct) = Data.Maybe.isJust <$> Data.Capnp.Untyped.getPtr 0 struct
data Side (m :: * -> *)
    = Side'server
    | Side'client
    | Side'unknown' Word16
instance Enum (Side m) where
    toEnum = Codec.Capnp.fromWord . fromIntegral
    fromEnum = fromIntegral . Codec.Capnp.toWord


instance Codec.Capnp.IsWord (Side m) where
    fromWord n = go (fromIntegral n :: Word16)
      where
        go 1 = Side'client
        go 0 = Side'server
        go tag = Side'unknown' (fromIntegral tag)
    toWord Side'client = 1
    toWord Side'server = 0
    toWord (Side'unknown' tag) = fromIntegral tag
instance Data.Capnp.Untyped.ReadCtx m => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m (Side m)) where
    fromPtr msg ptr = fmap
       (fmap (toEnum . (fromIntegral :: Word16 -> Int)))
       (Codec.Capnp.fromPtr msg ptr)

newtype ProvisionId (m :: * -> *) = ProvisionId (Data.Capnp.Untyped.Struct m)

instance Data.Capnp.Untyped.ReadCtx m => Codec.Capnp.IsStruct m (ProvisionId m) where
    fromStruct = pure . ProvisionId
instance Data.Capnp.Untyped.ReadCtx m => Codec.Capnp.IsPtr m (ProvisionId m) where
    fromPtr = Codec.Capnp.structPtr

instance Data.Capnp.Untyped.ReadCtx m => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m (ProvisionId m)) where
    fromPtr = Codec.Capnp.structListPtr
get_ProvisionId'joinId :: Data.Capnp.Untyped.ReadCtx m => ProvisionId m -> m Word32
get_ProvisionId'joinId (ProvisionId struct) = Codec.Capnp.getWordField struct 0 0 0

has_ProvisionId'joinId :: Data.Capnp.Untyped.ReadCtx m => ProvisionId m -> m Bool
has_ProvisionId'joinId(ProvisionId struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
newtype VatId (m :: * -> *) = VatId (Data.Capnp.Untyped.Struct m)

instance Data.Capnp.Untyped.ReadCtx m => Codec.Capnp.IsStruct m (VatId m) where
    fromStruct = pure . VatId
instance Data.Capnp.Untyped.ReadCtx m => Codec.Capnp.IsPtr m (VatId m) where
    fromPtr = Codec.Capnp.structPtr

instance Data.Capnp.Untyped.ReadCtx m => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m (VatId m)) where
    fromPtr = Codec.Capnp.structListPtr
get_VatId'side :: Data.Capnp.Untyped.ReadCtx m => VatId m -> m (Side m)
get_VatId'side (VatId struct) = Codec.Capnp.getWordField struct 0 0 0

has_VatId'side :: Data.Capnp.Untyped.ReadCtx m => VatId m -> m Bool
has_VatId'side(VatId struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)