{-# LANGUAGE DuplicateRecordFields #-}

module IR.Pure where

import Data.Word
import qualified IR.Common as C
import qualified IR.Name as Name

type Brand = C.ListBrand Name.CapnpQ

data File = File
  { fileId :: !Word64,
    fileName :: FilePath,
    decls :: [Decl],
    -- | A list of enums that we should re-export from this module.
    reExportEnums :: [Name.LocalQ],
    -- | Whether or not the module uses rpc features. If not, we skip
    -- the rpc related imports. This is mainly important to avoid a
    -- cyclic dependency with rpc.capnp.
    usesRpc :: !Bool
  }

data Decl
  = DataDecl Data
  | ConstDecl Constant
  | IFaceDecl Interface

data Data = Data
  { typeName :: Name.LocalQ,
    typeParams :: [Name.UnQ],
    -- | Whether this is a "first class" type, i.e. it is a type in the
    -- capnproto sense, rather than an auxiliary type defined for a group
    -- or an anonymous union.
    --
    -- Note that this *can* be set for unions, if they subsume the whole
    -- struct, since in that case we collapse the two types in the
    -- high-level API.
    firstClass :: !Bool,
    -- | The name of the type our 'Cerial' should be. This will only be
    -- different from typeName if we're an anonymous union in a struct
    -- that also has other fields; in this case our Cerial should be
    -- the same as our parent struct.
    cerialName :: Name.LocalQ,
    def :: DataDef
  }

data DataDef
  = Sum [Variant]
  | Product [Field]

data Constant = Constant
  { name :: Name.LocalQ,
    value :: C.Value Brand Name.CapnpQ
  }

data Interface = IFace
  { name :: Name.CapnpQ,
    typeParams :: [C.TypeParamRef Name.CapnpQ],
    interfaceId :: !Word64,
    methods :: [Method],
    -- | Immediate superclasses
    supers :: [(Interface, Brand)],
    -- | All ancestors, including 'supers'.
    ancestors :: [(Interface, Brand)]
  }

-- TODO(cleanup): this same type exists in IR.Flat; it doesn't make sense for
-- IR.Common, but we should factor this out.
data Method = Method
  { name :: Name.UnQ,
    paramType :: C.CompositeType Brand Name.CapnpQ,
    resultType :: C.CompositeType Brand Name.CapnpQ
  }

data Field = Field
  { -- | The name of the field.
    name :: Name.UnQ,
    -- | The type of the field.
    type_ :: C.Type Brand Name.CapnpQ
  }

data Variant = Variant
  { name :: Name.LocalQ,
    arg :: Maybe (C.Type Brand Name.CapnpQ)
  }
