module Main

-- %default total

%lib C "mongoc-1.0"

%include C "mongo.c"

isPtrNull: Ptr -> IO Bool
isPtrNull ptr = do
  code <- foreign FFI_C "idris_mongoc_init_is_ptr_null" (Ptr -> IO Int) ptr
  pure $ case code of
    0 => False
    _ => True

init : () -> IO ()
init () = foreign FFI_C "mongoc_init" (IO ())

cleanup : () -> IO ()
cleanup () = foreign FFI_C "mongoc_cleanup" (IO ())

data URI = MkURI Ptr

uriFromString : String -> IO (Maybe URI)
uriFromString uri_string = do
  ptr <- foreign FFI_C "idris_mongoc_uri_new_with_error" (String -> IO Ptr) uri_string
  isError <- isPtrNull ptr
  pure $ case isError of
    True => Nothing
    False => Just $ MkURI ptr

connectionUri : IO String
connectionUri = do
  [_, uri] <- getArgs
  pure uri

main : IO ()
main = do
  () <- init ()
  uri_string <- connectionUri
  putStrLn uri_string
  Just uri <- uriFromString uri_string
  () <- cleanup ()
  pure ()
