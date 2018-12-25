module Mongo

import Common
import BSon
import ISon

%lib     C "mongoc-1.0"
%link    C "idris_mongo.o"
%include C "idris_mongo.h"

%access export

init : () -> IO ()
init () = foreign FFI_C "idris_mongoc_init" (IO ())

cleanUp : () -> IO ()
cleanUp () = foreign FFI_C "idris_mongoc_cleanup" (IO ())

public export
data URI = MkURI CData

uri : String -> IO (Maybe URI)
uri uriString = do
  uri <- foreign FFI_C "idris_mongoc_uri_new_with_error"
    (String -> IO CData) uriString
  isError <- isCDataPtrNull uri
  case isError of
    True => pure Nothing
    False => pure $ Just $ MkURI uri
