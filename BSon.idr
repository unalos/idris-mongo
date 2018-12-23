module BSon

%lib C "bson-1.0"
%link C "idris_bson.o"
%include C "idris_bson.h"

%access export

private
isCDataPtrNull : CData -> IO Bool
isCDataPtrNull cData = do
  success <- foreign FFI_C "idris_bson_is_C_data_ptr_null"
    (CData -> IO Int) cData
  case success of
    0 => pure False
    _ => pure True

public export
data BSon = MkBSon CData

init : () -> IO BSon
init () = do
  cData <- foreign FFI_C "idris_bson_init" (IO CData)
  pure $ MkBSon cData

appendInt32 : BSon -> String -> Bits32 -> IO ()
appendInt32 (MkBSon bSon) key value =
  foreign FFI_C "idris_bson_append_int32" (CData -> String -> Bits32 -> IO ()) bSon key value

appendUTF8 : BSon -> String -> String -> IO ()
appendUTF8 (MkBSon bSon) key value =
  foreign FFI_C "idris_bson_append_utf8" (CData -> String -> String -> IO ()) bSon key value

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

private
data Iterator = MkIterator CData

private
iterInit : BSon -> IO Iterator
iterInit (MkBSon bSon) = do
  cData <- foreign FFI_C "idris_bson_iter_init" (CData -> IO CData) bSon
  pure $ MkIterator cData

private
iterNext : Iterator -> IO Int
iterNext (MkIterator iterator) = do
  foreign FFI_C "idris_bson_iter_next" (CData -> IO Int) iterator

private
iterKey : Iterator -> IO String
iterKey (MkIterator iterator) = do
  foreign FFI_C "idris_bson_iter_key" (CData -> IO String) iterator

private
iterType : Iterator -> IO Int
iterType (MkIterator iterator) = do
  foreign FFI_C "idris_bson_iter_type" (CData -> IO Int) iterator

private
typeUTF8 : IO Int
typeUTF8 = foreign FFI_C "idris_bson_type_utf8" (IO Int)

private
typeInt32 : IO Int
typeInt32 = foreign FFI_C "idris_bson_type_int32" (IO Int)

public export
data Value : Type where
  UTF8Value  : String -> Value
  Int32Value : Bits32 -> Value

Show Value where
  show (UTF8Value string) = show string
  show (Int32Value int32) = show int32

private
iterUTF8 : Iterator -> IO String
iterUTF8 (MkIterator iterator) = do
  MkRaw utf8 <- foreign FFI_C "idris_bson_iter_utf8" (CData -> IO (Raw String)) iterator
  pure utf8

private
UTF8Validate : String -> IO (Maybe ())
UTF8Validate string = do
  success <- foreign FFI_C "idris_bson_utf8_validate" (String -> IO Int) string
  case success of
    0 => pure Nothing
    1 => pure $ Just ()

private
iterInt32 : Iterator -> IO Bits32
iterInt32 (MkIterator iterator) =
  foreign FFI_C "idris_bson_iter_int32" (CData -> IO Bits32) iterator

private
cond : List (Lazy Bool, Lazy a) -> a -> a
cond [] def = def
cond ((x, y) :: xs) def = if x then y else cond xs def

private
iterValue : Iterator -> IO (Maybe Value)
iterValue iterator = do
  typeCode <- iterType iterator
  utf8 <- typeUTF8
  int32 <- typeInt32
  cond [
    (typeCode == utf8, do
      utf8Value <- iterUTF8 iterator
      Just () <- UTF8Validate utf8Value
        | Nothing => pure Nothing
      pure $ Just (UTF8Value utf8Value)),
    (typeCode == int32, do
      int32Value <- iterInt32 iterator
      pure $ Just (Int32Value int32Value))
  ] (pure Nothing)

fold : (acc -> String -> Value -> acc) -> acc -> BSon -> IO (Maybe acc)
fold func init bSon =
  do iterator <- iterInit bSon
     aux iterator init
  where
    aux : Iterator -> acc -> IO (Maybe acc)
    aux iterator acc = do
      code <- iterNext iterator
      case code of
        0 => pure $ Just acc
        _ => do
          key <- iterKey iterator
          Just value <- iterValue iterator
          aux iterator (func acc key value)
