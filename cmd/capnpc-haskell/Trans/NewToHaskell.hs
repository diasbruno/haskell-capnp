{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE LambdaCase            #-}
{-# LANGUAGE NamedFieldPuns        #-}
{-# LANGUAGE OverloadedStrings     #-}
module Trans.NewToHaskell
    ( fileToModules
    ) where

import qualified Capnp.Repr            as R
import           Data.String           (IsString(fromString))
import           Data.Word
import qualified IR.Common             as C
import qualified IR.Haskell            as Hs
import qualified IR.Name               as Name
import qualified IR.New                as New
import           Trans.ToHaskellCommon

imports :: [Hs.Import]
imports =
    [ Hs.ImportAs { importAs = "R", parts = ["Capnp", "Repr"] }
    , Hs.ImportAs { importAs = "F", parts = ["Capnp", "Fields"] }
    , Hs.ImportAs { importAs = "Basics", parts = ["Capnp", "New", "Basics"] }
    , Hs.ImportAs { importAs = "OL", parts = ["GHC", "OverloadedLabels"] }
    , Hs.ImportAs { importAs = "GH", parts = ["Capnp", "GenHelpers", "New"] }
    ]

fileToModules :: New.File -> [Hs.Module]
fileToModules file@New.File{fileName} =
    [ Hs.Module
        { modName = ["Capnp", "Gen"] ++ makeModName fileName ++ ["New"]
        , modLangPragmas =
            [ "TypeFamilies"
            , "DataKinds"
            , "FlexibleInstances"
            , "MultiParamTypeClasses"
            , "UndecidableInstances"
            ]
        , modExports = Nothing
        , modImports = imports
        , modDecls = fileToDecls file
        }
    ]

fileToDecls :: New.File -> [Hs.Decl]
fileToDecls New.File{fileId, decls} =
    concatMap (declToDecls fileId) decls


declToDecls :: Word64 -> New.Decl -> [Hs.Decl]
declToDecls thisMod decl =
    case decl of
        New.TypeDecl {name, params, repr} ->
            let dataName = Name.localToUnQ name
                typeArgs = toTVars params
            in
            [ Hs.DcData Hs.Data
                { dataName
                , typeArgs
                , dataVariants = []
                , derives = []
                , dataNewtype = False
                }
            , Hs.DcTypeInstance
                (Hs.TApp
                    (tgName ["R"] "ReprFor")
                    [ case typeArgs of
                        [] -> tuName dataName
                        _  -> Hs.TApp (tuName dataName) typeArgs
                    ]
                )
                (toType repr)
            ]
        New.FieldDecl{containerType, typeParams, fieldName, fieldLocType} ->
            let tVars = toTVars typeParams
                ctx = paramsContext tVars
                labelType = Hs.TString (Name.renderUnQ fieldName)
                parentType = Hs.TApp (Hs.TLName containerType) tVars
                childType = fieldLocTypeToType thisMod fieldLocType
                fieldKind = Hs.TGName $ fieldLocTypeToFieldKind fieldLocType
            in
            [ Hs.DcInstance
                { ctx
                , typ = Hs.TApp (tgName ["OL"] "IsLabel")
                    [ labelType
                    , Hs.TApp (tgName ["F"] "Field") [fieldKind, parentType, childType]
                    ]
                , defs =
                    [ Hs.IdValue Hs.DfValue
                        { name = "fromLabel"
                        , value = fieldLocTypeToField fieldLocType
                        , params = []
                        }
                    ]
                }
            , Hs.DcInstance
                { ctx
                , typ = Hs.TApp
                    (tgName ["F"] "HasField")
                    [labelType, fieldKind, parentType, childType]
                , defs = []
                }
            ]
        New.UnionDecl{name, typeParams, tagLoc, variants} ->
            let tVars = toTVars typeParams in
            Hs.DcInstance
                { ctx = paramsContext tVars
                , typ = Hs.TApp
                    (tgName ["F"] "HasUnion")
                    [Hs.TApp (Hs.TLName name) tVars]
                , defs =
                    [ Hs.IdValue Hs.DfValue
                        { name = "unionField"
                        , params = []
                        , value = fieldLocTypeToField $ C.DataField
                            tagLoc
                            (C.PrimWord (C.PrimInt (C.IntType C.Unsigned C.Sz16)))
                        }
                    , defineRawData thisMod name tVars variants
                    -- , defineInternalWhich thisMod name typeParams variants
                    ]
                }
            : concatMap (variantToDecls thisMod name typeParams) variants


defineRawData _thisMod name tVars _variants =
    Hs.IdData Hs.Data
        { dataName = "RawWhich"
        , typeArgs =
            [ Hs.TVar "mut_"
            , Hs.TApp (Hs.TVar $ Name.renderUnQ $ Name.localToUnQ name) tVars
            ]

        , dataNewtype = False
        -- TODO:
        , dataVariants = []
        , derives = []
        }

variantToDecls thisMod containerType typeParams New.UnionVariant{tagValue, variantName, fieldLocType} =
    let tVars = toTVars typeParams
        ctx = paramsContext tVars
        labelType = Hs.TString (Name.renderUnQ variantName)
        parentType = Hs.TApp (Hs.TLName containerType) tVars
        childType = fieldLocTypeToType thisMod fieldLocType
        fieldKind = Hs.TGName $ fieldLocTypeToFieldKind fieldLocType
    in
    [ Hs.DcInstance
        { ctx
        , typ = Hs.TApp (tgName ["OL"] "IsLabel")
            [ labelType
            , Hs.TApp (tgName ["F"] "Variant")
                [fieldKind, parentType, childType]
            ]
        , defs =
            [ Hs.IdValue Hs.DfValue
                { name = "fromLabel"
                , params = []
                , value = Hs.EApp
                    (egName ["F"] "Variant")
                    [ fieldLocTypeToField fieldLocType
                    , Hs.EInt (fromIntegral tagValue)
                    ]
                }
            ]
        }
    , Hs.DcInstance
        { ctx
        , typ = Hs.TApp
            (tgName ["F"] "HasVariant")
            [labelType, fieldKind, parentType, childType]
        , defs = []
        }
    ]

paramsContext :: [Hs.Type] -> [Hs.Type]
paramsContext tVars =
    zipWith paramConstraints tVars (map (("pr_" ++) . show) [1..])

-- | Constraints required for a capnproto type parameter. The returned
-- expression has kind 'Constraint'.
--
-- The second argument is a unique type variable name within this scope.
paramConstraints :: Hs.Type -> String -> Hs.Type
paramConstraints t s =
    Hs.TApp (tgName ["GH"] "TypeParam") [t, Hs.TVar $ fromString s]

tCapnp :: Word64 -> Name.CapnpQ -> Hs.Type
tCapnp thisMod Name.CapnpQ{local, fileId}
    | thisMod == fileId = Hs.TLName local
    | otherwise = tgName (map Name.renderUnQ $ idToModule fileId ++ ["New"]) local

fieldLocTypeToType :: Word64 -> C.FieldLocType New.Brand Name.CapnpQ -> Hs.Type
fieldLocTypeToType thisMod = \case
    C.VoidField     -> Hs.TUnit
    C.DataField _ t -> wordTypeToType thisMod t
    C.PtrField _ t  -> ptrTypeToType thisMod t
    C.HereField t   -> compositeTypeToType thisMod t

fieldLocTypeToFieldKind :: C.FieldLocType b n -> Name.GlobalQ
fieldLocTypeToFieldKind = \case
    C.HereField _ -> gName ["F"] "Group"
    _             -> gName ["F"] "Slot"

wordTypeToType thisMod = \case
    C.EnumType t -> tCapnp thisMod t
    C.PrimWord t -> primWordToType t

primWordToType = \case
    C.PrimInt t   -> intTypeToType t
    C.PrimFloat32 -> tStd_ "Float"
    C.PrimFloat64 -> tStd_ "Double"
    C.PrimBool    -> tStd_ "Bool"

intTypeToType (C.IntType sign size) =
    let prefix = case sign of
            C.Signed   -> "Int"
            C.Unsigned -> "Word"
    in
    tStd_ $ fromString $ prefix ++ show (C.sizeBits size)

wordTypeBits = \case
    C.EnumType _                              -> 16
    C.PrimWord (C.PrimInt (C.IntType _ size)) -> C.sizeBits size
    C.PrimWord C.PrimFloat32                  -> 32
    C.PrimWord C.PrimFloat64                  -> 64
    C.PrimWord C.PrimBool                     -> 1

ptrTypeToType thisMod = \case
    C.ListOf t       -> Hs.TApp (tgName ["R"] "List") [typeToType thisMod t]
    C.PrimPtr t      -> primPtrToType t
    C.PtrComposite t -> compositeTypeToType thisMod t
    C.PtrInterface t -> interfaceTypeToType thisMod t
    C.PtrParam t     -> typeParamToType t

typeToType thisMod = \case
    C.CompositeType t -> compositeTypeToType thisMod t
    C.VoidType        -> Hs.TUnit
    C.WordType t      -> wordTypeToType thisMod t
    C.PtrType t       -> ptrTypeToType thisMod t

primPtrToType = \case
    C.PrimText     -> tgName ["Basics"] "Text"
    C.PrimData     -> tgName ["Basics"] "Data"
    C.PrimAnyPtr t -> anyPtrToType t

anyPtrToType :: C.AnyPtr -> Hs.Type
anyPtrToType t = tgName ["Basics"] $ case t of
    C.Struct -> "AnyStruct"
    C.List   -> "AnyList"
    C.Cap    -> "Capability"
    C.Ptr    -> "AnyPointer"

compositeTypeToType thisMod (C.StructType    name brand) = namedType thisMod name brand
interfaceTypeToType thisMod (C.InterfaceType name brand) = namedType thisMod name brand

typeParamToType = Hs.TVar . Name.typeVarName . C.paramName

namedType :: Word64 -> Name.CapnpQ -> C.ListBrand Name.CapnpQ -> Hs.Type
namedType thisMod name (C.ListBrand [])   = tCapnp thisMod name
namedType thisMod name (C.ListBrand args) =
    Hs.TApp
        (tCapnp thisMod name)
        [ typeToType thisMod (C.PtrType t) | t <- args ]

fieldLocTypeToField = \case
    C.DataField loc wt ->
        let shift = C.dataOff loc
            index = C.dataIdx loc
            nbits = wordTypeBits wt
            defaultValue = C.dataDef loc
        in
        Hs.EApp
            (egName ["GH"] "dataField")
            [ Hs.EInt $ fromIntegral shift
            , Hs.EInt $ fromIntegral index
            , Hs.EInt $ fromIntegral nbits
            , Hs.EInt $ fromIntegral defaultValue
            ]
    C.PtrField idx _ ->
        Hs.EApp (egName ["GH"] "ptrField") [Hs.EInt $ fromIntegral idx]
    C.VoidField ->
        egName ["GH"] "voidField"
    C.HereField _ ->
        egName ["GH"] "groupField"


class ToType a where
    toType :: a -> Hs.Type

instance ToType R.Repr where
    toType (R.Ptr p)  = rApp "Ptr" [toType p]
    toType (R.Data d) = rApp "Data" [toType d]

instance ToType a => ToType (Maybe a) where
    toType Nothing  = tStd_ "Nothing"
    toType (Just a) = Hs.TApp (tStd_ "Just") [toType a]

instance ToType R.PtrRepr where
    toType R.Cap      = tReprName "Cap"
    toType (R.List r) = rApp "List" [toType r]
    toType R.Struct   = tReprName "Struct"

instance ToType R.ListRepr where
    toType (R.ListNormal nl) = rApp "ListNormal" [toType nl]
    toType R.ListComposite   = tReprName "ListComposite"

instance ToType R.NormalListRepr where
    toType (R.ListData r) = rApp "ListData" [toType r]
    toType R.ListPtr      = tReprName "ListPtr"

instance ToType R.DataSz where
    toType = tReprName . fromString . show


rApp :: Name.LocalQ -> [Hs.Type] -> Hs.Type
rApp n = Hs.TApp (tReprName n)

tReprName :: Name.LocalQ -> Hs.Type
tReprName = tgName ["R"]
