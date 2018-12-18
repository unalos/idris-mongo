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
