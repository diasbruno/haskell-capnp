{-# OPTIONS_GHC -Wno-unused-imports #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Capnp.Capnp.Persistent where

-- Code generated by capnpc-haskell. DO NOT EDIT.
-- Generated from schema file: capnp/persistent.capnp

import Data.Int
import Data.Word

import GHC.OverloadedLabels

import Data.Capnp.Bits (Word1)

import qualified Data.Bits
import qualified Data.Maybe
import qualified Codec.Capnp as C'
import qualified Data.Capnp.Basics as B'
import qualified Data.Capnp.TraversalLimit as TL'
import qualified Data.Capnp.Untyped as U'
import qualified Data.Capnp.Message as M'

import qualified Capnp.ById.Xbdf87d7bb8304e81

newtype Persistent'SaveParams msg = Persistent'SaveParams_newtype_ (U'.Struct msg)

instance C'.IsStruct msg (Persistent'SaveParams msg) where
    fromStruct = pure . Persistent'SaveParams_newtype_
instance C'.IsPtr msg (Persistent'SaveParams msg) where
    fromPtr msg ptr = Persistent'SaveParams_newtype_ <$> C'.fromPtr msg ptr
    toPtr (Persistent'SaveParams_newtype_ struct) = C'.toPtr struct
instance B'.ListElem msg (Persistent'SaveParams msg) where
    newtype List msg (Persistent'SaveParams msg) = List_Persistent'SaveParams (U'.ListOf msg (U'.Struct msg))
    length (List_Persistent'SaveParams l) = U'.length l
    index i (List_Persistent'SaveParams l) = U'.index i l >>= (let {go :: U'.ReadCtx m msg => U'.Struct msg -> m (Persistent'SaveParams msg); go = C'.fromStruct} in go)
instance B'.MutListElem s (Persistent'SaveParams (M'.MutMsg s)) where
    setIndex (Persistent'SaveParams_newtype_ elt) i (List_Persistent'SaveParams l) = U'.setIndex elt i l
    allocList msg len = List_Persistent'SaveParams <$> U'.allocCompositeList msg 0 1 len
instance U'.HasMessage (Persistent'SaveParams msg) msg where
    message (Persistent'SaveParams_newtype_ struct) = U'.message struct
instance U'.MessageDefault (Persistent'SaveParams msg) msg where
    messageDefault = Persistent'SaveParams_newtype_ . U'.messageDefault

instance C'.Allocate s (Persistent'SaveParams (M'.MutMsg s)) where
    new msg = Persistent'SaveParams_newtype_ <$> U'.allocStruct msg 0 1
instance C'.IsPtr msg (B'.List msg (Persistent'SaveParams msg)) where
    fromPtr msg ptr = List_Persistent'SaveParams <$> C'.fromPtr msg ptr
    toPtr (List_Persistent'SaveParams l) = C'.toPtr l
get_Persistent'SaveParams'sealFor :: U'.ReadCtx m msg => Persistent'SaveParams msg -> m (Maybe (U'.Ptr msg))
get_Persistent'SaveParams'sealFor (Persistent'SaveParams_newtype_ struct) =
    U'.getPtr 0 struct
    >>= C'.fromPtr (U'.message struct)


has_Persistent'SaveParams'sealFor :: U'.ReadCtx m msg => Persistent'SaveParams msg -> m Bool
has_Persistent'SaveParams'sealFor(Persistent'SaveParams_newtype_ struct) = Data.Maybe.isJust <$> U'.getPtr 0 struct

set_Persistent'SaveParams'sealFor :: (U'.ReadCtx m (M'.MutMsg s), M'.WriteCtx m s) => Persistent'SaveParams (M'.MutMsg s) -> (Maybe (U'.Ptr (M'.MutMsg s))) -> m ()
set_Persistent'SaveParams'sealFor (Persistent'SaveParams_newtype_ struct) value = U'.setPtr (C'.toPtr value) 0 struct



newtype Persistent'SaveResults msg = Persistent'SaveResults_newtype_ (U'.Struct msg)

instance C'.IsStruct msg (Persistent'SaveResults msg) where
    fromStruct = pure . Persistent'SaveResults_newtype_
instance C'.IsPtr msg (Persistent'SaveResults msg) where
    fromPtr msg ptr = Persistent'SaveResults_newtype_ <$> C'.fromPtr msg ptr
    toPtr (Persistent'SaveResults_newtype_ struct) = C'.toPtr struct
instance B'.ListElem msg (Persistent'SaveResults msg) where
    newtype List msg (Persistent'SaveResults msg) = List_Persistent'SaveResults (U'.ListOf msg (U'.Struct msg))
    length (List_Persistent'SaveResults l) = U'.length l
    index i (List_Persistent'SaveResults l) = U'.index i l >>= (let {go :: U'.ReadCtx m msg => U'.Struct msg -> m (Persistent'SaveResults msg); go = C'.fromStruct} in go)
instance B'.MutListElem s (Persistent'SaveResults (M'.MutMsg s)) where
    setIndex (Persistent'SaveResults_newtype_ elt) i (List_Persistent'SaveResults l) = U'.setIndex elt i l
    allocList msg len = List_Persistent'SaveResults <$> U'.allocCompositeList msg 0 1 len
instance U'.HasMessage (Persistent'SaveResults msg) msg where
    message (Persistent'SaveResults_newtype_ struct) = U'.message struct
instance U'.MessageDefault (Persistent'SaveResults msg) msg where
    messageDefault = Persistent'SaveResults_newtype_ . U'.messageDefault

instance C'.Allocate s (Persistent'SaveResults (M'.MutMsg s)) where
    new msg = Persistent'SaveResults_newtype_ <$> U'.allocStruct msg 0 1
instance C'.IsPtr msg (B'.List msg (Persistent'SaveResults msg)) where
    fromPtr msg ptr = List_Persistent'SaveResults <$> C'.fromPtr msg ptr
    toPtr (List_Persistent'SaveResults l) = C'.toPtr l
get_Persistent'SaveResults'sturdyRef :: U'.ReadCtx m msg => Persistent'SaveResults msg -> m (Maybe (U'.Ptr msg))
get_Persistent'SaveResults'sturdyRef (Persistent'SaveResults_newtype_ struct) =
    U'.getPtr 0 struct
    >>= C'.fromPtr (U'.message struct)


has_Persistent'SaveResults'sturdyRef :: U'.ReadCtx m msg => Persistent'SaveResults msg -> m Bool
has_Persistent'SaveResults'sturdyRef(Persistent'SaveResults_newtype_ struct) = Data.Maybe.isJust <$> U'.getPtr 0 struct

set_Persistent'SaveResults'sturdyRef :: (U'.ReadCtx m (M'.MutMsg s), M'.WriteCtx m s) => Persistent'SaveResults (M'.MutMsg s) -> (Maybe (U'.Ptr (M'.MutMsg s))) -> m ()
set_Persistent'SaveResults'sturdyRef (Persistent'SaveResults_newtype_ struct) value = U'.setPtr (C'.toPtr value) 0 struct


