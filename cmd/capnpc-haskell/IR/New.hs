module IR.New
    ( File(..)
    , Decl(..)
    , Brand
    ) where

import qualified Capnp.Repr as R
import qualified Data.Text  as T
import           Data.Word
import qualified IR.Common  as C
import qualified IR.Name    as Name

type Brand = C.ListBrand Name.CapnpQ

data File
    = File
        { fileId   :: !Word64
        , decls    :: [Decl]
        , fileName :: FilePath
        }

data Decl
    = TypeDecl
        { name   :: Name.LocalQ
        , nodeId :: !Word64
        , params :: [Name.UnQ]
        , repr   :: R.Repr
        }
    | FieldDecl
        { containerType :: Name.LocalQ
        , typeParams    :: [Name.UnQ]
        , fieldName     :: T.Text
        , fieldType     :: C.Type Brand Name.CapnpQ
        }
