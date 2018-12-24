module BSon

import Common

%lib C "bson-1.0"
%link C "idris_bson.o"
%include C "idris_bson.h"

%access export

public export
data BSon = MkBSon CData

bSon : () -> IO BSon
bSon () = do
  cData <- foreign FFI_C "idris_bson_new" (IO CData)
  pure $ MkBSon cData

handleSuccessCode : IO Int -> IO (Maybe ())
handleSuccessCode successIO = do
  success <- successIO
  case success of
    0 => pure Nothing
    _ => pure $ Just ()

appendInt32 : BSon -> String -> Bits32 -> IO (Maybe ())
appendInt32 (MkBSon bSon) key value =
  handleSuccessCode $ foreign FFI_C "idris_bson_append_int32"
    (CData -> String -> Bits32 -> IO Int) bSon key value

appendInt64 : BSon -> String -> Bits64 -> IO (Maybe ())
appendInt64 (MkBSon bSon) key value =
  handleSuccessCode $ foreign FFI_C "idris_bson_append_int64"
    (CData -> String -> Bits64 -> IO Int) bSon key value

appendUTF8 : BSon -> String -> String -> IO (Maybe ())
appendUTF8 (MkBSon bSon) key value =
  handleSuccessCode $ foreign FFI_C "idris_bson_append_utf8"
    (CData -> String -> String -> IO Int) bSon key value

appendDocument : BSon -> String -> BSon -> IO (Maybe ())
appendDocument (MkBSon bSon) key (MkBSon value) =
  handleSuccessCode $ foreign FFI_C "idris_bson_append_document"
    (CData -> String -> CData -> IO Int) bSon key value

fromJSon : String -> IO (Maybe BSon)
fromJSon jSon = do
  cData <- foreign FFI_C "idris_bson_new_from_json" (String -> IO CData) jSon
  isError <- isCDataPtrNull cData
  case isError of
    True => pure Nothing
    False => pure (Just $ MkBSon cData)

canonicalExtendedJSon : BSon -> IO String
canonicalExtendedJSon (MkBSon bSon) = do
  MkRaw jSon <- foreign FFI_C "idris_bson_as_canonical_extended_json" (CData -> IO (Raw String)) bSon
  pure jSon

relaxedExtendedJSon : BSon -> IO String
relaxedExtendedJSon (MkBSon bSon) = do
  MkRaw jSon <- foreign FFI_C "idris_bson_as_relaxed_extended_json" (CData -> IO (Raw String)) bSon
  pure jSon

export
data Iterator = MkIterator CData

iterInit : BSon -> IO Iterator
iterInit (MkBSon bSon) = do
  cData <- foreign FFI_C "idris_bson_iter_init" (CData -> IO CData) bSon
  pure $ MkIterator cData

iterNext : Iterator -> IO Int
iterNext (MkIterator iterator) = do
  foreign FFI_C "idris_bson_iter_next" (CData -> IO Int) iterator

iterKey : Iterator -> IO String
iterKey (MkIterator iterator) = do
  foreign FFI_C "idris_bson_iter_key" (CData -> IO String) iterator

iterType : Iterator -> IO Int
iterType (MkIterator iterator) = do
  foreign FFI_C "idris_bson_iter_type" (CData -> IO Int) iterator

typeInt32 : IO Int
typeInt32 = foreign FFI_C "idris_bson_type_int32" (IO Int)

typeInt64 : IO Int
typeInt64 = foreign FFI_C "idris_bson_type_int64" (IO Int)

typeUTF8 : IO Int
typeUTF8 = foreign FFI_C "idris_bson_type_utf8" (IO Int)

typeDocument : IO Int
typeDocument = foreign FFI_C "idris_bson_type_document" (IO Int)

iterInt32 : Iterator -> IO Bits32
iterInt32 (MkIterator iterator) =
  foreign FFI_C "idris_bson_iter_int32"
    (CData -> IO Bits32) iterator

iterInt64 : Iterator -> IO Bits64
iterInt64 (MkIterator iterator) =
  foreign FFI_C "idris_bson_iter_int64"
    (CData -> IO Bits64) iterator

iterUTF8 : Iterator -> IO String
iterUTF8 (MkIterator iterator) = do
  MkRaw utf8 <- foreign FFI_C "idris_bson_iter_utf8"
    (CData -> IO (Raw String)) iterator
  pure utf8

UTF8Validate : String -> IO (Maybe ())
UTF8Validate string =
  handleSuccessCode $ foreign FFI_C "idris_bson_utf8_validate"
    (String -> IO Int) string

iterRecurse : Iterator -> IO (Maybe Iterator)
iterRecurse (MkIterator iterator) = do
  childCData <- foreign FFI_C "idris_bson_iter_recurse"
    (CData -> IO CData) iterator
  isError <- isCDataPtrNull childCData
  case isError of
    True => pure Nothing
    False => pure $ Just $ MkIterator childCData
