module Main

-- import CFFI

%include C "mongoc/mongoc.h"
%lib C "mongoc-1.0"

init : () -> IO ()
init () = foreign FFI_C "mongoc_init" (IO ())

main : IO ()
main = do
  () <- init ()
  putStrLn "exiting"
