-- Data types that are used by more than one intermediate form.
-- See also IR.Name, which defines identifiers, which are also
-- used in more than one IR.
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE LambdaCase    #-}
module IR.Common where

import Data.Word

import qualified Capnp.Untyped.Pure as U

newtype TypeId = TypeId Word64
    deriving(Show, Read, Eq, Ord)

data IntType = IntType !Sign !IntSize
    deriving(Show, Read, Eq)

data Sign
    = Signed
    | Unsigned
    deriving(Show, Read, Eq)

data IntSize
    = Sz8
    | Sz16
    | Sz32
    | Sz64
    deriving(Show, Read, Eq)

sizeBits :: IntSize -> Int
sizeBits Sz8  = 8
sizeBits Sz16 = 16
sizeBits Sz32 = 32
sizeBits Sz64 = 64

-- | Return the size in bits of a type that belongs in the data section of a struct.
dataFieldSize :: WordType r -> Int
dataFieldSize = \case
    EnumType _                          -> 16
    PrimWord (PrimInt (IntType _ size)) -> sizeBits size
    PrimWord PrimFloat32                -> 32
    PrimWord PrimFloat64                -> 64
    PrimWord PrimBool                   -> 1

-- Capnproto types. The 'r' type parameter is the type of references to other nodes,
-- which may be different in different stages of the pipeline.

data Type r
    = CompositeType (CompositeType r)
    | VoidType
    | WordType (WordType r)
    | PtrType (PtrType r)
    deriving(Show, Read, Eq, Functor)

newtype CompositeType r
    = StructType r
    deriving(Show, Read, Eq, Functor)

data WordType r
    = EnumType r
    | PrimWord PrimWord
    deriving(Show, Read, Eq, Functor)

data PtrType r
    = ListOf (Type r)
    | PrimPtr PrimPtr
    | PtrComposite (CompositeType r)
    | PtrInterface r
    deriving(Show, Read, Eq, Functor)

data PrimWord
    = PrimInt IntType
    | PrimFloat32
    | PrimFloat64
    | PrimBool
    deriving(Show, Read, Eq)

data PrimPtr
    = PrimText
    | PrimData
    | PrimAnyPtr AnyPtr
    deriving(Show, Read, Eq)

data AnyPtr
    = Struct
    | List
    | Cap
    | Ptr
    deriving(Show, Read, Eq)

-- | The type and location of a field.
data FieldLocType r
    -- | The field is in the struct's data section.
    = DataField DataLoc (WordType r)
    -- | The field is in the struct's pointer section.
    | PtrField
        { ptrFieldIndex    :: !Word16 -- ^ Index into the pointer section
        , ptrFieldType     :: PtrType r -- ^ Type of the pointer
        , ptrFieldNullable :: !Bool -- ^ Whether null is meaningful
        }
    -- | The field is a group or union; it's "location" is the whole struct.
    | HereField (CompositeType r)
    -- | The field is of type void (and thus is zero-size).
    | VoidField
    deriving(Show, Read, Eq, Functor)

-- | The location of a field within a struct's data section.
data DataLoc = DataLoc
    { dataIdx :: !Int
    -- ^ The index of the 64-bit word containing the field.
    , dataOff :: !Int
    -- ^ The bit offset inside the 64-bit word.
    , dataDef :: !Word64
    -- ^ The value is stored xor-ed with this value. This is used
    -- to allow for encoding default values. Note that this is xor-ed
    -- with the bits representing the value, not the whole word.
    }
    deriving(Show, Read, Eq)

data Value r
    = VoidValue
    | WordValue (WordType r) !Word64
    | PtrValue (PtrType r) (Maybe U.Ptr)
    deriving(Show, Eq, Functor)

-- | Extract the type from a 'FildLocType'.
fieldType :: FieldLocType r -> Type r
fieldType (DataField _ ty)            = WordType ty
fieldType PtrField{ptrFieldType = ty} = PtrType ty
fieldType (HereField ty)              = CompositeType ty
fieldType VoidField                   = VoidType
