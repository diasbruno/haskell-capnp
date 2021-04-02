{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE NamedFieldPuns        #-}
{-# LANGUAGE OverloadedStrings     #-}
module Trans.HaskellToText (moduleToText) where

import Data.List                    (intersperse)
import Data.String                  (fromString)
import Text.PrettyPrint.Leijen.Text (hcat, vcat)

import qualified Data.Text                    as T
import qualified Data.Text.Lazy               as LT
import qualified Text.PrettyPrint.Leijen.Text as PP

import IR.Haskell

import qualified IR.Common as C
import qualified IR.Name   as Name

moduleToText :: Module -> LT.Text
moduleToText mod = PP.displayT $ PP.renderPretty 0.4 80 (format mod)

-- | Types which can be rendered as haskell source code.
--
-- Note well: while format returns a Doc, it is not safe to render it using
-- wl-pprint's "compact" output; we rely on newline significance in some ways
-- without enforcing it.
--
-- It would be nice to fix this, but given that we don't currently expose this
-- via the library and only ever render it in the one place (in main), it isn't
-- a huge priority.
class Format a where
    format :: a -> PP.Doc

instance Format Module where
    format Module{modName, modLangPragmas, modDecls, modExports, modImports} = vcat
        [ vcat [ "{-# LANGUAGE " <> PP.textStrict ext <> " #-}" | ext <- modLangPragmas ]
        -- The generated code sometimes triggers these warnings, but they're nothing to
        -- worry about.
        --
        -- Dodgy-exports comes up when we don't actaully generate any definitions to
        -- export, in which case GHC complains in the machine readable module alias that
        -- we're trying to re-export everything from a module with no-exports. This
        -- happens with e.g. c++.capnp, which only defines annotations.
        , "{-# OPTIONS_GHC -Wno-unused-imports #-}"
        , "{-# OPTIONS_GHC -Wno-dodgy-exports #-}"
        , "{-# OPTIONS_GHC -Wno-unused-matches #-}"
        , "{-# OPTIONS_GHC -Wno-orphans #-}"
        , "{-# OPTIONS_GHC -Wno-unticked-promoted-constructors #-}"
        , "{-# OPTIONS_GHC -Wno-name-shadowing #-}"
        , hcat
            [ "module "
            , PP.textStrict $ mconcat $ intersperse "." $ map Name.renderUnQ modName
            , case modExports of
                Nothing -> ""
                Just exports ->
                    PP.tupled (map format exports)
            , " where"
            ]
        , vcat $ map format modImports
        -- We import many things, including the prelude, qualified under the
        -- "Std_" namespace, so that they don't collide with names in the
        -- generated code; see issue #58.
        , vcat $ map format
            [ ImportAs { importAs = "Std_", parts = ["Prelude"] }
            , ImportAs { importAs = "Std_", parts = ["Data", "Word"] }
            , ImportAs { importAs = "Std_", parts = ["Data", "Int"] }
            ]
        -- ...but there are a couple operators we still want unqaulified:
        , "import Prelude ((<$>), (<*>), (>>=))"
        , vcat $ map format modDecls
        ]

instance Format Export where
    format (ExportMod parts) =
        "module " <> PP.textStrict (mconcat $ intersperse "." $ map Name.renderUnQ parts)
    format (ExportLCtors name) = format name <> "(..)"
    format (ExportGCtors name) = format name <> "(..)"
    format (ExportGName  name) = format name
    format (ExportLName  name) = format name

instance Format Decl where
    format (DcData d) = format d
    format DcValue{typ, def=def@DfValue{name}} = vcat
        [ hcat [ format name, " :: ", format typ ]
        , format def
        ]
    format DcInstance{ctx, typ, defs} = hcat
        [ "instance "
        , format (TCtx ctx typ)
        , whereBlock defs
        ]
    format (DcTypeInstance alias orig) = hcat
        [ "type instance "
        , format alias
        , " = "
        , format orig
        ]
    format DcClass{ctx, name, params, funDeps, decls} = hcat
        [ "class "
        , format $
            TCtx ctx $
                TApp
                    (TLName name)
                    [TLName (Name.unQToLocal p) | p <- params]
        , formatFunDeps funDeps
        , whereBlock decls
        ]

formatFunDeps :: [(T.Text, T.Text)] -> PP.Doc
formatFunDeps [] = ""
formatFunDeps deps = mconcat
    [ " | "
    , mconcat $ intersperse ", "
        [ PP.textStrict a <> " -> " <> PP.textStrict b
        | (a, b) <- deps
        ]
    ]

whereBlock :: Format a => [a] -> PP.Doc
whereBlock [] = ""
whereBlock xs = vcat
    [ " where"
    , indent $ vcat $ map format xs
    ]

instance Format ClassDecl where
    format (CdValueDecl name typ) = hcat [ format name, " :: ", format typ ]
    format (CdValueDef def)       = format def
    format (CdMinimal names) = hcat
        [ "{-# MINIMAL "
        , hcat $ PP.punctuate PP.comma (map format names)
        , " #-}"
        ]

instance Format InstanceDef where
    format (IdData d)  = format d
    format (IdValue d) = format d
    format (IdType d)  = format d

instance Format TypeAlias where
    format (TypeAlias name params value) = hcat
        [ "type "
        , format name
        , " "
        , mconcat $ intersperse " " (map format params)
        , " = "
        , format value
        ]

instance Format DataDecl where
    format Data{dataName, typeArgs, dataVariants, dataNewtype, derives} = vcat
        [ hcat
            [ if dataNewtype
                then "newtype "
                else "data "
            , format dataName
            , " "
            , mconcat $ intersperse " " $ map format typeArgs
            ]
        , indent $ vcat
            [ case dataVariants of
                (d:ds) -> vcat $ ("= " <> format d) : map (("| " <>) . format) ds
                []     -> ""
            , formatDerives derives
            ]
        ]

instance Format ValueDef where
    format DfValue{name, value, params} = hcat
        [ format name
        , " "
        , hcat $ intersperse " " $ map format params
        , " = "
        , format value
        ]

instance Format Exp where
    format (EApp e es) = hcat
        [ "("
        , hcat $ intersperse " " $ map format (e:es)
        , ")"
        ]
    format (EFApp e []) = format e
    format (EFApp e es) = hcat
        [ "("
        , format e
        , PP.encloseSep " <$> " ")" " <*> " $ map format es
        ]
    format (EGName e) = format e
    format (ELName e) = format e
    format (EInt n) = fromString (show n)
    format (EDo ds ex) = vcat
        [ "(do"
        , indent $ vcat (map format ds ++ [format ex, ")"])
        ]
    format (EBind x f) = PP.parens (format x <> " >>= " <> format f)
    format (ETup es) = PP.tupled (map format es)
    format (ECase ex arms) = vcat
        [ hcat [ "case ", format ex, " of"]
        , indent $ vcat
            [ vcat
                [ hcat [ format p, " ->" ]
                , indent (format e)
                ]
            | (p, e) <- arms
            ]
        ]
    format (ETypeAnno e ty) = PP.parens $ hcat
        [ format e
        , " :: "
        , format ty
        ]
    format (EBytes bytes) = fromString (show bytes)
    format (ELambda params body) = PP.parens $ hcat
        [ "\\"
        , hcat (PP.punctuate " " (map format params))
        , " -> "
        , format body
        ]
    format (ERecord old updates) =
        format old <> PP.encloseSep "{" "}" ","
            [ hcat [ format name, " = ", format value ]
            | (name, value) <- updates
            ]
    format (ELabel name) = "#" <> format name

instance Format Do where
    format (DoBind var ex) = format var <> " <- " <> format ex
    format (DoE ex)        = format ex

instance Format Pattern where
    format (PVar v) = PP.textStrict v
    format (PLCtor c ps) = hcat
        [ "("
        , mconcat $ intersperse " " (format c : map format ps)
        , ")"
        ]
    format (PGCtor c ps) = hcat
        [ "("
        , mconcat $ intersperse " " (format c : map format ps)
        , ")"
        ]
    format (PInt n) = fromString (show n)
    format (PLRecordWildCard name) = format name <> "{..}"

formatDerives :: [Name.UnQ] -> PP.Doc
formatDerives [] = ""
formatDerives ds = "deriving" <> PP.tupled (map format ds)

instance Format DataVariant where
    format DataVariant{dvCtorName, dvArgs} =
        hcat [ format dvCtorName, " ", format dvArgs ]

instance Format DataArgs where
    format (APos types) =
        mconcat $ intersperse " " (map format types)
    format (ARec fields) = PP.line <> indent
        (PP.encloseSep
            "{" "}" ","
            [ format name <> " :: " <> format ty | (name, ty) <- fields ]
        )

instance Format Type where
    format (TGName ty) = format ty
    format (TLName ty) = format ty
    format (TVar txt)  = PP.textStrict txt
    format (TApp f xs) =
        "(" <> mconcat (intersperse " " $ map format (f:xs)) <> ")"
    format (TFn types) =
        mconcat $ intersperse " -> " $ map format types
    format (TCtx[] ty) = format ty
    format (TCtx constraints ty) =
        PP.tupled (map format constraints) <> " => " <> format ty
    format (TPrim ty) = format ty
    format TUnit = "()"
    format (TKindAnnotated ty kind) =
        "(" <> format ty <> " :: " <> format kind <> ")"
    format (TString str) = fromString $ show str

instance Format Name.GlobalQ where
    format Name.GlobalQ{local, globalNS=Name.NS parts} =
        mconcat
            [ mconcat $ intersperse "." (map PP.textStrict parts)
            , "."
            , format local
            ]

instance Format Name.LocalQ where
    format = PP.textStrict . Name.renderLocalQ

instance Format Name.UnQ where
    format = PP.textStrict . Name.renderUnQ


instance Format Import where
    format ImportAs{importAs, parts} = hcat
        [ "import qualified "
        , implodeNS parts
        , " as "
        , format importAs
        ]
    format ImportQual{ parts } = hcat [ "import qualified ", implodeNS parts ]
    format ImportAll { parts } = hcat [ "import ", implodeNS parts ]

implodeNS :: Format a => [a] -> PP.Doc
implodeNS parts = mconcat $ intersperse "." (map format parts)

instance Format C.PrimWord where
    format C.PrimBool = "Std_.Bool"
    format (C.PrimInt (C.IntType sign sz)) =
        let szDoc = fromString $ show $ C.sizeBits sz
            typePrefix = case sign of
                C.Signed   -> "Int"
                C.Unsigned -> "Word"
        in
        "Std_." <> typePrefix <> szDoc
    format C.PrimFloat32 = "Std_.Float"
    format C.PrimFloat64 = "Std_.Double"

-- | Indent the argument by four spaces.
indent :: PP.Doc -> PP.Doc
indent = PP.indent 4
