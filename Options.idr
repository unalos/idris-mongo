module Options

import BSon
import WriteConcern

%lib     C "mongoc-1.0"
%link    C "idris_mongo_options.o"
%include C "idris_mongo_options.h"

%access export

public export
data Options = MkOptions CData

private
append : Options -> WriteConcern -> IO (Maybe ())
append (MkOptions options) (MkWriteConcern writeConcern) = do
  success <- foreign FFI_C "idris_mongoc_write_concern_append"
    (CData -> CData -> IO Int) writeConcern options
  case success of
    0 => pure Nothing
    _ => pure $ Just ()

options : WriteConcern -> IO (Maybe Options)
options writeConcern = do
  MkBSon bSon <- bSon ()
  Just () <- append (MkOptions bSon) writeConcern
    | Nothing => pure Nothing
  pure $ Just $ MkOptions bSon
