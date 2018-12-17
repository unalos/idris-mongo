module Main

-- import CFFI

%flag C "-I/usr/local/Cellar/mongo-c-driver/1.13.0/include/libbson-1.0"
%flag C "-I/usr/local/Cellar/mongo-c-driver/1.13.0/include/libmongoc-1.0"
%include C "mongoc/mongoc.h"
%lib C "mongoc-1.0"

init : () -> IO ()
init () = foreign FFI_C "mongoc_init" (IO ())

main : IO ()
main = do
  () <- init ()
  putStrLn "exiting"
