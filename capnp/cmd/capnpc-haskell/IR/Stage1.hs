-- First stage IR. This models the data structures in schema.capnp more closely
-- than the other intermediate forms. Differences:
--
-- \* Lots of information which we won't use is discarded.
-- \* Nodes no longer reference eachother by ID; instead we include direct
--   references to the objects.
-- \* The details of some structures are tweaked to make them more ergonomic
--   to use and/or more idiomatic Haskell.
{-# LANGUAGE DuplicateRecordFields #-}

module IR.Stage1
  ( File (..),
    ReqFile (..),
    Interface (..),
    Method (..),
    Node (..),
    NodeCommon (..),
    NodeUnion (..),
    Struct (..),
    Field (..),
    CodeGenReq (..),
    Brand,
  )
where

import Data.Word
import qualified IR.Common as Common
import qualified IR.Name as Name

type Brand = Common.MapBrand Node

data CodeGenReq = CodeGenReq
  { reqFiles :: [ReqFile],
    allFiles :: [File]
  }

data ReqFile = ReqFile
  { file :: File,
    fileName :: FilePath
  }

data File = File
  { fileNodes :: [(Name.UnQ, Node)],
    fileId :: !Word64
  }
  deriving (Show, Eq)

data Node = Node
  { nodeCommon :: NodeCommon,
    nodeUnion :: NodeUnion
  }
  deriving (Show, Eq)

data NodeCommon = NodeCommon
  { nodeNested :: [(Name.UnQ, Node)],
    nodeParent :: Maybe Node,
    nodeId :: !Word64,
    nodeParams :: [Name.UnQ]
  }
  deriving (Show, Eq)

data NodeUnion
  = NodeEnum [Name.UnQ]
  | NodeStruct Struct
  | NodeInterface Interface
  | NodeConstant (Common.Value Brand Node)
  | NodeOther
  deriving (Show, Eq)

data Interface = Interface
  { methods :: [Method],
    supers :: [Common.InterfaceType Brand Node]
  }
  deriving (Show, Eq)

data Method = Method
  { name :: Name.UnQ,
    paramType :: Common.CompositeType Brand Node,
    resultType :: Common.CompositeType Brand Node
  }
  deriving (Show, Eq)

data Struct = Struct
  { dataWordCount :: !Word16,
    pointerCount :: !Word16,
    isGroup :: !Bool,
    tagOffset :: !Word32,
    fields :: [Field]
  }
  deriving (Show, Eq)

data Field = Field
  { name :: Name.UnQ,
    tag :: Maybe Word16,
    locType :: Common.FieldLocType Brand Node
  }
  deriving (Show, Eq)
