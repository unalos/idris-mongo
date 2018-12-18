module Main

-- import CFFI

%include C "mongoc/mongoc.h"
%lib C "mongoc-1.0"

init : () -> IO ()
init () = foreign FFI_C "mongoc_init" (IO ())

cleanup : () -> IO ()
cleanup () = foreign FFI_C "mongoc_cleanup" (IO ())

main : IO ()
main = do
  () <- init ()
  () <- cleanup ()
  pure ()
