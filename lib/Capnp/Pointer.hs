-- |
-- Module: Capnp.Pointer
-- Description: Support for parsing/serializing capnproto pointers
--
-- This module provides support for parsing and serializing capnproto pointers.
-- This is a low-level module; most users will not need to call it directly.
module Capnp.Pointer
  ( Ptr (..),
    ElementSize (..),
    EltSpec (..),
    parsePtr,
    parsePtr',
    serializePtr,
    serializePtr',
    parseEltSpec,
    serializeEltSpec,
  )
where

import Capnp.Bits
import Data.Bits
import Data.Int
import Data.Word

-- | A 'Ptr' represents the information in a capnproto pointer.
data Ptr
  = -- | @'StructPtr' off dataSz ptrSz@ is a pointer to a struct
    -- at offset @off@ in words from the end of the pointer, with
    -- a data section of size @dataSz@ words, and a pointer section
    -- of size @ptrSz@ words.
    --
    -- Note that the value @'StructPtr' 0 0 0@ is illegal, since
    -- its encoding is reserved for the "null" pointer.
    StructPtr !Int32 !Word16 !Word16
  | -- | @'ListPtr' off eltSpec@ is a pointer to a list starting at
    -- offset @off@ in words from the end of the pointer. @eltSpec@
    -- encodes the C and D fields in the encoding spec; see 'EltSpec'
    -- for details
    ListPtr !Int32 !EltSpec
  | -- | @'FarPtr' twoWords off segment@ is a far pointer, whose landing
    -- pad is:
    --
    -- * two words iff @twoWords@,
    -- * @off@ words from the start of the target segment, and
    -- * in segment id @segment@.
    FarPtr !Bool !Word32 !Word32
  | -- | @'CapPtr' id@ is a pointer to the capability with the id @id@.
    CapPtr !Word32
  deriving (Show, Eq)

-- | The element size field in a list pointer.
data ElementSize
  = Sz0
  | Sz1
  | Sz8
  | Sz16
  | Sz32
  | Sz64
  | SzPtr
  deriving (Show, Eq, Enum)

-- | A combination of the C and D fields in a list pointer, i.e. the element
-- size, and either the number of elements in the list, or the total number
-- of /words/ in the list (if size is composite).
data EltSpec
  = -- | @'EltNormal' size len@ is a normal (non-composite) element type
    -- (C /= 7). @size@ is the size of the elements, and @len@ is the
    -- number of elements in the list.
    EltNormal !ElementSize !Word32
  | -- | @EltComposite len@ is a composite element (C == 7). @len@ is the
    -- length of the list in words.
    EltComposite !Int32
  deriving (Show, Eq)

-- | @'parsePtr' word@ parses word as a capnproto pointer. A null pointer is
-- parsed as 'Nothing'.
parsePtr :: Word64 -> Maybe Ptr
parsePtr 0 = Nothing
parsePtr p = Just (parsePtr' p)

-- | @'parsePtr'' word@ parses @word@ as a capnproto pointer. It ignores
-- nulls, returning them the same as @(StructPtr 0 0 0)@.
parsePtr' :: Word64 -> Ptr
parsePtr' word =
  case bitRange word 0 2 :: Word64 of
    0 ->
      StructPtr
        (i30 (lo word))
        (bitRange word 32 48)
        (bitRange word 48 64)
    1 ->
      ListPtr
        (i30 (lo word))
        (parseEltSpec word)
    2 ->
      FarPtr
        (toEnum (bitRange word 2 3))
        (bitRange word 3 32)
        (bitRange word 32 64)
    3 -> CapPtr (bitRange word 32 64)
    _ -> error "unreachable"

-- | @'serializePtr' ptr@ serializes the pointer as a 'Word64', translating
-- 'Nothing' to a null pointer.
--
-- This also changes the offset of zero-sized struct pointers to -1, to avoid
-- them being interpreted as null.
serializePtr :: Maybe Ptr -> Word64
serializePtr Nothing = 0
serializePtr (Just p@(StructPtr (-1) 0 0)) =
  serializePtr' p
serializePtr (Just (StructPtr _ 0 0)) =
  -- We need to handle this specially, for two reasons.
  --
  -- First, if the offset is zero, the the normal encoding would be interpreted
  -- as null. We can get around this by changing the offset to -1, which will
  -- point immediately before the pointer, which is always a valid position --
  -- and since the size is zero, we can stick it at any valid position.
  --
  -- Second, the canonicalization algorithm requires that *all* zero size structs
  -- are encoded this way, and doing this for all offsets, rather than only zero
  -- offsets, avoids needing extra logic elsewhere.
  serializePtr' (StructPtr (-1) 0 0)
serializePtr (Just p) =
  serializePtr' p

-- | @'serializePtr'' ptr@ serializes the pointer as a Word64.
--
-- Unlike 'serializePtr', this results in a null pointer on the input
-- @(StructPtr 0 0 0)@, rather than adjusting the offset.
serializePtr' :: Ptr -> Word64
serializePtr' (StructPtr off dataSz ptrSz) =
  -- 0 .|.
  fromLo (fromI30 off)
    .|. (fromIntegral dataSz `shiftL` 32)
    .|. (fromIntegral ptrSz `shiftL` 48)
serializePtr' (ListPtr off eltSpec) =
  -- eltSz numElts) =
  1
    .|. fromLo (fromI30 off)
    .|. serializeEltSpec eltSpec
serializePtr' (FarPtr twoWords off segId) =
  2
    .|. (fromIntegral (fromEnum twoWords) `shiftL` 2)
    .|. (fromIntegral off `shiftL` 3)
    .|. (fromIntegral segId `shiftL` 32)
serializePtr' (CapPtr index) =
  3
    .|.
    -- (fromIntegral 0 `shiftL` 2) .|.
    (fromIntegral index `shiftL` 32)

-- | @'parseEltSpec' word@ reads the 'EltSpec' from @word@, which must be the
-- encoding of a list pointer (this is not verified).
parseEltSpec :: Word64 -> EltSpec
parseEltSpec word = case bitRange word 32 35 of
  7 -> EltComposite (i29 (hi word))
  sz -> EltNormal (toEnum sz) (bitRange word 35 64)

-- | @'serializeEltSpec' eltSpec@ serializes @eltSpec@ as a 'Word64'. all bits
-- which are not determined by the 'EltSpec' are zero.
serializeEltSpec :: EltSpec -> Word64
serializeEltSpec (EltNormal sz len) =
  (fromIntegral (fromEnum sz) `shiftL` 32)
    .|. (fromIntegral len `shiftL` 35)
serializeEltSpec (EltComposite words) =
  (7 `shiftL` 32)
    .|. fromHi (fromI29 words)
