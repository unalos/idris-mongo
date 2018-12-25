module WriteConcern

import BSon

%lib     C "mongoc-1.0"
%link    C "idris_mongo_write_concern.o"
%include C "idris_mongo_write_concern.h"

%access export
%default covering

public export
data WriteConcern = MkWriteConcern CData

private
newWriteConcern : () -> IO WriteConcern
newWriteConcern () = do
  writeConcern <- foreign FFI_C "idris_mongoc_write_concern_new" (IO CData)
  pure $ MkWriteConcern writeConcern

private
setWMajority : WriteConcern -> IO ()
setWMajority (MkWriteConcern writeConcern) =
  foreign FFI_C "idris_mongoc_write_concern_set_wmajority"
    (CData -> IO ()) writeConcern

writeConcern : {default False wMajority : Bool} -> IO WriteConcern
writeConcern {wMajority} =
  do
    MkWriteConcern writeConcern <- newWriteConcern ()
    () <- auxSetWMajority wMajority (MkWriteConcern writeConcern)
    pure $ MkWriteConcern writeConcern
  where
    auxSetWMajority : Bool -> WriteConcern -> IO ()
    auxSetWMajority False _ = pure ()
    auxSetWMajority True writeConcern = setWMajority writeConcern
