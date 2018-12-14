{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}
{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-name-shadowing #-}
{-# OPTIONS_GHC -Wno-unused-matches #-}
{- |
Module: Capnp.Gen.Calculator.Pure
Description: High-level generated module for calculator.capnp
This module is the generated code for calculator.capnp,
for the high-level api.
-}
module Capnp.Gen.Calculator.Pure (Calculator(..), Calculator'server_(..),export_Calculator, Expression(..), Function(..), Function'server_(..),export_Function, Capnp.Gen.ById.X85150b117366d14b.Operator(..), Value(..), Value'server_(..),export_Value, Calculator'defFunction'params(..), Calculator'defFunction'results(..), Calculator'evaluate'params(..), Calculator'evaluate'results(..), Calculator'getOperator'params(..), Calculator'getOperator'results(..), Function'call'params(..), Function'call'results(..), Value'read'params(..), Value'read'results(..)
) where
-- Code generated by capnpc-haskell. DO NOT EDIT.
-- Generated from schema file: calculator.capnp
import Data.Int
import Data.Word
import Data.Default (Default(def))
import GHC.Generics (Generic)
import Capnp.Basics.Pure (Data, Text)
import Control.Monad.Catch (MonadThrow(throwM))
import Control.Concurrent.STM (STM)
import Control.Monad.IO.Class (MonadIO(liftIO))
import Capnp.TraversalLimit (MonadLimit, evalLimitT)
import Control.Monad (forM_)
import qualified Capnp.Convert as Convert
import qualified Capnp.Message as M'
import qualified Capnp.Untyped as U'
import qualified Capnp.Untyped.Pure as PU'
import qualified Capnp.GenHelpers.Pure as PH'
import qualified Capnp.Classes as C'
import qualified Capnp.Rpc.Untyped as Rpc
import qualified Capnp.Rpc.Server as Server
import qualified Capnp.Gen.Capnp.Rpc.Pure as Rpc
import qualified Capnp.Promise as Promise
import qualified Capnp.GenHelpers.Rpc as RH'
import qualified Data.Vector as V
import qualified Data.ByteString as BS
import qualified Supervisors
import qualified Capnp.Gen.ById.X85150b117366d14b
newtype Calculator = Calculator M'.Client
    deriving(Show, Eq, Generic)
instance Rpc.IsClient Calculator where
    fromClient = Calculator
    toClient (Calculator client) = client
instance C'.FromPtr msg Calculator where
    fromPtr = RH'.isClientFromPtr
instance C'.ToPtr s Calculator where
    toPtr = RH'.isClientToPtr
instance C'.Decerialize Calculator where
    type Cerial msg Calculator = Capnp.Gen.ById.X85150b117366d14b.Calculator msg
    decerialize (Capnp.Gen.ById.X85150b117366d14b.Calculator Nothing) = pure $ Calculator M'.nullClient
    decerialize (Capnp.Gen.ById.X85150b117366d14b.Calculator (Just cap)) = Calculator <$> U'.getClient cap
instance C'.Cerialize Calculator where
    cerialize msg (Calculator client) = Capnp.Gen.ById.X85150b117366d14b.Calculator . Just <$> U'.appendCap msg client
class MonadIO m => Calculator'server_ m cap where
    {-# MINIMAL calculator'evaluate, calculator'defFunction, calculator'getOperator #-}
    calculator'evaluate :: cap -> Server.MethodHandler m (Calculator'evaluate'params) (Calculator'evaluate'results)
    calculator'evaluate _ = Server.methodUnimplemented
    calculator'defFunction :: cap -> Server.MethodHandler m (Calculator'defFunction'params) (Calculator'defFunction'results)
    calculator'defFunction _ = Server.methodUnimplemented
    calculator'getOperator :: cap -> Server.MethodHandler m (Calculator'getOperator'params) (Calculator'getOperator'results)
    calculator'getOperator _ = Server.methodUnimplemented
export_Calculator :: Calculator'server_ IO a => Supervisors.Supervisor -> a -> STM Calculator
export_Calculator sup_ server_ = Calculator <$> Rpc.export sup_ Server.ServerOps
    { handleStop = pure () -- TODO
    , handleCall = \interfaceId methodId -> case interfaceId of
        10923537602090224694 -> case methodId of
            0 -> Server.toUntypedHandler (calculator'evaluate server_)
            1 -> Server.toUntypedHandler (calculator'defFunction server_)
            2 -> Server.toUntypedHandler (calculator'getOperator server_)
            _ -> Server.methodUnimplemented
        _ -> Server.methodUnimplemented
    }
instance Calculator'server_ IO Calculator where
    calculator'evaluate (Calculator client) = Rpc.clientMethodHandler 10923537602090224694 0 client
    calculator'defFunction (Calculator client) = Rpc.clientMethodHandler 10923537602090224694 1 client
    calculator'getOperator (Calculator client) = Rpc.clientMethodHandler 10923537602090224694 2 client
data Expression
    = Expression'literal (Double)
    | Expression'previousResult (Value)
    | Expression'parameter (Word32)
    | Expression'call
        {function :: Function,
        params :: PU'.ListOf (Expression)}
    | Expression'unknown' Word16
    deriving(Show,Eq,Generic)
instance C'.Decerialize Expression where
    type Cerial msg Expression = Capnp.Gen.ById.X85150b117366d14b.Expression msg
    decerialize raw = do
        raw <- Capnp.Gen.ById.X85150b117366d14b.get_Expression' raw
        case raw of
            Capnp.Gen.ById.X85150b117366d14b.Expression'literal val -> pure (Expression'literal val)
            Capnp.Gen.ById.X85150b117366d14b.Expression'previousResult val -> Expression'previousResult <$> C'.decerialize val
            Capnp.Gen.ById.X85150b117366d14b.Expression'parameter val -> pure (Expression'parameter val)
            Capnp.Gen.ById.X85150b117366d14b.Expression'call raw -> Expression'call <$>
                (Capnp.Gen.ById.X85150b117366d14b.get_Expression'call'function raw >>= C'.decerialize) <*>
                (Capnp.Gen.ById.X85150b117366d14b.get_Expression'call'params raw >>= C'.decerialize)
            Capnp.Gen.ById.X85150b117366d14b.Expression'unknown' val -> pure $ Expression'unknown' val
instance C'.Marshal Expression where
    marshalInto raw value = do
        case value of
            Expression'literal arg_ -> Capnp.Gen.ById.X85150b117366d14b.set_Expression'literal raw arg_
            Expression'previousResult arg_ -> do
                field_ <- C'.cerialize (U'.message raw) arg_
                Capnp.Gen.ById.X85150b117366d14b.set_Expression'previousResult raw field_
            Expression'parameter arg_ -> Capnp.Gen.ById.X85150b117366d14b.set_Expression'parameter raw arg_
            Expression'call{..} -> do
                raw <- Capnp.Gen.ById.X85150b117366d14b.set_Expression'call raw
                field_ <- C'.cerialize (U'.message raw) function
                Capnp.Gen.ById.X85150b117366d14b.set_Expression'call'function raw field_
                let len_ = V.length params
                field_ <- Capnp.Gen.ById.X85150b117366d14b.new_Expression'call'params len_ raw
                forM_ [0..len_ - 1] $ \i -> do
                    elt <- C'.index i field_
                    C'.marshalInto elt (params V.! i)
            Expression'unknown' arg_ -> Capnp.Gen.ById.X85150b117366d14b.set_Expression'unknown' raw arg_
instance C'.Cerialize Expression
instance C'.FromStruct M'.ConstMsg Expression where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.Gen.ById.X85150b117366d14b.Expression M'.ConstMsg)
instance Default Expression where
    def = PH'.defaultStruct
newtype Function = Function M'.Client
    deriving(Show, Eq, Generic)
instance Rpc.IsClient Function where
    fromClient = Function
    toClient (Function client) = client
instance C'.FromPtr msg Function where
    fromPtr = RH'.isClientFromPtr
instance C'.ToPtr s Function where
    toPtr = RH'.isClientToPtr
instance C'.Decerialize Function where
    type Cerial msg Function = Capnp.Gen.ById.X85150b117366d14b.Function msg
    decerialize (Capnp.Gen.ById.X85150b117366d14b.Function Nothing) = pure $ Function M'.nullClient
    decerialize (Capnp.Gen.ById.X85150b117366d14b.Function (Just cap)) = Function <$> U'.getClient cap
instance C'.Cerialize Function where
    cerialize msg (Function client) = Capnp.Gen.ById.X85150b117366d14b.Function . Just <$> U'.appendCap msg client
class MonadIO m => Function'server_ m cap where
    {-# MINIMAL function'call #-}
    function'call :: cap -> Server.MethodHandler m (Function'call'params) (Function'call'results)
    function'call _ = Server.methodUnimplemented
export_Function :: Function'server_ IO a => Supervisors.Supervisor -> a -> STM Function
export_Function sup_ server_ = Function <$> Rpc.export sup_ Server.ServerOps
    { handleStop = pure () -- TODO
    , handleCall = \interfaceId methodId -> case interfaceId of
        17143016017778443156 -> case methodId of
            0 -> Server.toUntypedHandler (function'call server_)
            _ -> Server.methodUnimplemented
        _ -> Server.methodUnimplemented
    }
instance Function'server_ IO Function where
    function'call (Function client) = Rpc.clientMethodHandler 17143016017778443156 0 client
instance C'.Decerialize Capnp.Gen.ById.X85150b117366d14b.Operator where
    type Cerial msg Capnp.Gen.ById.X85150b117366d14b.Operator = Capnp.Gen.ById.X85150b117366d14b.Operator
    decerialize = pure
newtype Value = Value M'.Client
    deriving(Show, Eq, Generic)
instance Rpc.IsClient Value where
    fromClient = Value
    toClient (Value client) = client
instance C'.FromPtr msg Value where
    fromPtr = RH'.isClientFromPtr
instance C'.ToPtr s Value where
    toPtr = RH'.isClientToPtr
instance C'.Decerialize Value where
    type Cerial msg Value = Capnp.Gen.ById.X85150b117366d14b.Value msg
    decerialize (Capnp.Gen.ById.X85150b117366d14b.Value Nothing) = pure $ Value M'.nullClient
    decerialize (Capnp.Gen.ById.X85150b117366d14b.Value (Just cap)) = Value <$> U'.getClient cap
instance C'.Cerialize Value where
    cerialize msg (Value client) = Capnp.Gen.ById.X85150b117366d14b.Value . Just <$> U'.appendCap msg client
class MonadIO m => Value'server_ m cap where
    {-# MINIMAL value'read #-}
    value'read :: cap -> Server.MethodHandler m (Value'read'params) (Value'read'results)
    value'read _ = Server.methodUnimplemented
export_Value :: Value'server_ IO a => Supervisors.Supervisor -> a -> STM Value
export_Value sup_ server_ = Value <$> Rpc.export sup_ Server.ServerOps
    { handleStop = pure () -- TODO
    , handleCall = \interfaceId methodId -> case interfaceId of
        14116142932258867410 -> case methodId of
            0 -> Server.toUntypedHandler (value'read server_)
            _ -> Server.methodUnimplemented
        _ -> Server.methodUnimplemented
    }
instance Value'server_ IO Value where
    value'read (Value client) = Rpc.clientMethodHandler 14116142932258867410 0 client
data Calculator'defFunction'params
    = Calculator'defFunction'params
        {paramCount :: Int32,
        body :: Expression}
    deriving(Show,Eq,Generic)
instance C'.Decerialize Calculator'defFunction'params where
    type Cerial msg Calculator'defFunction'params = Capnp.Gen.ById.X85150b117366d14b.Calculator'defFunction'params msg
    decerialize raw = do
        Calculator'defFunction'params <$>
            (Capnp.Gen.ById.X85150b117366d14b.get_Calculator'defFunction'params'paramCount raw) <*>
            (Capnp.Gen.ById.X85150b117366d14b.get_Calculator'defFunction'params'body raw >>= C'.decerialize)
instance C'.Marshal Calculator'defFunction'params where
    marshalInto raw value = do
        case value of
            Calculator'defFunction'params{..} -> do
                Capnp.Gen.ById.X85150b117366d14b.set_Calculator'defFunction'params'paramCount raw paramCount
                field_ <- Capnp.Gen.ById.X85150b117366d14b.new_Calculator'defFunction'params'body raw
                C'.marshalInto field_ body
instance C'.Cerialize Calculator'defFunction'params
instance C'.FromStruct M'.ConstMsg Calculator'defFunction'params where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.Gen.ById.X85150b117366d14b.Calculator'defFunction'params M'.ConstMsg)
instance Default Calculator'defFunction'params where
    def = PH'.defaultStruct
data Calculator'defFunction'results
    = Calculator'defFunction'results
        {func :: Function}
    deriving(Show,Eq,Generic)
instance C'.Decerialize Calculator'defFunction'results where
    type Cerial msg Calculator'defFunction'results = Capnp.Gen.ById.X85150b117366d14b.Calculator'defFunction'results msg
    decerialize raw = do
        Calculator'defFunction'results <$>
            (Capnp.Gen.ById.X85150b117366d14b.get_Calculator'defFunction'results'func raw >>= C'.decerialize)
instance C'.Marshal Calculator'defFunction'results where
    marshalInto raw value = do
        case value of
            Calculator'defFunction'results{..} -> do
                field_ <- C'.cerialize (U'.message raw) func
                Capnp.Gen.ById.X85150b117366d14b.set_Calculator'defFunction'results'func raw field_
instance C'.Cerialize Calculator'defFunction'results
instance C'.FromStruct M'.ConstMsg Calculator'defFunction'results where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.Gen.ById.X85150b117366d14b.Calculator'defFunction'results M'.ConstMsg)
instance Default Calculator'defFunction'results where
    def = PH'.defaultStruct
data Calculator'evaluate'params
    = Calculator'evaluate'params
        {expression :: Expression}
    deriving(Show,Eq,Generic)
instance C'.Decerialize Calculator'evaluate'params where
    type Cerial msg Calculator'evaluate'params = Capnp.Gen.ById.X85150b117366d14b.Calculator'evaluate'params msg
    decerialize raw = do
        Calculator'evaluate'params <$>
            (Capnp.Gen.ById.X85150b117366d14b.get_Calculator'evaluate'params'expression raw >>= C'.decerialize)
instance C'.Marshal Calculator'evaluate'params where
    marshalInto raw value = do
        case value of
            Calculator'evaluate'params{..} -> do
                field_ <- Capnp.Gen.ById.X85150b117366d14b.new_Calculator'evaluate'params'expression raw
                C'.marshalInto field_ expression
instance C'.Cerialize Calculator'evaluate'params
instance C'.FromStruct M'.ConstMsg Calculator'evaluate'params where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.Gen.ById.X85150b117366d14b.Calculator'evaluate'params M'.ConstMsg)
instance Default Calculator'evaluate'params where
    def = PH'.defaultStruct
data Calculator'evaluate'results
    = Calculator'evaluate'results
        {value :: Value}
    deriving(Show,Eq,Generic)
instance C'.Decerialize Calculator'evaluate'results where
    type Cerial msg Calculator'evaluate'results = Capnp.Gen.ById.X85150b117366d14b.Calculator'evaluate'results msg
    decerialize raw = do
        Calculator'evaluate'results <$>
            (Capnp.Gen.ById.X85150b117366d14b.get_Calculator'evaluate'results'value raw >>= C'.decerialize)
instance C'.Marshal Calculator'evaluate'results where
    marshalInto raw value = do
        case value of
            Calculator'evaluate'results{..} -> do
                field_ <- C'.cerialize (U'.message raw) value
                Capnp.Gen.ById.X85150b117366d14b.set_Calculator'evaluate'results'value raw field_
instance C'.Cerialize Calculator'evaluate'results
instance C'.FromStruct M'.ConstMsg Calculator'evaluate'results where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.Gen.ById.X85150b117366d14b.Calculator'evaluate'results M'.ConstMsg)
instance Default Calculator'evaluate'results where
    def = PH'.defaultStruct
data Calculator'getOperator'params
    = Calculator'getOperator'params
        {op :: Capnp.Gen.ById.X85150b117366d14b.Operator}
    deriving(Show,Eq,Generic)
instance C'.Decerialize Calculator'getOperator'params where
    type Cerial msg Calculator'getOperator'params = Capnp.Gen.ById.X85150b117366d14b.Calculator'getOperator'params msg
    decerialize raw = do
        Calculator'getOperator'params <$>
            (Capnp.Gen.ById.X85150b117366d14b.get_Calculator'getOperator'params'op raw)
instance C'.Marshal Calculator'getOperator'params where
    marshalInto raw value = do
        case value of
            Calculator'getOperator'params{..} -> do
                Capnp.Gen.ById.X85150b117366d14b.set_Calculator'getOperator'params'op raw op
instance C'.Cerialize Calculator'getOperator'params
instance C'.FromStruct M'.ConstMsg Calculator'getOperator'params where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.Gen.ById.X85150b117366d14b.Calculator'getOperator'params M'.ConstMsg)
instance Default Calculator'getOperator'params where
    def = PH'.defaultStruct
data Calculator'getOperator'results
    = Calculator'getOperator'results
        {func :: Function}
    deriving(Show,Eq,Generic)
instance C'.Decerialize Calculator'getOperator'results where
    type Cerial msg Calculator'getOperator'results = Capnp.Gen.ById.X85150b117366d14b.Calculator'getOperator'results msg
    decerialize raw = do
        Calculator'getOperator'results <$>
            (Capnp.Gen.ById.X85150b117366d14b.get_Calculator'getOperator'results'func raw >>= C'.decerialize)
instance C'.Marshal Calculator'getOperator'results where
    marshalInto raw value = do
        case value of
            Calculator'getOperator'results{..} -> do
                field_ <- C'.cerialize (U'.message raw) func
                Capnp.Gen.ById.X85150b117366d14b.set_Calculator'getOperator'results'func raw field_
instance C'.Cerialize Calculator'getOperator'results
instance C'.FromStruct M'.ConstMsg Calculator'getOperator'results where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.Gen.ById.X85150b117366d14b.Calculator'getOperator'results M'.ConstMsg)
instance Default Calculator'getOperator'results where
    def = PH'.defaultStruct
data Function'call'params
    = Function'call'params
        {params :: PU'.ListOf (Double)}
    deriving(Show,Eq,Generic)
instance C'.Decerialize Function'call'params where
    type Cerial msg Function'call'params = Capnp.Gen.ById.X85150b117366d14b.Function'call'params msg
    decerialize raw = do
        Function'call'params <$>
            (Capnp.Gen.ById.X85150b117366d14b.get_Function'call'params'params raw >>= C'.decerialize)
instance C'.Marshal Function'call'params where
    marshalInto raw value = do
        case value of
            Function'call'params{..} -> do
                let len_ = V.length params
                field_ <- Capnp.Gen.ById.X85150b117366d14b.new_Function'call'params'params len_ raw
                forM_ [0..len_ - 1] $ \i -> do
                    C'.setIndex (params V.! i) i field_
instance C'.Cerialize Function'call'params
instance C'.FromStruct M'.ConstMsg Function'call'params where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.Gen.ById.X85150b117366d14b.Function'call'params M'.ConstMsg)
instance Default Function'call'params where
    def = PH'.defaultStruct
data Function'call'results
    = Function'call'results
        {value :: Double}
    deriving(Show,Eq,Generic)
instance C'.Decerialize Function'call'results where
    type Cerial msg Function'call'results = Capnp.Gen.ById.X85150b117366d14b.Function'call'results msg
    decerialize raw = do
        Function'call'results <$>
            (Capnp.Gen.ById.X85150b117366d14b.get_Function'call'results'value raw)
instance C'.Marshal Function'call'results where
    marshalInto raw value = do
        case value of
            Function'call'results{..} -> do
                Capnp.Gen.ById.X85150b117366d14b.set_Function'call'results'value raw value
instance C'.Cerialize Function'call'results
instance C'.FromStruct M'.ConstMsg Function'call'results where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.Gen.ById.X85150b117366d14b.Function'call'results M'.ConstMsg)
instance Default Function'call'results where
    def = PH'.defaultStruct
data Value'read'params
    = Value'read'params
    deriving(Show,Eq,Generic)
instance C'.Decerialize Value'read'params where
    type Cerial msg Value'read'params = Capnp.Gen.ById.X85150b117366d14b.Value'read'params msg
    decerialize raw = do
        pure $ Value'read'params
instance C'.Marshal Value'read'params where
    marshalInto raw value = do
        case value of
            Value'read'params -> pure ()
instance C'.Cerialize Value'read'params
instance C'.FromStruct M'.ConstMsg Value'read'params where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.Gen.ById.X85150b117366d14b.Value'read'params M'.ConstMsg)
instance Default Value'read'params where
    def = PH'.defaultStruct
data Value'read'results
    = Value'read'results
        {value :: Double}
    deriving(Show,Eq,Generic)
instance C'.Decerialize Value'read'results where
    type Cerial msg Value'read'results = Capnp.Gen.ById.X85150b117366d14b.Value'read'results msg
    decerialize raw = do
        Value'read'results <$>
            (Capnp.Gen.ById.X85150b117366d14b.get_Value'read'results'value raw)
instance C'.Marshal Value'read'results where
    marshalInto raw value = do
        case value of
            Value'read'results{..} -> do
                Capnp.Gen.ById.X85150b117366d14b.set_Value'read'results'value raw value
instance C'.Cerialize Value'read'results
instance C'.FromStruct M'.ConstMsg Value'read'results where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.Gen.ById.X85150b117366d14b.Value'read'results M'.ConstMsg)
instance Default Value'read'results where
    def = PH'.defaultStruct