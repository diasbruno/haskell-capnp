{-# OPTIONS_GHC -Wno-unused-imports #-}
{-# OPTIONS_GHC -Wno-unused-matches #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveGeneric #-}
{- |
Module: Capnp.Gen.Echo
Description: Low-level generated module for echo.capnp
This module is the generated code for echo.capnp, for the
low-level api.
-}
module Capnp.Gen.Echo where
-- Code generated by capnpc-haskell. DO NOT EDIT.
-- Generated from schema file: echo.capnp
import Data.Int
import Data.Word
import GHC.Generics (Generic)
import Capnp.Bits (Word1)
import qualified Data.Bits
import qualified Data.Maybe
import qualified Data.ByteString
import qualified Capnp.Classes as C'
import qualified Capnp.Basics as B'
import qualified Capnp.GenHelpers as H'
import qualified Capnp.TraversalLimit as TL'
import qualified Capnp.Untyped as U'
import qualified Capnp.Message as M'
newtype Echo msg = Echo (Maybe (U'.Cap msg))
instance C'.FromPtr msg (Echo msg) where
    fromPtr msg cap = Echo <$> C'.fromPtr msg cap
instance C'.ToPtr s (Echo (M'.MutMsg s)) where
    toPtr msg (Echo Nothing) = pure Nothing
    toPtr msg (Echo (Just cap)) = pure $ Just $ U'.PtrCap cap
newtype Echo'echo'params msg = Echo'echo'params_newtype_ (U'.Struct msg)
instance U'.TraverseMsg Echo'echo'params where
    tMsg f (Echo'echo'params_newtype_ s) = Echo'echo'params_newtype_ <$> U'.tMsg f s
instance C'.FromStruct msg (Echo'echo'params msg) where
    fromStruct = pure . Echo'echo'params_newtype_
instance C'.ToStruct msg (Echo'echo'params msg) where
    toStruct (Echo'echo'params_newtype_ struct) = struct
instance U'.HasMessage (Echo'echo'params msg) where
    type InMessage (Echo'echo'params msg) = msg
    message (Echo'echo'params_newtype_ struct) = U'.message struct
instance U'.MessageDefault (Echo'echo'params msg) where
    messageDefault = Echo'echo'params_newtype_ . U'.messageDefault
instance B'.ListElem msg (Echo'echo'params msg) where
    newtype List msg (Echo'echo'params msg) = List_Echo'echo'params (U'.ListOf msg (U'.Struct msg))
    listFromPtr msg ptr = List_Echo'echo'params <$> C'.fromPtr msg ptr
    toUntypedList (List_Echo'echo'params l) = U'.ListStruct l
    length (List_Echo'echo'params l) = U'.length l
    index i (List_Echo'echo'params l) = U'.index i l >>= (let {go :: U'.ReadCtx m msg => U'.Struct msg -> m (Echo'echo'params msg); go = C'.fromStruct} in go)
instance C'.FromPtr msg (Echo'echo'params msg) where
    fromPtr msg ptr = Echo'echo'params_newtype_ <$> C'.fromPtr msg ptr
instance C'.ToPtr s (Echo'echo'params (M'.MutMsg s)) where
    toPtr msg (Echo'echo'params_newtype_ struct) = C'.toPtr msg struct
instance B'.MutListElem s (Echo'echo'params (M'.MutMsg s)) where
    setIndex (Echo'echo'params_newtype_ elt) i (List_Echo'echo'params l) = U'.setIndex elt i l
    newList msg len = List_Echo'echo'params <$> U'.allocCompositeList msg 0 1 len
instance C'.Allocate s (Echo'echo'params (M'.MutMsg s)) where
    new msg = Echo'echo'params_newtype_ <$> U'.allocStruct msg 0 1
get_Echo'echo'params'query :: U'.ReadCtx m msg => Echo'echo'params msg -> m (B'.Text msg)
get_Echo'echo'params'query (Echo'echo'params_newtype_ struct) =
    U'.getPtr 0 struct
    >>= C'.fromPtr (U'.message struct)
has_Echo'echo'params'query :: U'.ReadCtx m msg => Echo'echo'params msg -> m Bool
has_Echo'echo'params'query(Echo'echo'params_newtype_ struct) = Data.Maybe.isJust <$> U'.getPtr 0 struct
set_Echo'echo'params'query :: U'.RWCtx m s => Echo'echo'params (M'.MutMsg s) -> (B'.Text (M'.MutMsg s)) -> m ()
set_Echo'echo'params'query (Echo'echo'params_newtype_ struct) value = do
    ptr <- C'.toPtr (U'.message struct) value
    U'.setPtr ptr 0 struct
new_Echo'echo'params'query :: U'.RWCtx m s => Int -> Echo'echo'params (M'.MutMsg s) -> m ((B'.Text (M'.MutMsg s)))
new_Echo'echo'params'query len struct = do
    result <- B'.newText (U'.message struct) len
    set_Echo'echo'params'query struct result
    pure result
newtype Echo'echo'results msg = Echo'echo'results_newtype_ (U'.Struct msg)
instance U'.TraverseMsg Echo'echo'results where
    tMsg f (Echo'echo'results_newtype_ s) = Echo'echo'results_newtype_ <$> U'.tMsg f s
instance C'.FromStruct msg (Echo'echo'results msg) where
    fromStruct = pure . Echo'echo'results_newtype_
instance C'.ToStruct msg (Echo'echo'results msg) where
    toStruct (Echo'echo'results_newtype_ struct) = struct
instance U'.HasMessage (Echo'echo'results msg) where
    type InMessage (Echo'echo'results msg) = msg
    message (Echo'echo'results_newtype_ struct) = U'.message struct
instance U'.MessageDefault (Echo'echo'results msg) where
    messageDefault = Echo'echo'results_newtype_ . U'.messageDefault
instance B'.ListElem msg (Echo'echo'results msg) where
    newtype List msg (Echo'echo'results msg) = List_Echo'echo'results (U'.ListOf msg (U'.Struct msg))
    listFromPtr msg ptr = List_Echo'echo'results <$> C'.fromPtr msg ptr
    toUntypedList (List_Echo'echo'results l) = U'.ListStruct l
    length (List_Echo'echo'results l) = U'.length l
    index i (List_Echo'echo'results l) = U'.index i l >>= (let {go :: U'.ReadCtx m msg => U'.Struct msg -> m (Echo'echo'results msg); go = C'.fromStruct} in go)
instance C'.FromPtr msg (Echo'echo'results msg) where
    fromPtr msg ptr = Echo'echo'results_newtype_ <$> C'.fromPtr msg ptr
instance C'.ToPtr s (Echo'echo'results (M'.MutMsg s)) where
    toPtr msg (Echo'echo'results_newtype_ struct) = C'.toPtr msg struct
instance B'.MutListElem s (Echo'echo'results (M'.MutMsg s)) where
    setIndex (Echo'echo'results_newtype_ elt) i (List_Echo'echo'results l) = U'.setIndex elt i l
    newList msg len = List_Echo'echo'results <$> U'.allocCompositeList msg 0 1 len
instance C'.Allocate s (Echo'echo'results (M'.MutMsg s)) where
    new msg = Echo'echo'results_newtype_ <$> U'.allocStruct msg 0 1
get_Echo'echo'results'reply :: U'.ReadCtx m msg => Echo'echo'results msg -> m (B'.Text msg)
get_Echo'echo'results'reply (Echo'echo'results_newtype_ struct) =
    U'.getPtr 0 struct
    >>= C'.fromPtr (U'.message struct)
has_Echo'echo'results'reply :: U'.ReadCtx m msg => Echo'echo'results msg -> m Bool
has_Echo'echo'results'reply(Echo'echo'results_newtype_ struct) = Data.Maybe.isJust <$> U'.getPtr 0 struct
set_Echo'echo'results'reply :: U'.RWCtx m s => Echo'echo'results (M'.MutMsg s) -> (B'.Text (M'.MutMsg s)) -> m ()
set_Echo'echo'results'reply (Echo'echo'results_newtype_ struct) value = do
    ptr <- C'.toPtr (U'.message struct) value
    U'.setPtr ptr 0 struct
new_Echo'echo'results'reply :: U'.RWCtx m s => Int -> Echo'echo'results (M'.MutMsg s) -> m ((B'.Text (M'.MutMsg s)))
new_Echo'echo'results'reply len struct = do
    result <- B'.newText (U'.message struct) len
    set_Echo'echo'results'reply struct result
    pure result