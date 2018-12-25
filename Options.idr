module Options

import BSon
import ISon
import WriteConcern
import ReadConcern

%lib     C "mongoc-1.0"
%link    C "idris_mongo_options.o"
%include C "idris_mongo_options.h"

%access export

public export
data Options = MkOptions CData

private
writeConcernAppend : Options -> WriteConcern -> IO (Maybe ())
writeConcernAppend (MkOptions options) (MkWriteConcern writeConcern) = do
  success <- foreign FFI_C "idris_mongoc_write_concern_append"
    (CData -> CData -> IO Int) writeConcern options
  case success of
    0 => pure Nothing
    _ => pure $ Just ()

writeConcernOptions : WriteConcern -> IO (Maybe Options)
writeConcernOptions writeConcern = do
  let MkBSon bSon = bSon ()
  Just () <- writeConcernAppend (MkOptions bSon) writeConcern
    | Nothing => pure Nothing
  pure $ Just $ MkOptions bSon

private
readConcernAppend : Options -> ReadConcern -> IO (Maybe ())
readConcernAppend (MkOptions options) (MkReadConcern readConcern) = do
  success <- foreign FFI_C "idris_mongoc_read_concern_append"
    (CData -> CData -> IO Int) readConcern options
  case success of
    0 => pure Nothing
    _ => pure $ Just ()

readConcernOptions : ReadConcern -> Document -> IO (Maybe Options)
readConcernOptions readConcern optionsDocument = do
  Just (MkBSon bSon) <- bSon optionsDocument
    | Nothing => pure Nothing
  Just () <- readConcernAppend (MkOptions bSon) readConcern
    | Nothing => pure Nothing
  pure $ Just $ MkOptions bSon
