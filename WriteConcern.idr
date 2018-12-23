module WriteConcern

import BSon

%lib C "mongoc-1.0"
%link C "idris_mongo_write_concern.o"
%include C "idris_mongo_write_concern.h"

%access export

WriteConcern : Type
WriteConcern = CData

writeConcern : () -> IO WriteConcern
writeConcern () = foreign FFI_C "idris_mongoc_write_concern_new" (IO CData)

append : BSon -> WriteConcern -> IO (Maybe ())
append (MkBSon command) writeConcern = do
  success <- foreign FFI_C "idris_mongoc_write_concern_append"
    (CData -> CData -> IO Int) writeConcern command
  case success of
    0 => pure Nothing
    _ => pure $ Just ()
