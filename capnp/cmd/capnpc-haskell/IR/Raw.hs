-- IR for a high-level representation of the low-level API modules.
--
-- This talks about things like getters, setters, wrapper types for structs,
-- etc. It's still not at the level of detail of actual Haskell, but encodes
-- the constructs to be generated, as opposed to the declarative description
-- of the schema.
{-# LANGUAGE DuplicateRecordFields #-}

module IR.Raw (File (..), Decl (..), Variant (..), TagSetter (..), NewFnType (..), tagOffsetToDataLoc) where

import Data.Word
import qualified IR.Common as Common
import qualified IR.Name as Name

type Brand = Common.ListBrand Name.CapnpQ

data File = File
  { fileId :: !Word64,
    fileName :: FilePath,
    decls :: [Decl]
  }
  deriving (Show, Eq)

data Decl
  = -- | Define a newtype wrapper around a struct. This also defines
    -- some instances of type classes that exist for all such wrappers.
    StructWrapper
      { typeCtor :: Name.LocalQ,
        typeParams :: [Name.UnQ]
      }
  | -- | Define instances of several type classes which should only
    -- exist for "real" structs, i.e. not groups.
    StructInstances
      { -- | The type constructor for the type to generate instances for.
        typeCtor :: Name.LocalQ,
        typeParams :: [Name.UnQ],
        -- Needed for some instances:
        dataWordCount :: !Word16,
        pointerCount :: !Word16
      }
  | InterfaceWrapper
      { typeCtor :: Name.LocalQ,
        typeParams :: [Name.UnQ]
      }
  | UnionVariant
      { -- | The type constructor of the parent, i.e. the enclosing struct.
        -- we can derive the type constructor for the union proper from this,
        -- and it is useful to have for other things (like unknown' variants).
        parentTypeCtor :: Name.LocalQ,
        tagOffset :: !Word32,
        typeParams :: [Name.UnQ],
        unionDataCtors :: [Variant]
      }
  | Enum
      { typeCtor :: Name.LocalQ,
        dataCtors :: [Name.LocalQ]
      }
  | Getter -- get_* function
      { fieldName :: Name.LocalQ,
        containerType :: Name.LocalQ,
        typeParams :: [Name.UnQ],
        fieldLocType :: Common.FieldLocType Brand Name.CapnpQ
      }
  | Setter -- set_* function
      { fieldName :: Name.LocalQ,
        containerType :: Name.LocalQ,
        typeParams :: [Name.UnQ],
        fieldLocType :: Common.FieldLocType Brand Name.CapnpQ,
        -- | Info for setting the tag, if this is a union.
        tag :: Maybe TagSetter
      }
  | HasFn -- has_* function
      { fieldName :: Name.LocalQ,
        containerType :: Name.LocalQ,
        typeParams :: [Name.UnQ],
        ptrIndex :: !Word16
      }
  | NewFn -- new_* function
      { fieldName :: Name.LocalQ,
        containerType :: Name.LocalQ,
        typeParams :: [Name.UnQ],
        fieldLocType :: Common.FieldLocType Brand Name.CapnpQ,
        newFnType :: NewFnType
      }
  | Constant
      { name :: Name.LocalQ,
        value :: Common.Value Brand Name.CapnpQ
      }
  deriving (Show, Eq)

data NewFnType
  = NewList
  | NewText
  | NewData
  | NewStruct
  deriving (Show, Eq)

data TagSetter = TagSetter
  { tagOffset :: !Word32,
    tagValue :: !Word16
  }
  deriving (Show, Eq)

-- | Convert a tag offset (as in the 'tagOffset' field of 'TagSetter') to a
-- corresponding 'Common.DataLoc', with the default value set to zero.
tagOffsetToDataLoc :: Word32 -> Common.DataLoc
tagOffsetToDataLoc tagOffset =
  Common.DataLoc
    { dataIdx = fromIntegral tagOffset `div` 4,
      dataOff = (fromIntegral tagOffset `mod` 4) * 16,
      dataDef = 0
    }

data Variant = Variant
  { name :: Name.LocalQ,
    tagValue :: !Word16,
    locType :: Common.FieldLocType Brand Name.CapnpQ
  }
  deriving (Show, Eq)
