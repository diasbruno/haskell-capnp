{-# LANGUAGE DataKinds        #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies     #-}
{-|
Module: Capnp.Convert
Description: Convert between messages, typed capnproto values, and (lazy)bytestring(builders).

This module provides various helper functions to convert between messages, types defined
in capnproto schema (called "values" in the rest of this module's documentation),
bytestrings (both lazy and strict), and bytestring builders.

Note that most of the functions which decode messages or raw bytes do *not* need to be
run inside of an instance of 'MonadLimit'; they choose an appropriate limit based on the
size of the input.

Note that not all conversions exist or necessarily make sense.
-}
module Capnp.Convert
    ( msgToBuilder
    , msgToLBS
    , msgToBS
    , msgToValue
    , bsToMsg
    , bsToValue
    , lbsToMsg
    , lbsToValue
    , valueToBuilder
    , valueToBS
    , valueToLBS
    , valueToMsg
    ) where

import Control.Monad       ((>=>))
import Control.Monad.Catch (MonadThrow)
import Data.Foldable       (foldlM)

import qualified Data.ByteString         as BS
import qualified Data.ByteString.Builder as BB
import qualified Data.ByteString.Lazy    as LBS

import Capnp.Classes

import Capnp.Bits           (WordCount)
import Capnp.Message        (Mutability (..))
import Capnp.TraversalLimit (LimitT, MonadLimit, evalLimitT)
import Codec.Capnp          (getRoot, setRoot)
import Data.Mutable         (freeze)

import qualified Capnp.Message as M

-- | Compute a reasonable limit based on the size of a message. The limit
-- is the total number of words in all of the message's segments, multiplied
-- by 10 to provide some slack for decoding default values.
limitFromMsg :: (MonadThrow m, M.MonadReadMessage mut m) => M.Message mut -> m WordCount
limitFromMsg msg = do
    messageWords <- countMessageWords
    pure (messageWords * 10)
  where
    countMessageWords = do
        segCount <- M.numSegs msg
        foldlM
            (\total i -> do
                words <- M.getSegment msg i >>= M.numWords
                pure (words + total)
            )
            0
            [0..segCount - 1]

-- | Convert an immutable message to a bytestring 'BB.Builder'.
-- To convert a mutable message, 'freeze' it first.
msgToBuilder :: M.Message 'Const -> BB.Builder
msgToBuilder = M.encode

-- | Convert an immutable message to a lazy 'LBS.ByteString'.
-- To convert a mutable message, 'freeze' it first.
msgToLBS :: M.Message 'Const -> LBS.ByteString
msgToLBS = BB.toLazyByteString . msgToBuilder

-- | Convert an immutable message to a strict 'BS.ByteString'.
-- To convert a mutable message, 'freeze' it first.
msgToBS :: M.Message 'Const -> BS.ByteString
msgToBS = LBS.toStrict . msgToLBS

-- | Convert a message to a value.
msgToValue :: (MonadThrow m, M.MonadReadMessage mut (LimitT m), M.MonadReadMessage mut m, FromStruct mut a) => M.Message mut -> m a
msgToValue msg = do
    limit <- limitFromMsg msg
    evalLimitT limit (getRoot msg)

-- | Convert a strict 'BS.ByteString' to a message.
bsToMsg :: MonadThrow m => BS.ByteString -> m (M.Message 'Const)
bsToMsg = M.decode

-- | Convert a strict 'BS.ByteString' to a value.
bsToValue :: (MonadThrow m, FromStruct 'Const a) => BS.ByteString -> m a
bsToValue = bsToMsg >=> msgToValue

-- | Convert a lazy 'LBS.ByteString' to a message.
lbsToMsg :: MonadThrow m => LBS.ByteString -> m (M.Message 'Const)
lbsToMsg = bsToMsg . LBS.toStrict

-- | Convert a lazy 'LBS.ByteString' to a value.
lbsToValue :: (MonadThrow m, FromStruct 'Const a) => LBS.ByteString -> m a
lbsToValue = bsToValue . LBS.toStrict

-- | Convert a value to a 'BS.Builder'.
valueToBuilder :: (MonadLimit m, M.WriteCtx m s, Cerialize s a, ToStruct ('Mut s) (Cerial ('Mut s) a)) => a -> m BB.Builder
valueToBuilder val = msgToBuilder <$> (valueToMsg val >>= freeze)

-- | Convert a value to a strict 'BS.ByteString'.
valueToBS :: (MonadLimit m, M.WriteCtx m s, Cerialize s a, ToStruct ('Mut s) (Cerial ('Mut s) a)) => a -> m BS.ByteString
valueToBS = fmap LBS.toStrict . valueToLBS

-- | Convert a value to a lazy 'LBS.ByteString'.
valueToLBS :: (MonadLimit m, M.WriteCtx m s, Cerialize s a, ToStruct ('Mut s) (Cerial ('Mut s) a)) => a -> m LBS.ByteString
valueToLBS = fmap BB.toLazyByteString . valueToBuilder

-- | Convert a value to a message.
valueToMsg :: (MonadLimit m, M.WriteCtx m s, Cerialize s a, ToStruct ('Mut s) (Cerial ('Mut s) a)) => a -> m (M.Message ('Mut s))
valueToMsg val = do
    msg <- M.newMessage Nothing
    ret <- cerialize msg val
    setRoot ret
    pure msg
