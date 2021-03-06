module BSon

import Common
import BSonError

%lib     C "bson-1.0"
%link    C "idris_bson.o"
%include C "idris_bson.h"

%access export

public export
data BSon = MkBSon CData

bSon : () -> IO BSon
bSon () = do
  cData <- foreign FFI_C "idris_bson_new" (IO CData)
  pure $ MkBSon cData

private
handleSuccessCode : IO Int -> IO (Maybe ())
handleSuccessCode successIO = do
  success <- successIO
  case success of
    0 => pure Nothing
    _ => pure $ Just ()

appendUTF8 : BSon -> String -> String -> IO (Maybe ())
appendUTF8 (MkBSon bSon) key value =
  handleSuccessCode $ foreign FFI_C "idris_bson_append_utf8"
    (CData -> String -> String -> IO Int) bSon key value

appendDocument : BSon -> String -> BSon -> IO (Maybe ())
appendDocument (MkBSon bSon) key (MkBSon value) =
  handleSuccessCode $ foreign FFI_C "idris_bson_append_document"
    (CData -> String -> CData -> IO Int) bSon key value

appendInt32 : BSon -> String -> Bits32 -> IO (Maybe ())
appendInt32 (MkBSon bSon) key value =
  handleSuccessCode $ foreign FFI_C "idris_bson_append_int32"
    (CData -> String -> Bits32 -> IO Int) bSon key value

appendInt64 : BSon -> String -> Bits64 -> IO (Maybe ())
appendInt64 (MkBSon bSon) key value =
  handleSuccessCode $ foreign FFI_C "idris_bson_append_int64"
    (CData -> String -> Bits64 -> IO Int) bSon key value

||| Converts a JSon string to a BSon.
|||
||| @ jSon The JSon string.
fromJSon : (jSon : String) -> IO (Either BSonError BSon)
fromJSon jSon = do
  MkBSonError errorPlaceHolder <- newErrorPlaceHolder ()
  cData <- foreign FFI_C "idris_bson_new_from_json"
    (String -> CData -> IO CData) jSon errorPlaceHolder
  isError <- isCDataPtrNull cData
  case isError of
    True => pure $ Left $ MkBSonError errorPlaceHolder
    False => pure $ Right $ MkBSon cData

canonicalExtendedJSon : BSon -> IO String
canonicalExtendedJSon (MkBSon bSon) = do
  MkRaw jSon <- foreign FFI_C "idris_bson_as_canonical_extended_json"
    (CData -> IO (Raw String)) bSon
  pure jSon

relaxedExtendedJSon : BSon -> IO String
relaxedExtendedJSon (MkBSon bSon) = do
  MkRaw jSon <- foreign FFI_C "idris_bson_as_relaxed_extended_json"
    (CData -> IO (Raw String)) bSon
  pure jSon

export
data Iterator = MkIterator CData BSon
-- NOTE: We keep a reference to the BSon object on which we are iterating to
-- keep garbage collection sound: we do not want the object on which we are
-- iterating to be garbage collected before we have finished using the iterator.

iterInit : BSon -> IO Iterator
iterInit bSon = do
  let MkBSon bSonCData = bSon
  cData <- foreign FFI_C "idris_bson_iter_init" (CData -> IO CData) bSonCData
  pure $ MkIterator cData bSon

iterNext : Iterator -> IO Int
iterNext (MkIterator iterator _) =
  foreign FFI_C "idris_bson_iter_next" (CData -> IO Int) iterator

iterKey : Iterator -> IO String
iterKey (MkIterator iterator _) = do
  MkRaw key <- foreign FFI_C "idris_bson_iter_key" (CData -> IO (Raw String)) iterator
  pure key

iterType : Iterator -> IO Int
iterType (MkIterator iterator _) =
  foreign FFI_C "idris_bson_iter_type" (CData -> IO Int) iterator

typeUTF8 : IO Int
typeUTF8 = foreign FFI_C "idris_bson_type_utf8" (IO Int)

typeDocument : IO Int
typeDocument = foreign FFI_C "idris_bson_type_document" (IO Int)

typeInt32 : IO Int
typeInt32 = foreign FFI_C "idris_bson_type_int32" (IO Int)

typeInt64 : IO Int
typeInt64 = foreign FFI_C "idris_bson_type_int64" (IO Int)

iterUTF8 : Iterator -> IO String
iterUTF8 (MkIterator iterator _) = do
  MkRaw utf8 <- foreign FFI_C "idris_bson_iter_utf8"
    (CData -> IO (Raw String)) iterator
  pure utf8

UTF8Validate : String -> IO (Maybe ())
UTF8Validate string =
  handleSuccessCode $ foreign FFI_C "idris_bson_utf8_validate"
    (String -> IO Int) string

iterRecurse : Iterator -> IO (Maybe Iterator)
iterRecurse (MkIterator iterator bSon) = do
  childCData <- foreign FFI_C "idris_bson_iter_recurse"
    (CData -> IO CData) iterator
  isError <- isCDataPtrNull childCData
  case isError of
    True => pure Nothing
    False => pure $ Just $ MkIterator childCData bSon

iterInt32 : Iterator -> IO Bits32
iterInt32 (MkIterator iterator _) =
  foreign FFI_C "idris_bson_iter_int32"
    (CData -> IO Bits32) iterator

iterInt64 : Iterator -> IO Bits64
iterInt64 (MkIterator iterator _) =
  foreign FFI_C "idris_bson_iter_int64"
    (CData -> IO Bits64) iterator
