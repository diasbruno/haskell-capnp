{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}
{- |
Module: Capnp.Capnp.Json.Pure
Description: High-level generated module for capnp/json.capnp
This module is the generated code for capnp/json.capnp,
for the high-level api.
-}
module Capnp.Capnp.Json.Pure (JsonValue(..), JsonValue'Call(..), JsonValue'Field(..)
) where
-- Code generated by capnpc-haskell. DO NOT EDIT.
-- Generated from schema file: capnp/json.capnp
import Data.Int
import Data.Word
import Data.Capnp.Untyped.Pure (List)
import Data.Capnp.Basics.Pure (Data, Text)
import Control.Monad.Catch (MonadThrow)
import Data.Capnp.TraversalLimit (MonadLimit)
import Control.Monad (forM_)
import qualified Data.Capnp.Message as M'
import qualified Data.Capnp.Untyped.Pure as PU'
import qualified Codec.Capnp as C'
import qualified Data.Vector as V
import qualified Capnp.ById.X8ef99297a43a5e34
import qualified Capnp.ById.Xbdf87d7bb8304e81.Pure
import qualified Capnp.ById.Xbdf87d7bb8304e81
data JsonValue
     = JsonValue'null |
    JsonValue'boolean (Bool) |
    JsonValue'number (Double) |
    JsonValue'string (Text) |
    JsonValue'array (List (JsonValue)) |
    JsonValue'object (List (JsonValue'Field)) |
    JsonValue'call (JsonValue'Call) |
    JsonValue'unknown' (Word16)
    deriving(Show, Read, Eq)
instance C'.Decerialize (Capnp.ById.X8ef99297a43a5e34.JsonValue M'.ConstMsg) JsonValue where
    decerialize raw = do
        raw <- Capnp.ById.X8ef99297a43a5e34.get_JsonValue' raw
        case raw of
            Capnp.ById.X8ef99297a43a5e34.JsonValue'null -> pure JsonValue'null
            Capnp.ById.X8ef99297a43a5e34.JsonValue'boolean val -> JsonValue'boolean <$> C'.decerialize val
            Capnp.ById.X8ef99297a43a5e34.JsonValue'number val -> JsonValue'number <$> C'.decerialize val
            Capnp.ById.X8ef99297a43a5e34.JsonValue'string val -> JsonValue'string <$> C'.decerialize val
            Capnp.ById.X8ef99297a43a5e34.JsonValue'array val -> JsonValue'array <$> C'.decerialize val
            Capnp.ById.X8ef99297a43a5e34.JsonValue'object val -> JsonValue'object <$> C'.decerialize val
            Capnp.ById.X8ef99297a43a5e34.JsonValue'call val -> JsonValue'call <$> C'.decerialize val
            Capnp.ById.X8ef99297a43a5e34.JsonValue'unknown' val -> JsonValue'unknown' <$> C'.decerialize val
instance C'.IsStruct M'.ConstMsg JsonValue where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.X8ef99297a43a5e34.JsonValue M'.ConstMsg)
instance C'.Cerialize s JsonValue (Capnp.ById.X8ef99297a43a5e34.JsonValue (M'.MutMsg s)) where
    marshalInto raw value = do
        case value of
            JsonValue'null -> Capnp.ById.X8ef99297a43a5e34.set_JsonValue'null raw
            JsonValue'boolean _ -> pure ()
            JsonValue'number _ -> pure ()
            JsonValue'string _ -> pure ()
            JsonValue'array _ -> pure ()
            JsonValue'object _ -> pure ()
            JsonValue'call _ -> pure ()
            JsonValue'unknown' _ -> pure ()
data JsonValue'Call
     = JsonValue'Call
        {function :: Text,
        params :: List (JsonValue)}
    deriving(Show, Read, Eq)
instance C'.Decerialize (Capnp.ById.X8ef99297a43a5e34.JsonValue'Call M'.ConstMsg) JsonValue'Call where
    decerialize raw = JsonValue'Call <$>
        (Capnp.ById.X8ef99297a43a5e34.get_JsonValue'Call'function raw >>= C'.decerialize) <*>
        (Capnp.ById.X8ef99297a43a5e34.get_JsonValue'Call'params raw >>= C'.decerialize)
instance C'.IsStruct M'.ConstMsg JsonValue'Call where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.X8ef99297a43a5e34.JsonValue'Call M'.ConstMsg)
instance C'.Cerialize s JsonValue'Call (Capnp.ById.X8ef99297a43a5e34.JsonValue'Call (M'.MutMsg s)) where
    marshalInto raw value = do
        case value of
            JsonValue'Call{..} -> do
                pure ()
                let len_ = V.length params
                field_ <- Capnp.ById.X8ef99297a43a5e34.new_JsonValue'Call'params len_ raw
                forM_ [0..len_ - 1] $ \i -> do
                    elt <- C'.index i field_
                    C'.marshalInto elt (params V.! i)
data JsonValue'Field
     = JsonValue'Field
        {name :: Text,
        value :: JsonValue}
    deriving(Show, Read, Eq)
instance C'.Decerialize (Capnp.ById.X8ef99297a43a5e34.JsonValue'Field M'.ConstMsg) JsonValue'Field where
    decerialize raw = JsonValue'Field <$>
        (Capnp.ById.X8ef99297a43a5e34.get_JsonValue'Field'name raw >>= C'.decerialize) <*>
        (Capnp.ById.X8ef99297a43a5e34.get_JsonValue'Field'value raw >>= C'.decerialize)
instance C'.IsStruct M'.ConstMsg JsonValue'Field where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.X8ef99297a43a5e34.JsonValue'Field M'.ConstMsg)
instance C'.Cerialize s JsonValue'Field (Capnp.ById.X8ef99297a43a5e34.JsonValue'Field (M'.MutMsg s)) where
    marshalInto raw value = do
        case value of
            JsonValue'Field{..} -> do
                pure ()
                pure ()