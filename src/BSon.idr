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
appendInt32 bSon key value = case bSon of
  MkBSon bSonCData => foreign FFI_C "idris_bson_append_int32"
    (CData -> String -> Bits32 -> IO ()) bSonCData key value
