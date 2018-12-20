module BSon

%lib C "bson-1.0"
%include C "idris_bson.c"
%access export

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

canonicalExtendedJSon : BSon -> IO String
canonicalExtendedJSon (MkBSon bson) =
  foreign FFI_C "idris_bson_as_canonical_extended_json" (CData -> IO String) bson

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
  OtherValue : Value

Show Value where
  show (UTF8Value string) = show string
  show (Int32Value int32) = show int32

private
iterUTF8 : Iterator -> IO String
iterUTF8 (MkIterator iterator) =
  foreign FFI_C "idris_bson_iter_utf8" (CData -> IO String) iterator

private
iterInt32 : Iterator -> IO Bits32
iterInt32 (MkIterator iterator) =
  foreign FFI_C "idris_bson_iter_int32" (CData -> IO Bits32) iterator

private
iterValue : Iterator -> IO Value
iterValue iterator = do
  typeCode <- iterType iterator
  utf8 <- typeUTF8
  int32 <- typeInt32
  if typeCode == utf8
  then
    do utf8Value <- iterUTF8 iterator
       pure $ UTF8Value utf8Value
  else if typeCode == int32
  then
    do int32Value <- iterInt32 iterator
       pure $ Int32Value int32Value
  else pure OtherValue

fold : (acc -> String -> Value -> acc) -> acc -> BSon -> IO acc
fold func init bSon =
  do iterator <- iterInit bSon
     aux iterator init
  where
    aux : Iterator -> acc -> IO acc
    aux iterator acc = do
      code <- iterNext iterator
      case code of
        0 => pure acc
        _ => do
          key <- iterKey iterator
          value <- iterValue iterator
          aux iterator (func acc key value)
