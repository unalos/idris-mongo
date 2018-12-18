module BSon

%include C "bson.c"
%access export

data BSon = MkBSon CData

init : () -> IO BSon
init () = do
  cData <- foreign FFI_C "idris_bson_init" (IO CData)
  pure $ MkBSon cData
