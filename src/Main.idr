module Main

-- %default total

%lib C "mongoc-1.0"

%include C "mongo.c"

isCDataPtrNull: CData -> IO Bool
isCDataPtrNull cData = do
  code <- foreign FFI_C "idris_mongoc_init_is_C_data_ptr_null" (CData -> IO Int) cData
  pure $ case code of
    0 => False
    _ => True

init : () -> IO ()
init () = foreign FFI_C "mongoc_init" (IO ())

cleanup : () -> IO ()
cleanup () = foreign FFI_C "mongoc_cleanup" (IO ())

data URI = MkURI CData

uri : String -> IO (Maybe URI)
uri uriString = do
  cData <- foreign FFI_C "idris_mongoc_uri_new_with_error" (String -> IO CData) uriString
  isError <- isCDataPtrNull cData
  pure $ case isError of
    True => Nothing
    False => Just $ MkURI cData

data Client = MkClient CData

client : URI -> IO Client
client uri = case uri of
  MkURI uriCData => do
    cData <- foreign FFI_C "idris_mongoc_client_new_from_uri" (CData -> IO CData) uriCData
    pure $ MkClient cData

connectionUri : IO String
connectionUri = do
  [_, uri] <- getArgs
  pure uri

main : IO ()
main = do
  () <- init ()
  uri_string <- connectionUri
  putStrLn uri_string
  Just uri <- uri uri_string
  () <- cleanup ()
  client <- client uri
  pure ()
