{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE EmptyDataDeriving #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}
{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-unused-matches #-}
{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unticked-promoted-constructors #-}
{-# OPTIONS_GHC -Wno-name-shadowing #-}
module Capnp.Gen.Capnp.Rpc.New where
import qualified Capnp.Repr as R
import qualified Capnp.Repr.Parsed as RP
import qualified Capnp.New.Basics as Basics
import qualified GHC.OverloadedLabels as OL
import qualified Capnp.GenHelpers.New as GH
import qualified Capnp.New.Classes as C
import qualified GHC.Generics as Generics
import qualified Prelude as Std_
import qualified Data.Word as Std_
import qualified Data.Int as Std_
import Prelude ((<$>), (<*>), (>>=))
data Message 
type instance (R.ReprFor Message) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct Message) where
    numStructWords  = 1
    numStructPtrs  = 1
instance (C.Allocate Message) where
    type AllocHint Message = ()
    new  = GH.newStruct
data instance C.Parsed Message
    = Message 
        {union' :: (C.Parsed (GH.Which Message))}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed Message))
deriving instance (Std_.Eq (C.Parsed Message))
instance (GH.HasUnion Message) where
    unionField  = (GH.dataField 0 0 16 0)
    data RawWhich mut_ Message
        = RW_Message'unimplemented (R.Raw mut_ Message)
        | RW_Message'abort (R.Raw mut_ Exception)
        | RW_Message'call (R.Raw mut_ Call)
        | RW_Message'return (R.Raw mut_ Return)
        | RW_Message'finish (R.Raw mut_ Finish)
        | RW_Message'resolve (R.Raw mut_ Resolve)
        | RW_Message'release (R.Raw mut_ Release)
        | RW_Message'obsoleteSave (R.Raw mut_ Basics.AnyPointer)
        | RW_Message'bootstrap (R.Raw mut_ Bootstrap)
        | RW_Message'obsoleteDelete (R.Raw mut_ Basics.AnyPointer)
        | RW_Message'provide (R.Raw mut_ Provide)
        | RW_Message'accept (R.Raw mut_ Accept)
        | RW_Message'join (R.Raw mut_ Join)
        | RW_Message'disembargo (R.Raw mut_ Disembargo)
        | RW_Message'unknown' Std_.Word16
    internalWhich tag_ struct_ = case tag_ of
        0 ->
            (RW_Message'unimplemented <$> (GH.readVariant #unimplemented struct_))
        1 ->
            (RW_Message'abort <$> (GH.readVariant #abort struct_))
        2 ->
            (RW_Message'call <$> (GH.readVariant #call struct_))
        3 ->
            (RW_Message'return <$> (GH.readVariant #return struct_))
        4 ->
            (RW_Message'finish <$> (GH.readVariant #finish struct_))
        5 ->
            (RW_Message'resolve <$> (GH.readVariant #resolve struct_))
        6 ->
            (RW_Message'release <$> (GH.readVariant #release struct_))
        7 ->
            (RW_Message'obsoleteSave <$> (GH.readVariant #obsoleteSave struct_))
        8 ->
            (RW_Message'bootstrap <$> (GH.readVariant #bootstrap struct_))
        9 ->
            (RW_Message'obsoleteDelete <$> (GH.readVariant #obsoleteDelete struct_))
        10 ->
            (RW_Message'provide <$> (GH.readVariant #provide struct_))
        11 ->
            (RW_Message'accept <$> (GH.readVariant #accept struct_))
        12 ->
            (RW_Message'join <$> (GH.readVariant #join struct_))
        13 ->
            (RW_Message'disembargo <$> (GH.readVariant #disembargo struct_))
        _ ->
            (Std_.pure (RW_Message'unknown' tag_))
    data Which Message
instance (GH.HasVariant "unimplemented" GH.Slot Message Message) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 0)
instance (GH.HasVariant "abort" GH.Slot Message Exception) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 1)
instance (GH.HasVariant "call" GH.Slot Message Call) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 2)
instance (GH.HasVariant "return" GH.Slot Message Return) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 3)
instance (GH.HasVariant "finish" GH.Slot Message Finish) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 4)
instance (GH.HasVariant "resolve" GH.Slot Message Resolve) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 5)
instance (GH.HasVariant "release" GH.Slot Message Release) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 6)
instance (GH.HasVariant "obsoleteSave" GH.Slot Message Basics.AnyPointer) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 7)
instance (GH.HasVariant "bootstrap" GH.Slot Message Bootstrap) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 8)
instance (GH.HasVariant "obsoleteDelete" GH.Slot Message Basics.AnyPointer) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 9)
instance (GH.HasVariant "provide" GH.Slot Message Provide) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 10)
instance (GH.HasVariant "accept" GH.Slot Message Accept) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 11)
instance (GH.HasVariant "join" GH.Slot Message Join) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 12)
instance (GH.HasVariant "disembargo" GH.Slot Message Disembargo) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 13)
data instance C.Parsed (GH.Which Message)
    = Message'unimplemented (RP.Parsed Message)
    | Message'abort (RP.Parsed Exception)
    | Message'call (RP.Parsed Call)
    | Message'return (RP.Parsed Return)
    | Message'finish (RP.Parsed Finish)
    | Message'resolve (RP.Parsed Resolve)
    | Message'release (RP.Parsed Release)
    | Message'obsoleteSave (RP.Parsed Basics.AnyPointer)
    | Message'bootstrap (RP.Parsed Bootstrap)
    | Message'obsoleteDelete (RP.Parsed Basics.AnyPointer)
    | Message'provide (RP.Parsed Provide)
    | Message'accept (RP.Parsed Accept)
    | Message'join (RP.Parsed Join)
    | Message'disembargo (RP.Parsed Disembargo)
    | Message'unknown' Std_.Word16
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed (GH.Which Message)))
deriving instance (Std_.Eq (C.Parsed (GH.Which Message)))
data Bootstrap 
type instance (R.ReprFor Bootstrap) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct Bootstrap) where
    numStructWords  = 1
    numStructPtrs  = 1
instance (C.Allocate Bootstrap) where
    type AllocHint Bootstrap = ()
    new  = GH.newStruct
data instance C.Parsed Bootstrap
    = Bootstrap 
        {questionId :: (RP.Parsed Std_.Word32)
        ,deprecatedObjectId :: (RP.Parsed Basics.AnyPointer)}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed Bootstrap))
deriving instance (Std_.Eq (C.Parsed Bootstrap))
instance (GH.HasField "questionId" GH.Slot Bootstrap Std_.Word32) where
    fieldByLabel  = (GH.dataField 0 0 32 0)
instance (GH.HasField "deprecatedObjectId" GH.Slot Bootstrap Basics.AnyPointer) where
    fieldByLabel  = (GH.ptrField 0)
data Call 
type instance (R.ReprFor Call) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct Call) where
    numStructWords  = 3
    numStructPtrs  = 3
instance (C.Allocate Call) where
    type AllocHint Call = ()
    new  = GH.newStruct
data instance C.Parsed Call
    = Call 
        {questionId :: (RP.Parsed Std_.Word32)
        ,target :: (RP.Parsed MessageTarget)
        ,interfaceId :: (RP.Parsed Std_.Word64)
        ,methodId :: (RP.Parsed Std_.Word16)
        ,params :: (RP.Parsed Payload)
        ,sendResultsTo :: (RP.Parsed Call'sendResultsTo)
        ,allowThirdPartyTailCall :: (RP.Parsed Std_.Bool)}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed Call))
deriving instance (Std_.Eq (C.Parsed Call))
instance (GH.HasField "questionId" GH.Slot Call Std_.Word32) where
    fieldByLabel  = (GH.dataField 0 0 32 0)
instance (GH.HasField "target" GH.Slot Call MessageTarget) where
    fieldByLabel  = (GH.ptrField 0)
instance (GH.HasField "interfaceId" GH.Slot Call Std_.Word64) where
    fieldByLabel  = (GH.dataField 0 1 64 0)
instance (GH.HasField "methodId" GH.Slot Call Std_.Word16) where
    fieldByLabel  = (GH.dataField 32 0 16 0)
instance (GH.HasField "params" GH.Slot Call Payload) where
    fieldByLabel  = (GH.ptrField 1)
instance (GH.HasField "sendResultsTo" GH.Group Call Call'sendResultsTo) where
    fieldByLabel  = GH.groupField
instance (GH.HasField "allowThirdPartyTailCall" GH.Slot Call Std_.Bool) where
    fieldByLabel  = (GH.dataField 0 2 1 0)
data Call'sendResultsTo 
type instance (R.ReprFor Call'sendResultsTo) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct Call'sendResultsTo) where
    numStructWords  = 3
    numStructPtrs  = 3
instance (C.Allocate Call'sendResultsTo) where
    type AllocHint Call'sendResultsTo = ()
    new  = GH.newStruct
data instance C.Parsed Call'sendResultsTo
    = Call'sendResultsTo' 
        {union' :: (C.Parsed (GH.Which Call'sendResultsTo))}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed Call'sendResultsTo))
deriving instance (Std_.Eq (C.Parsed Call'sendResultsTo))
instance (GH.HasUnion Call'sendResultsTo) where
    unionField  = (GH.dataField 48 0 16 0)
    data RawWhich mut_ Call'sendResultsTo
        = RW_Call'sendResultsTo'caller (R.Raw mut_ ())
        | RW_Call'sendResultsTo'yourself (R.Raw mut_ ())
        | RW_Call'sendResultsTo'thirdParty (R.Raw mut_ Basics.AnyPointer)
        | RW_Call'sendResultsTo'unknown' Std_.Word16
    internalWhich tag_ struct_ = case tag_ of
        0 ->
            (RW_Call'sendResultsTo'caller <$> (GH.readVariant #caller struct_))
        1 ->
            (RW_Call'sendResultsTo'yourself <$> (GH.readVariant #yourself struct_))
        2 ->
            (RW_Call'sendResultsTo'thirdParty <$> (GH.readVariant #thirdParty struct_))
        _ ->
            (Std_.pure (RW_Call'sendResultsTo'unknown' tag_))
    data Which Call'sendResultsTo
instance (GH.HasVariant "caller" GH.Slot Call'sendResultsTo ()) where
    variantByLabel  = (GH.Variant GH.voidField 0)
instance (GH.HasVariant "yourself" GH.Slot Call'sendResultsTo ()) where
    variantByLabel  = (GH.Variant GH.voidField 1)
instance (GH.HasVariant "thirdParty" GH.Slot Call'sendResultsTo Basics.AnyPointer) where
    variantByLabel  = (GH.Variant (GH.ptrField 2) 2)
data instance C.Parsed (GH.Which Call'sendResultsTo)
    = Call'sendResultsTo'caller 
    | Call'sendResultsTo'yourself 
    | Call'sendResultsTo'thirdParty (RP.Parsed Basics.AnyPointer)
    | Call'sendResultsTo'unknown' Std_.Word16
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed (GH.Which Call'sendResultsTo)))
deriving instance (Std_.Eq (C.Parsed (GH.Which Call'sendResultsTo)))
data Return 
type instance (R.ReprFor Return) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct Return) where
    numStructWords  = 2
    numStructPtrs  = 1
instance (C.Allocate Return) where
    type AllocHint Return = ()
    new  = GH.newStruct
data instance C.Parsed Return
    = Return 
        {answerId :: (RP.Parsed Std_.Word32)
        ,releaseParamCaps :: (RP.Parsed Std_.Bool)
        ,union' :: (C.Parsed (GH.Which Return))}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed Return))
deriving instance (Std_.Eq (C.Parsed Return))
instance (GH.HasUnion Return) where
    unionField  = (GH.dataField 48 0 16 0)
    data RawWhich mut_ Return
        = RW_Return'results (R.Raw mut_ Payload)
        | RW_Return'exception (R.Raw mut_ Exception)
        | RW_Return'canceled (R.Raw mut_ ())
        | RW_Return'resultsSentElsewhere (R.Raw mut_ ())
        | RW_Return'takeFromOtherQuestion (R.Raw mut_ Std_.Word32)
        | RW_Return'acceptFromThirdParty (R.Raw mut_ Basics.AnyPointer)
        | RW_Return'unknown' Std_.Word16
    internalWhich tag_ struct_ = case tag_ of
        0 ->
            (RW_Return'results <$> (GH.readVariant #results struct_))
        1 ->
            (RW_Return'exception <$> (GH.readVariant #exception struct_))
        2 ->
            (RW_Return'canceled <$> (GH.readVariant #canceled struct_))
        3 ->
            (RW_Return'resultsSentElsewhere <$> (GH.readVariant #resultsSentElsewhere struct_))
        4 ->
            (RW_Return'takeFromOtherQuestion <$> (GH.readVariant #takeFromOtherQuestion struct_))
        5 ->
            (RW_Return'acceptFromThirdParty <$> (GH.readVariant #acceptFromThirdParty struct_))
        _ ->
            (Std_.pure (RW_Return'unknown' tag_))
    data Which Return
instance (GH.HasVariant "results" GH.Slot Return Payload) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 0)
instance (GH.HasVariant "exception" GH.Slot Return Exception) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 1)
instance (GH.HasVariant "canceled" GH.Slot Return ()) where
    variantByLabel  = (GH.Variant GH.voidField 2)
instance (GH.HasVariant "resultsSentElsewhere" GH.Slot Return ()) where
    variantByLabel  = (GH.Variant GH.voidField 3)
instance (GH.HasVariant "takeFromOtherQuestion" GH.Slot Return Std_.Word32) where
    variantByLabel  = (GH.Variant (GH.dataField 0 1 32 0) 4)
instance (GH.HasVariant "acceptFromThirdParty" GH.Slot Return Basics.AnyPointer) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 5)
data instance C.Parsed (GH.Which Return)
    = Return'results (RP.Parsed Payload)
    | Return'exception (RP.Parsed Exception)
    | Return'canceled 
    | Return'resultsSentElsewhere 
    | Return'takeFromOtherQuestion (RP.Parsed Std_.Word32)
    | Return'acceptFromThirdParty (RP.Parsed Basics.AnyPointer)
    | Return'unknown' Std_.Word16
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed (GH.Which Return)))
deriving instance (Std_.Eq (C.Parsed (GH.Which Return)))
instance (GH.HasField "answerId" GH.Slot Return Std_.Word32) where
    fieldByLabel  = (GH.dataField 0 0 32 0)
instance (GH.HasField "releaseParamCaps" GH.Slot Return Std_.Bool) where
    fieldByLabel  = (GH.dataField 32 0 1 1)
data Finish 
type instance (R.ReprFor Finish) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct Finish) where
    numStructWords  = 1
    numStructPtrs  = 0
instance (C.Allocate Finish) where
    type AllocHint Finish = ()
    new  = GH.newStruct
data instance C.Parsed Finish
    = Finish 
        {questionId :: (RP.Parsed Std_.Word32)
        ,releaseResultCaps :: (RP.Parsed Std_.Bool)}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed Finish))
deriving instance (Std_.Eq (C.Parsed Finish))
instance (GH.HasField "questionId" GH.Slot Finish Std_.Word32) where
    fieldByLabel  = (GH.dataField 0 0 32 0)
instance (GH.HasField "releaseResultCaps" GH.Slot Finish Std_.Bool) where
    fieldByLabel  = (GH.dataField 32 0 1 1)
data Resolve 
type instance (R.ReprFor Resolve) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct Resolve) where
    numStructWords  = 1
    numStructPtrs  = 1
instance (C.Allocate Resolve) where
    type AllocHint Resolve = ()
    new  = GH.newStruct
data instance C.Parsed Resolve
    = Resolve 
        {promiseId :: (RP.Parsed Std_.Word32)
        ,union' :: (C.Parsed (GH.Which Resolve))}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed Resolve))
deriving instance (Std_.Eq (C.Parsed Resolve))
instance (GH.HasUnion Resolve) where
    unionField  = (GH.dataField 32 0 16 0)
    data RawWhich mut_ Resolve
        = RW_Resolve'cap (R.Raw mut_ CapDescriptor)
        | RW_Resolve'exception (R.Raw mut_ Exception)
        | RW_Resolve'unknown' Std_.Word16
    internalWhich tag_ struct_ = case tag_ of
        0 ->
            (RW_Resolve'cap <$> (GH.readVariant #cap struct_))
        1 ->
            (RW_Resolve'exception <$> (GH.readVariant #exception struct_))
        _ ->
            (Std_.pure (RW_Resolve'unknown' tag_))
    data Which Resolve
instance (GH.HasVariant "cap" GH.Slot Resolve CapDescriptor) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 0)
instance (GH.HasVariant "exception" GH.Slot Resolve Exception) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 1)
data instance C.Parsed (GH.Which Resolve)
    = Resolve'cap (RP.Parsed CapDescriptor)
    | Resolve'exception (RP.Parsed Exception)
    | Resolve'unknown' Std_.Word16
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed (GH.Which Resolve)))
deriving instance (Std_.Eq (C.Parsed (GH.Which Resolve)))
instance (GH.HasField "promiseId" GH.Slot Resolve Std_.Word32) where
    fieldByLabel  = (GH.dataField 0 0 32 0)
data Release 
type instance (R.ReprFor Release) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct Release) where
    numStructWords  = 1
    numStructPtrs  = 0
instance (C.Allocate Release) where
    type AllocHint Release = ()
    new  = GH.newStruct
data instance C.Parsed Release
    = Release 
        {id :: (RP.Parsed Std_.Word32)
        ,referenceCount :: (RP.Parsed Std_.Word32)}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed Release))
deriving instance (Std_.Eq (C.Parsed Release))
instance (GH.HasField "id" GH.Slot Release Std_.Word32) where
    fieldByLabel  = (GH.dataField 0 0 32 0)
instance (GH.HasField "referenceCount" GH.Slot Release Std_.Word32) where
    fieldByLabel  = (GH.dataField 32 0 32 0)
data Disembargo 
type instance (R.ReprFor Disembargo) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct Disembargo) where
    numStructWords  = 1
    numStructPtrs  = 1
instance (C.Allocate Disembargo) where
    type AllocHint Disembargo = ()
    new  = GH.newStruct
data instance C.Parsed Disembargo
    = Disembargo 
        {target :: (RP.Parsed MessageTarget)
        ,context :: (RP.Parsed Disembargo'context)}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed Disembargo))
deriving instance (Std_.Eq (C.Parsed Disembargo))
instance (GH.HasField "target" GH.Slot Disembargo MessageTarget) where
    fieldByLabel  = (GH.ptrField 0)
instance (GH.HasField "context" GH.Group Disembargo Disembargo'context) where
    fieldByLabel  = GH.groupField
data Disembargo'context 
type instance (R.ReprFor Disembargo'context) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct Disembargo'context) where
    numStructWords  = 1
    numStructPtrs  = 1
instance (C.Allocate Disembargo'context) where
    type AllocHint Disembargo'context = ()
    new  = GH.newStruct
data instance C.Parsed Disembargo'context
    = Disembargo'context' 
        {union' :: (C.Parsed (GH.Which Disembargo'context))}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed Disembargo'context))
deriving instance (Std_.Eq (C.Parsed Disembargo'context))
instance (GH.HasUnion Disembargo'context) where
    unionField  = (GH.dataField 32 0 16 0)
    data RawWhich mut_ Disembargo'context
        = RW_Disembargo'context'senderLoopback (R.Raw mut_ Std_.Word32)
        | RW_Disembargo'context'receiverLoopback (R.Raw mut_ Std_.Word32)
        | RW_Disembargo'context'accept (R.Raw mut_ ())
        | RW_Disembargo'context'provide (R.Raw mut_ Std_.Word32)
        | RW_Disembargo'context'unknown' Std_.Word16
    internalWhich tag_ struct_ = case tag_ of
        0 ->
            (RW_Disembargo'context'senderLoopback <$> (GH.readVariant #senderLoopback struct_))
        1 ->
            (RW_Disembargo'context'receiverLoopback <$> (GH.readVariant #receiverLoopback struct_))
        2 ->
            (RW_Disembargo'context'accept <$> (GH.readVariant #accept struct_))
        3 ->
            (RW_Disembargo'context'provide <$> (GH.readVariant #provide struct_))
        _ ->
            (Std_.pure (RW_Disembargo'context'unknown' tag_))
    data Which Disembargo'context
instance (GH.HasVariant "senderLoopback" GH.Slot Disembargo'context Std_.Word32) where
    variantByLabel  = (GH.Variant (GH.dataField 0 0 32 0) 0)
instance (GH.HasVariant "receiverLoopback" GH.Slot Disembargo'context Std_.Word32) where
    variantByLabel  = (GH.Variant (GH.dataField 0 0 32 0) 1)
instance (GH.HasVariant "accept" GH.Slot Disembargo'context ()) where
    variantByLabel  = (GH.Variant GH.voidField 2)
instance (GH.HasVariant "provide" GH.Slot Disembargo'context Std_.Word32) where
    variantByLabel  = (GH.Variant (GH.dataField 0 0 32 0) 3)
data instance C.Parsed (GH.Which Disembargo'context)
    = Disembargo'context'senderLoopback (RP.Parsed Std_.Word32)
    | Disembargo'context'receiverLoopback (RP.Parsed Std_.Word32)
    | Disembargo'context'accept 
    | Disembargo'context'provide (RP.Parsed Std_.Word32)
    | Disembargo'context'unknown' Std_.Word16
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed (GH.Which Disembargo'context)))
deriving instance (Std_.Eq (C.Parsed (GH.Which Disembargo'context)))
data Provide 
type instance (R.ReprFor Provide) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct Provide) where
    numStructWords  = 1
    numStructPtrs  = 2
instance (C.Allocate Provide) where
    type AllocHint Provide = ()
    new  = GH.newStruct
data instance C.Parsed Provide
    = Provide 
        {questionId :: (RP.Parsed Std_.Word32)
        ,target :: (RP.Parsed MessageTarget)
        ,recipient :: (RP.Parsed Basics.AnyPointer)}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed Provide))
deriving instance (Std_.Eq (C.Parsed Provide))
instance (GH.HasField "questionId" GH.Slot Provide Std_.Word32) where
    fieldByLabel  = (GH.dataField 0 0 32 0)
instance (GH.HasField "target" GH.Slot Provide MessageTarget) where
    fieldByLabel  = (GH.ptrField 0)
instance (GH.HasField "recipient" GH.Slot Provide Basics.AnyPointer) where
    fieldByLabel  = (GH.ptrField 1)
data Accept 
type instance (R.ReprFor Accept) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct Accept) where
    numStructWords  = 1
    numStructPtrs  = 1
instance (C.Allocate Accept) where
    type AllocHint Accept = ()
    new  = GH.newStruct
data instance C.Parsed Accept
    = Accept 
        {questionId :: (RP.Parsed Std_.Word32)
        ,provision :: (RP.Parsed Basics.AnyPointer)
        ,embargo :: (RP.Parsed Std_.Bool)}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed Accept))
deriving instance (Std_.Eq (C.Parsed Accept))
instance (GH.HasField "questionId" GH.Slot Accept Std_.Word32) where
    fieldByLabel  = (GH.dataField 0 0 32 0)
instance (GH.HasField "provision" GH.Slot Accept Basics.AnyPointer) where
    fieldByLabel  = (GH.ptrField 0)
instance (GH.HasField "embargo" GH.Slot Accept Std_.Bool) where
    fieldByLabel  = (GH.dataField 32 0 1 0)
data Join 
type instance (R.ReprFor Join) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct Join) where
    numStructWords  = 1
    numStructPtrs  = 2
instance (C.Allocate Join) where
    type AllocHint Join = ()
    new  = GH.newStruct
data instance C.Parsed Join
    = Join 
        {questionId :: (RP.Parsed Std_.Word32)
        ,target :: (RP.Parsed MessageTarget)
        ,keyPart :: (RP.Parsed Basics.AnyPointer)}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed Join))
deriving instance (Std_.Eq (C.Parsed Join))
instance (GH.HasField "questionId" GH.Slot Join Std_.Word32) where
    fieldByLabel  = (GH.dataField 0 0 32 0)
instance (GH.HasField "target" GH.Slot Join MessageTarget) where
    fieldByLabel  = (GH.ptrField 0)
instance (GH.HasField "keyPart" GH.Slot Join Basics.AnyPointer) where
    fieldByLabel  = (GH.ptrField 1)
data MessageTarget 
type instance (R.ReprFor MessageTarget) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct MessageTarget) where
    numStructWords  = 1
    numStructPtrs  = 1
instance (C.Allocate MessageTarget) where
    type AllocHint MessageTarget = ()
    new  = GH.newStruct
data instance C.Parsed MessageTarget
    = MessageTarget 
        {union' :: (C.Parsed (GH.Which MessageTarget))}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed MessageTarget))
deriving instance (Std_.Eq (C.Parsed MessageTarget))
instance (GH.HasUnion MessageTarget) where
    unionField  = (GH.dataField 32 0 16 0)
    data RawWhich mut_ MessageTarget
        = RW_MessageTarget'importedCap (R.Raw mut_ Std_.Word32)
        | RW_MessageTarget'promisedAnswer (R.Raw mut_ PromisedAnswer)
        | RW_MessageTarget'unknown' Std_.Word16
    internalWhich tag_ struct_ = case tag_ of
        0 ->
            (RW_MessageTarget'importedCap <$> (GH.readVariant #importedCap struct_))
        1 ->
            (RW_MessageTarget'promisedAnswer <$> (GH.readVariant #promisedAnswer struct_))
        _ ->
            (Std_.pure (RW_MessageTarget'unknown' tag_))
    data Which MessageTarget
instance (GH.HasVariant "importedCap" GH.Slot MessageTarget Std_.Word32) where
    variantByLabel  = (GH.Variant (GH.dataField 0 0 32 0) 0)
instance (GH.HasVariant "promisedAnswer" GH.Slot MessageTarget PromisedAnswer) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 1)
data instance C.Parsed (GH.Which MessageTarget)
    = MessageTarget'importedCap (RP.Parsed Std_.Word32)
    | MessageTarget'promisedAnswer (RP.Parsed PromisedAnswer)
    | MessageTarget'unknown' Std_.Word16
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed (GH.Which MessageTarget)))
deriving instance (Std_.Eq (C.Parsed (GH.Which MessageTarget)))
data Payload 
type instance (R.ReprFor Payload) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct Payload) where
    numStructWords  = 0
    numStructPtrs  = 2
instance (C.Allocate Payload) where
    type AllocHint Payload = ()
    new  = GH.newStruct
data instance C.Parsed Payload
    = Payload 
        {content :: (RP.Parsed Basics.AnyPointer)
        ,capTable :: (RP.Parsed (R.List CapDescriptor))}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed Payload))
deriving instance (Std_.Eq (C.Parsed Payload))
instance (GH.HasField "content" GH.Slot Payload Basics.AnyPointer) where
    fieldByLabel  = (GH.ptrField 0)
instance (GH.HasField "capTable" GH.Slot Payload (R.List CapDescriptor)) where
    fieldByLabel  = (GH.ptrField 1)
data CapDescriptor 
type instance (R.ReprFor CapDescriptor) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct CapDescriptor) where
    numStructWords  = 1
    numStructPtrs  = 1
instance (C.Allocate CapDescriptor) where
    type AllocHint CapDescriptor = ()
    new  = GH.newStruct
data instance C.Parsed CapDescriptor
    = CapDescriptor 
        {attachedFd :: (RP.Parsed Std_.Word8)
        ,union' :: (C.Parsed (GH.Which CapDescriptor))}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed CapDescriptor))
deriving instance (Std_.Eq (C.Parsed CapDescriptor))
instance (GH.HasUnion CapDescriptor) where
    unionField  = (GH.dataField 0 0 16 0)
    data RawWhich mut_ CapDescriptor
        = RW_CapDescriptor'none (R.Raw mut_ ())
        | RW_CapDescriptor'senderHosted (R.Raw mut_ Std_.Word32)
        | RW_CapDescriptor'senderPromise (R.Raw mut_ Std_.Word32)
        | RW_CapDescriptor'receiverHosted (R.Raw mut_ Std_.Word32)
        | RW_CapDescriptor'receiverAnswer (R.Raw mut_ PromisedAnswer)
        | RW_CapDescriptor'thirdPartyHosted (R.Raw mut_ ThirdPartyCapDescriptor)
        | RW_CapDescriptor'unknown' Std_.Word16
    internalWhich tag_ struct_ = case tag_ of
        0 ->
            (RW_CapDescriptor'none <$> (GH.readVariant #none struct_))
        1 ->
            (RW_CapDescriptor'senderHosted <$> (GH.readVariant #senderHosted struct_))
        2 ->
            (RW_CapDescriptor'senderPromise <$> (GH.readVariant #senderPromise struct_))
        3 ->
            (RW_CapDescriptor'receiverHosted <$> (GH.readVariant #receiverHosted struct_))
        4 ->
            (RW_CapDescriptor'receiverAnswer <$> (GH.readVariant #receiverAnswer struct_))
        5 ->
            (RW_CapDescriptor'thirdPartyHosted <$> (GH.readVariant #thirdPartyHosted struct_))
        _ ->
            (Std_.pure (RW_CapDescriptor'unknown' tag_))
    data Which CapDescriptor
instance (GH.HasVariant "none" GH.Slot CapDescriptor ()) where
    variantByLabel  = (GH.Variant GH.voidField 0)
instance (GH.HasVariant "senderHosted" GH.Slot CapDescriptor Std_.Word32) where
    variantByLabel  = (GH.Variant (GH.dataField 32 0 32 0) 1)
instance (GH.HasVariant "senderPromise" GH.Slot CapDescriptor Std_.Word32) where
    variantByLabel  = (GH.Variant (GH.dataField 32 0 32 0) 2)
instance (GH.HasVariant "receiverHosted" GH.Slot CapDescriptor Std_.Word32) where
    variantByLabel  = (GH.Variant (GH.dataField 32 0 32 0) 3)
instance (GH.HasVariant "receiverAnswer" GH.Slot CapDescriptor PromisedAnswer) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 4)
instance (GH.HasVariant "thirdPartyHosted" GH.Slot CapDescriptor ThirdPartyCapDescriptor) where
    variantByLabel  = (GH.Variant (GH.ptrField 0) 5)
data instance C.Parsed (GH.Which CapDescriptor)
    = CapDescriptor'none 
    | CapDescriptor'senderHosted (RP.Parsed Std_.Word32)
    | CapDescriptor'senderPromise (RP.Parsed Std_.Word32)
    | CapDescriptor'receiverHosted (RP.Parsed Std_.Word32)
    | CapDescriptor'receiverAnswer (RP.Parsed PromisedAnswer)
    | CapDescriptor'thirdPartyHosted (RP.Parsed ThirdPartyCapDescriptor)
    | CapDescriptor'unknown' Std_.Word16
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed (GH.Which CapDescriptor)))
deriving instance (Std_.Eq (C.Parsed (GH.Which CapDescriptor)))
instance (GH.HasField "attachedFd" GH.Slot CapDescriptor Std_.Word8) where
    fieldByLabel  = (GH.dataField 16 0 8 255)
data PromisedAnswer 
type instance (R.ReprFor PromisedAnswer) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct PromisedAnswer) where
    numStructWords  = 1
    numStructPtrs  = 1
instance (C.Allocate PromisedAnswer) where
    type AllocHint PromisedAnswer = ()
    new  = GH.newStruct
data instance C.Parsed PromisedAnswer
    = PromisedAnswer 
        {questionId :: (RP.Parsed Std_.Word32)
        ,transform :: (RP.Parsed (R.List PromisedAnswer'Op))}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed PromisedAnswer))
deriving instance (Std_.Eq (C.Parsed PromisedAnswer))
instance (GH.HasField "questionId" GH.Slot PromisedAnswer Std_.Word32) where
    fieldByLabel  = (GH.dataField 0 0 32 0)
instance (GH.HasField "transform" GH.Slot PromisedAnswer (R.List PromisedAnswer'Op)) where
    fieldByLabel  = (GH.ptrField 0)
data PromisedAnswer'Op 
type instance (R.ReprFor PromisedAnswer'Op) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct PromisedAnswer'Op) where
    numStructWords  = 1
    numStructPtrs  = 0
instance (C.Allocate PromisedAnswer'Op) where
    type AllocHint PromisedAnswer'Op = ()
    new  = GH.newStruct
data instance C.Parsed PromisedAnswer'Op
    = PromisedAnswer'Op 
        {union' :: (C.Parsed (GH.Which PromisedAnswer'Op))}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed PromisedAnswer'Op))
deriving instance (Std_.Eq (C.Parsed PromisedAnswer'Op))
instance (GH.HasUnion PromisedAnswer'Op) where
    unionField  = (GH.dataField 0 0 16 0)
    data RawWhich mut_ PromisedAnswer'Op
        = RW_PromisedAnswer'Op'noop (R.Raw mut_ ())
        | RW_PromisedAnswer'Op'getPointerField (R.Raw mut_ Std_.Word16)
        | RW_PromisedAnswer'Op'unknown' Std_.Word16
    internalWhich tag_ struct_ = case tag_ of
        0 ->
            (RW_PromisedAnswer'Op'noop <$> (GH.readVariant #noop struct_))
        1 ->
            (RW_PromisedAnswer'Op'getPointerField <$> (GH.readVariant #getPointerField struct_))
        _ ->
            (Std_.pure (RW_PromisedAnswer'Op'unknown' tag_))
    data Which PromisedAnswer'Op
instance (GH.HasVariant "noop" GH.Slot PromisedAnswer'Op ()) where
    variantByLabel  = (GH.Variant GH.voidField 0)
instance (GH.HasVariant "getPointerField" GH.Slot PromisedAnswer'Op Std_.Word16) where
    variantByLabel  = (GH.Variant (GH.dataField 16 0 16 0) 1)
data instance C.Parsed (GH.Which PromisedAnswer'Op)
    = PromisedAnswer'Op'noop 
    | PromisedAnswer'Op'getPointerField (RP.Parsed Std_.Word16)
    | PromisedAnswer'Op'unknown' Std_.Word16
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed (GH.Which PromisedAnswer'Op)))
deriving instance (Std_.Eq (C.Parsed (GH.Which PromisedAnswer'Op)))
data ThirdPartyCapDescriptor 
type instance (R.ReprFor ThirdPartyCapDescriptor) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct ThirdPartyCapDescriptor) where
    numStructWords  = 1
    numStructPtrs  = 1
instance (C.Allocate ThirdPartyCapDescriptor) where
    type AllocHint ThirdPartyCapDescriptor = ()
    new  = GH.newStruct
data instance C.Parsed ThirdPartyCapDescriptor
    = ThirdPartyCapDescriptor 
        {id :: (RP.Parsed Basics.AnyPointer)
        ,vineId :: (RP.Parsed Std_.Word32)}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed ThirdPartyCapDescriptor))
deriving instance (Std_.Eq (C.Parsed ThirdPartyCapDescriptor))
instance (GH.HasField "id" GH.Slot ThirdPartyCapDescriptor Basics.AnyPointer) where
    fieldByLabel  = (GH.ptrField 0)
instance (GH.HasField "vineId" GH.Slot ThirdPartyCapDescriptor Std_.Word32) where
    fieldByLabel  = (GH.dataField 0 0 32 0)
data Exception 
type instance (R.ReprFor Exception) = (R.Ptr (Std_.Just R.Struct))
instance (C.TypedStruct Exception) where
    numStructWords  = 1
    numStructPtrs  = 1
instance (C.Allocate Exception) where
    type AllocHint Exception = ()
    new  = GH.newStruct
data instance C.Parsed Exception
    = Exception 
        {reason :: (RP.Parsed Basics.Text)
        ,obsoleteIsCallersFault :: (RP.Parsed Std_.Bool)
        ,obsoleteDurability :: (RP.Parsed Std_.Word16)
        ,type_ :: (RP.Parsed Exception'Type)}
    deriving(Generics.Generic)
deriving instance (Std_.Show (C.Parsed Exception))
deriving instance (Std_.Eq (C.Parsed Exception))
instance (GH.HasField "reason" GH.Slot Exception Basics.Text) where
    fieldByLabel  = (GH.ptrField 0)
instance (GH.HasField "obsoleteIsCallersFault" GH.Slot Exception Std_.Bool) where
    fieldByLabel  = (GH.dataField 0 0 1 0)
instance (GH.HasField "obsoleteDurability" GH.Slot Exception Std_.Word16) where
    fieldByLabel  = (GH.dataField 16 0 16 0)
instance (GH.HasField "type_" GH.Slot Exception Exception'Type) where
    fieldByLabel  = (GH.dataField 32 0 16 0)
data Exception'Type 
    = Exception'Type'failed 
    | Exception'Type'overloaded 
    | Exception'Type'disconnected 
    | Exception'Type'unimplemented 
    | Exception'Type'unknown' Std_.Word16
    deriving(Std_.Eq,Std_.Show)
type instance (R.ReprFor Exception'Type) = (R.Data R.Sz16)