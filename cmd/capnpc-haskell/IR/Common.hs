-- Data types that are used by more than one intermediate form.
-- See also IR.Name, which defines identifiers, which are also
-- used in more than one IR.
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE LambdaCase #-}

module IR.Common where

import qualified Capnp.Basics as B
import Capnp.Repr.Parsed (Parsed)
import Data.Bifunctor (Bifunctor (..))
import qualified Data.Map.Strict as M
import qualified Data.Vector as V
import Data.Word
import qualified IR.Name as Name

newtype TypeId = TypeId Word64
  deriving (Show, Read, Eq, Ord)

data IntType = IntType !Sign !IntSize
  deriving (Show, Read, Eq)

data Sign
  = Signed
  | Unsigned
  deriving (Show, Read, Eq)

data IntSize
  = Sz8
  | Sz16
  | Sz32
  | Sz64
  deriving (Show, Read, Eq)

sizeBits :: IntSize -> Int
sizeBits Sz8 = 8
sizeBits Sz16 = 16
sizeBits Sz32 = 32
sizeBits Sz64 = 64

-- | Return the size in bits of a type that belongs in the data section of a struct.
dataFieldSize :: WordType r -> Int
dataFieldSize = \case
  EnumType _ -> 16
  PrimWord (PrimInt (IntType _ size)) -> sizeBits size
  PrimWord PrimFloat32 -> 32
  PrimWord PrimFloat64 -> 64
  PrimWord PrimBool -> 1

-- Capnproto types. The 'r' type parameter is the type of references to other nodes,
-- which may be different in different stages of the pipeline. Likewise, the 'b'
-- parameter is the "Brand."

bothMap :: (Bifunctor p, Functor f) => (a -> b) -> p (f a) a -> p (f b) b
bothMap f = bimap (fmap f) f

newtype ListBrand r = ListBrand [PtrType (ListBrand r) r]
  deriving (Show, Read, Eq)

instance Functor ListBrand where
  fmap f (ListBrand ps) = ListBrand (fmap (bothMap f) ps)

newtype MapBrand r = MapBrand (M.Map Word64 (BrandScope r))
  deriving (Show, Eq)

instance Functor MapBrand where
  fmap f (MapBrand m) = MapBrand $ fmap (fmap f) m

newtype BrandScope r = Bind (V.Vector (Binding r))
  deriving (Show, Eq)

instance Functor BrandScope where
  fmap f (Bind bs) = Bind $ fmap (fmap f) bs

data Binding r = Unbound | BoundType (PtrType (MapBrand r) r)
  deriving (Show, Eq)

instance Functor Binding where
  fmap _ Unbound = Unbound
  fmap f (BoundType ty) = BoundType $ bothMap f ty

data TypeParamRef r = TypeParamRef
  { paramScope :: r,
    paramIndex :: !Int,
    paramName :: Name.UnQ
  }
  deriving (Show, Read, Eq, Functor)

data Type b r
  = CompositeType (CompositeType b r)
  | VoidType
  | WordType (WordType r)
  | PtrType (PtrType b r)
  deriving (Show, Read, Eq, Functor)

instance Bifunctor Type where
  second = fmap
  first f = \case
    CompositeType x -> CompositeType (first f x)
    VoidType -> VoidType
    WordType x -> WordType x
    PtrType x -> PtrType (first f x)

data CompositeType b r
  = StructType r b
  deriving (Show, Read, Eq, Functor)

instance Bifunctor CompositeType where
  second = fmap
  first f (StructType r b) = StructType r (f b)

data InterfaceType b r
  = InterfaceType r b
  deriving (Show, Read, Eq, Functor)

instance Bifunctor InterfaceType where
  second = fmap
  first f (InterfaceType r b) = InterfaceType r (f b)

data WordType r
  = EnumType r
  | PrimWord PrimWord
  deriving (Show, Read, Eq, Functor)

data PtrType b r
  = ListOf (Type b r)
  | PrimPtr PrimPtr
  | PtrComposite (CompositeType b r)
  | PtrInterface (InterfaceType b r)
  | PtrParam (TypeParamRef r)
  deriving (Show, Read, Eq, Functor)

instance Bifunctor PtrType where
  second = fmap
  first f = \case
    ListOf x -> ListOf (first f x)
    PrimPtr x -> PrimPtr x
    PtrComposite x -> PtrComposite (first f x)
    PtrInterface x -> PtrInterface (first f x)
    PtrParam p -> PtrParam p

data PrimWord
  = PrimInt IntType
  | PrimFloat32
  | PrimFloat64
  | PrimBool
  deriving (Show, Read, Eq)

data PrimPtr
  = PrimText
  | PrimData
  | PrimAnyPtr AnyPtr
  deriving (Show, Read, Eq)

data AnyPtr
  = Struct
  | List
  | Cap
  | Ptr
  deriving (Show, Read, Eq)

-- | The type and location of a field.
data FieldLocType b r
  = -- | The field is in the struct's data section.
    DataField DataLoc (WordType r)
  | -- | The field is in the struct's pointer section (the argument is the
    -- index).
    PtrField !Word16 (PtrType b r)
  | -- | The field is a group or union; it's "location" is the whole struct.
    HereField (CompositeType b r)
  | -- | The field is of type void (and thus is zero-size).
    VoidField
  deriving (Show, Read, Eq, Functor)

instance Bifunctor FieldLocType where
  second = fmap
  first f = \case
    DataField l t -> DataField l t
    PtrField idx t -> PtrField idx (first f t)
    HereField t -> HereField (first f t)
    VoidField -> VoidField

-- | The location of a field within a struct's data section.
data DataLoc = DataLoc
  { -- | The index of the 64-bit word containing the field.
    dataIdx :: !Int,
    -- | The bit offset inside the 64-bit word.
    dataOff :: !Int,
    -- | The value is stored xor-ed with this value. This is used
    -- to allow for encoding default values. Note that this is xor-ed
    -- with the bits representing the value, not the whole word.
    dataDef :: !Word64
  }
  deriving (Show, Read, Eq)

data Value b r
  = VoidValue
  | WordValue (WordType r) !Word64
  | PtrValue (PtrType b r) (Maybe (Parsed B.AnyPointer))
  deriving (Show, Eq, Functor)

instance Bifunctor Value where
  second = fmap
  first f = \case
    VoidValue -> VoidValue
    WordValue t v -> WordValue t v
    PtrValue t v -> PtrValue (first f t) v

-- | Extract the type from a 'FildLocType'.
fieldType :: FieldLocType r b -> Type r b
fieldType (DataField _ ty) = WordType ty
fieldType (PtrField _ ty) = PtrType ty
fieldType (HereField ty) = CompositeType ty
fieldType VoidField = VoidType
