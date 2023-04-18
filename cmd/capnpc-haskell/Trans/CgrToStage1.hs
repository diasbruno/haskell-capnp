{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NamedFieldPuns #-}

-- | Module: Trans.CgrToStage1
-- Description: Translate from schema.capnp's codegenerator request to IR.Stage1.
module Trans.CgrToStage1 (cgrToCgr) where

import qualified Capnp.Basics as B
import Capnp.Classes (toWord)
import Capnp.Fields (HasUnion (..))
import qualified Capnp.Gen.Capnp.Schema as Schema
import Capnp.Repr.Parsed (Parsed)
import qualified Data.ByteString as BS
import Data.Function ((&))
import qualified Data.Map.Strict as M
import Data.Maybe (mapMaybe)
import qualified Data.Text as T
import Data.Text.Encoding (encodeUtf8)
import Data.Word
import GHC.Float (castDoubleToWord64, castFloatToWord32)
import qualified IR.Common as C
import qualified IR.Name as Name
import qualified IR.Stage1 as Stage1

type NodeMap v = M.Map Word64 v

nodesToNodes :: NodeMap (Parsed Schema.Node) -> NodeMap Stage1.Node
nodesToNodes inMap = outMap
  where
    outMap = M.map translate inMap

    translate Schema.Node {scopeId, id, nestedNodes, union', parameters} =
      Stage1.Node
        { nodeCommon =
            Stage1.NodeCommon
              { nodeId = id,
                nodeNested =
                  [ (Name.UnQ name, node)
                    | Schema.Node'NestedNode {name, id} <- nestedNodes,
                      Just node <- [M.lookup id outMap]
                  ],
                nodeParent =
                  if scopeId == 0
                    then Nothing
                    else Just (outMap M.! id),
                nodeParams =
                  [ Name.UnQ name
                    | Schema.Node'Parameter {name} <- parameters
                  ]
              },
          nodeUnion = case union' of
            Schema.Node'enum Schema.Node'enum' {enumerants} ->
              Stage1.NodeEnum $ map enumerantToName enumerants
            Schema.Node'struct
              Schema.Node'struct'
                { dataWordCount,
                  pointerCount,
                  isGroup,
                  discriminantOffset,
                  fields
                } ->
                Stage1.NodeStruct
                  Stage1.Struct
                    { dataWordCount,
                      pointerCount,
                      isGroup,
                      tagOffset = discriminantOffset,
                      fields = map (fieldToField outMap) fields
                    }
            Schema.Node'interface Schema.Node'interface' {methods, superclasses} ->
              Stage1.NodeInterface
                Stage1.Interface
                  { methods = map (methodToMethod outMap) methods,
                    supers =
                      [ C.InterfaceType (outMap M.! id) (brandToBrand outMap brand)
                        | Schema.Superclass {id, brand} <- superclasses
                      ]
                  }
            Schema.Node'const Schema.Node'const' {type_ = Schema.Type type_, value = Schema.Value value} ->
              Stage1.NodeConstant $
                let mismatch = error "ERROR: Constant's type and value do not agree"
                 in case value of
                      Schema.Value'void ->
                        C.VoidValue
                      Schema.Value'bool v ->
                        C.WordValue (C.PrimWord C.PrimBool) (toWord v)
                      Schema.Value'int8 v ->
                        C.WordValue (C.PrimWord $ C.PrimInt $ C.IntType C.Signed C.Sz8) (toWord v)
                      Schema.Value'int16 v ->
                        C.WordValue (C.PrimWord $ C.PrimInt $ C.IntType C.Signed C.Sz16) (toWord v)
                      Schema.Value'int32 v ->
                        C.WordValue (C.PrimWord $ C.PrimInt $ C.IntType C.Signed C.Sz32) (toWord v)
                      Schema.Value'int64 v ->
                        C.WordValue (C.PrimWord $ C.PrimInt $ C.IntType C.Signed C.Sz64) (toWord v)
                      Schema.Value'uint8 v ->
                        C.WordValue (C.PrimWord $ C.PrimInt $ C.IntType C.Unsigned C.Sz8) (toWord v)
                      Schema.Value'uint16 v ->
                        C.WordValue (C.PrimWord $ C.PrimInt $ C.IntType C.Unsigned C.Sz16) (toWord v)
                      Schema.Value'uint32 v ->
                        C.WordValue (C.PrimWord $ C.PrimInt $ C.IntType C.Unsigned C.Sz32) (toWord v)
                      Schema.Value'uint64 v ->
                        C.WordValue (C.PrimWord $ C.PrimInt $ C.IntType C.Unsigned C.Sz64) (toWord v)
                      Schema.Value'float32 v ->
                        C.WordValue (C.PrimWord C.PrimFloat32) (toWord v)
                      Schema.Value'float64 v ->
                        C.WordValue (C.PrimWord C.PrimFloat64) (toWord v)
                      Schema.Value'text v ->
                        C.PtrValue (C.PrimPtr C.PrimText) $
                          Just $
                            B.PtrList $
                              B.List8 $
                                encodeUtf8 v
                                  & BS.unpack
                                  & (++ [0])
                      Schema.Value'data_ v ->
                        C.PtrValue (C.PrimPtr C.PrimText) $
                          Just $
                            B.PtrList $
                              B.List8 $
                                BS.unpack v
                      Schema.Value'list v ->
                        case type_ of
                          Schema.Type'list (Schema.Type'list' (Schema.Type elementType)) ->
                            C.PtrValue
                              (C.ListOf (typeToType outMap elementType))
                              v
                          _ ->
                            mismatch
                      Schema.Value'enum v ->
                        case type_ of
                          -- TODO: brand
                          Schema.Type'enum Schema.Type'enum' {typeId} ->
                            C.WordValue (C.EnumType (outMap M.! typeId)) (toWord v)
                          _ ->
                            mismatch
                      Schema.Value'struct v ->
                        case type_ of
                          -- TODO: brand
                          Schema.Type'struct Schema.Type'struct' {typeId, brand} ->
                            C.PtrValue
                              ( C.PtrComposite $
                                  C.StructType
                                    (outMap M.! typeId)
                                    (brandToBrand outMap brand)
                              )
                              v
                          _ ->
                            mismatch
                      Schema.Value'interface ->
                        case type_ of
                          Schema.Type'interface Schema.Type'interface' {typeId, brand} ->
                            C.PtrValue
                              (C.PtrInterface (C.InterfaceType (outMap M.! typeId) (brandToBrand outMap brand)))
                              Nothing
                          _ ->
                            mismatch
                      Schema.Value'anyPointer v ->
                        C.PtrValue (C.PrimPtr (C.PrimAnyPtr C.Ptr)) v
                      Schema.Value'unknown' tag ->
                        error $ "Unknown variant for Value #" ++ show tag
            _ ->
              Stage1.NodeOther
        }

brandToBrand :: NodeMap Stage1.Node -> Parsed Schema.Brand -> Stage1.Brand
brandToBrand nodeMap Schema.Brand {scopes} =
  C.MapBrand $ M.fromList $ mapMaybe scopeToScope scopes
  where
    scopeToScope Schema.Brand'Scope {scopeId, union'} = case union' of
      Schema.Brand'Scope'unknown' _ -> Nothing
      Schema.Brand'Scope'inherit -> Nothing
      Schema.Brand'Scope'bind bindings ->
        Just
          ( scopeId,
            C.Bind $
              bindings
                & map
                  ( \(Schema.Brand'Binding b) -> case b of
                      Schema.Brand'Binding'type_ (Schema.Type typ) ->
                        case typeToType nodeMap typ of
                          C.PtrType t ->
                            C.BoundType t
                          C.CompositeType t ->
                            C.BoundType (C.PtrComposite t)
                          _ ->
                            error
                              "Invalid schema: a type parameter was set to a non-pointer type."
                      Schema.Brand'Binding'unbound -> C.Unbound
                      Schema.Brand'Binding'unknown' _ -> C.Unbound
                  )
          )

methodToMethod :: NodeMap Stage1.Node -> Parsed Schema.Method -> Stage1.Method
methodToMethod
  nodeMap
  Schema.Method
    { name,
      paramStructType,
      paramBrand,
      resultStructType,
      resultBrand
    } =
    Stage1.Method
      { name = Name.UnQ name,
        paramType = structTypeToType nodeMap paramStructType paramBrand,
        resultType = structTypeToType nodeMap resultStructType resultBrand
      }

enumerantToName :: Parsed Schema.Enumerant -> Name.UnQ
enumerantToName Schema.Enumerant {name} = Name.UnQ name

fieldToField :: NodeMap Stage1.Node -> Parsed Schema.Field -> Stage1.Field
fieldToField nodeMap Schema.Field {name, discriminantValue, union'} =
  Stage1.Field
    { name = Name.UnQ name,
      tag =
        if discriminantValue == Schema.field'noDiscriminant
          then Nothing
          else Just discriminantValue,
      locType = getFieldLocType nodeMap union'
    }

getFieldLocType :: NodeMap Stage1.Node -> Parsed (Which Schema.Field) -> C.FieldLocType Stage1.Brand Stage1.Node
getFieldLocType nodeMap = \case
  Schema.Field'slot
    Schema.Field'slot'
      { type_ = Schema.Type type_,
        defaultValue = Schema.Value defaultValue,
        offset
      } ->
      case typeToType nodeMap type_ of
        C.VoidType ->
          C.VoidField
        C.PtrType ty ->
          C.PtrField (fromIntegral offset) ty
        C.WordType ty ->
          case valueBits defaultValue of
            Nothing ->
              error $
                "Invlaid schema: a field in a struct's data section "
                  ++ "had an illegal (non-data) default value."
            Just defaultVal ->
              C.DataField
                (dataLoc offset ty defaultVal)
                ty
        C.CompositeType ty ->
          C.PtrField (fromIntegral offset) (C.PtrComposite ty)
  Schema.Field'group Schema.Field'group' {typeId} ->
    C.HereField $
      C.StructType
        (nodeMap M.! typeId)
        (C.MapBrand M.empty) -- groups are always monomorphic
  Schema.Field'unknown' _ ->
    -- Don't know how to interpret this; we'll have to leave the argument
    -- opaque.
    C.VoidField

-- | Given the offset field from the capnp schema, a type, and a
-- default value, return a DataLoc describing the location of a field.
dataLoc :: Word32 -> C.WordType Stage1.Node -> Word64 -> C.DataLoc
dataLoc offset ty defaultVal =
  let bitsOffset = fromIntegral offset * C.dataFieldSize ty
   in C.DataLoc
        { dataIdx = bitsOffset `div` 64,
          dataOff = bitsOffset `mod` 64,
          dataDef = defaultVal
        }

-- | Return the raw bit-level representation of a value that is stored
-- in a struct's data section.
--
-- returns Nothing if the value is a non-word type.
valueBits :: Parsed (Which Schema.Value) -> Maybe Word64
valueBits = \case
  Schema.Value'bool b -> Just $ fromIntegral $ fromEnum b
  Schema.Value'int8 n -> Just $ fromIntegral n
  Schema.Value'int16 n -> Just $ fromIntegral n
  Schema.Value'int32 n -> Just $ fromIntegral n
  Schema.Value'int64 n -> Just $ fromIntegral n
  Schema.Value'uint8 n -> Just $ fromIntegral n
  Schema.Value'uint16 n -> Just $ fromIntegral n
  Schema.Value'uint32 n -> Just $ fromIntegral n
  Schema.Value'uint64 n -> Just n
  Schema.Value'float32 n -> Just $ fromIntegral $ castFloatToWord32 n
  Schema.Value'float64 n -> Just $ castDoubleToWord64 n
  Schema.Value'enum n -> Just $ fromIntegral n
  _ -> Nothing -- some non-word type.

reqFileToReqFile :: NodeMap Stage1.Node -> Parsed Schema.CodeGeneratorRequest'RequestedFile -> Stage1.ReqFile
reqFileToReqFile nodeMap Schema.CodeGeneratorRequest'RequestedFile {id, filename} =
  let Stage1.Node {nodeCommon = Stage1.NodeCommon {nodeNested}} = nodeMap M.! id
   in Stage1.ReqFile
        { fileName = T.unpack filename,
          file =
            Stage1.File
              { fileNodes = nodeNested,
                fileId = id
              }
        }

cgrToCgr :: Parsed Schema.CodeGeneratorRequest -> Stage1.CodeGenReq
cgrToCgr Schema.CodeGeneratorRequest {nodes, requestedFiles} =
  Stage1.CodeGenReq {allFiles, reqFiles}
  where
    nodeMap = nodesToNodes $ M.fromList [(id, node) | node@Schema.Node {id} <- nodes]
    reqFiles = map (reqFileToReqFile nodeMap) requestedFiles
    allFiles =
      [ let fileNodes =
              [ (Name.UnQ name, nodeMap M.! id)
                | Schema.Node'NestedNode {name, id} <- nestedNodes,
                  -- If the file is an import (i.e. not part of requestedFiles), then
                  -- the code generator will sometimes omit parts of it that are not
                  -- used. We need to check that the nestedNodes are actually included;
                  -- if not, we omit them from the otuput as well.
                  M.member id nodeMap
              ]
         in Stage1.File {fileId, fileNodes}
        | Schema.Node {union' = Schema.Node'file, id = fileId, nestedNodes} <- nodes
      ]

structTypeToType ::
  NodeMap Stage1.Node ->
  Word64 ->
  Parsed Schema.Brand ->
  C.CompositeType Stage1.Brand Stage1.Node
structTypeToType nodeMap typeId brand =
  C.StructType (nodeMap M.! typeId) (brandToBrand nodeMap brand)

typeToType :: NodeMap Stage1.Node -> Parsed (Which Schema.Type) -> C.Type Stage1.Brand Stage1.Node
typeToType nodeMap = \case
  Schema.Type'void -> C.VoidType
  Schema.Type'bool -> C.WordType $ C.PrimWord C.PrimBool
  Schema.Type'int8 -> C.WordType $ C.PrimWord $ C.PrimInt $ C.IntType C.Signed C.Sz8
  Schema.Type'int16 -> C.WordType $ C.PrimWord $ C.PrimInt $ C.IntType C.Signed C.Sz16
  Schema.Type'int32 -> C.WordType $ C.PrimWord $ C.PrimInt $ C.IntType C.Signed C.Sz32
  Schema.Type'int64 -> C.WordType $ C.PrimWord $ C.PrimInt $ C.IntType C.Signed C.Sz64
  Schema.Type'uint8 -> C.WordType $ C.PrimWord $ C.PrimInt $ C.IntType C.Unsigned C.Sz8
  Schema.Type'uint16 -> C.WordType $ C.PrimWord $ C.PrimInt $ C.IntType C.Unsigned C.Sz16
  Schema.Type'uint32 -> C.WordType $ C.PrimWord $ C.PrimInt $ C.IntType C.Unsigned C.Sz32
  Schema.Type'uint64 -> C.WordType $ C.PrimWord $ C.PrimInt $ C.IntType C.Unsigned C.Sz64
  Schema.Type'float32 -> C.WordType $ C.PrimWord C.PrimFloat32
  Schema.Type'float64 -> C.WordType $ C.PrimWord C.PrimFloat64
  Schema.Type'text -> C.PtrType $ C.PrimPtr C.PrimText
  Schema.Type'data_ -> C.PtrType $ C.PrimPtr C.PrimData
  Schema.Type'list Schema.Type'list' {elementType = Schema.Type t} ->
    C.PtrType $ C.ListOf (typeToType nodeMap t)
  -- nb. enum has a brand field, but it's not actually use for anything.
  Schema.Type'enum Schema.Type'enum' {typeId, brand = _} ->
    C.WordType $ C.EnumType $ nodeMap M.! typeId
  -- TODO: use 'brand' to generate type parameters.
  Schema.Type'struct Schema.Type'struct' {typeId, brand} ->
    C.CompositeType $ structTypeToType nodeMap typeId brand
  Schema.Type'interface Schema.Type'interface' {typeId, brand} ->
    C.PtrType $ C.PtrInterface (C.InterfaceType (nodeMap M.! typeId) (brandToBrand nodeMap brand))
  Schema.Type'anyPointer (Schema.Type'anyPointer' p) ->
    case p of
      Schema.Type'anyPointer'parameter Schema.Type'anyPointer'parameter' {scopeId, parameterIndex} ->
        let paramScope = nodeMap M.! scopeId
         in C.PtrType $
              C.PtrParam
                C.TypeParamRef
                  { paramScope,
                    paramIndex = fromIntegral parameterIndex,
                    paramName = Stage1.nodeParams (Stage1.nodeCommon paramScope) !! fromIntegral parameterIndex
                  }
      Schema.Type'anyPointer'unconstrained
        (Schema.Type'anyPointer'unconstrained' unconstrained) ->
          C.PtrType $ C.PrimPtr $ C.PrimAnyPtr $ case unconstrained of
            Schema.Type'anyPointer'unconstrained'anyKind -> C.Ptr
            Schema.Type'anyPointer'unconstrained'struct -> C.Struct
            Schema.Type'anyPointer'unconstrained'list -> C.List
            Schema.Type'anyPointer'unconstrained'capability -> C.Cap
            Schema.Type'anyPointer'unconstrained'unknown' _ -> C.Ptr
      -- \^ Something we don't know about; assume it could be anything.
      _ -> C.VoidType -- TODO: implicitMethodParameter
  _ -> C.VoidType -- TODO: constrained anyPointers
