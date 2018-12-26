module WriteConcern

import BSon

%lib     C "mongoc-1.0"
%link    C "idris_mongo_write_concern.o"
%include C "idris_mongo_write_concern.h"

%access export
%default covering

||| Write concern level.
|||
||| W_DEFAULT: By default, writes block awaiting acknowledgement from MongoDB.
||| Acknowledged write concern allows clients to catch network, duplicate key,
||| and other errors.
|||
||| W_UNACKNOWLEDGED: With this write concern, MongoDB does not acknowledge the
||| receipt of write operation. Unacknowledged is similar to errors ignored;
||| however, mongoc attempts to receive and handle network errors when possible.
|||
||| W_MAJORITY: Block until a write has been propagated to a majority of the
||| nodes in the replica set.
|||
||| W_NODES n: Block until a write has been propagated to at least n nodes in
||| the replica set.
public export
data WriteConcernW =
    W_DEFAULT
  | W_UNACKNOWLEDGED
  | W_MAJORITY
  | W_NODES Int -- greater or equal than 2

private
writeConcernWDefaultCode : IO Int
writeConcernWDefaultCode =
  foreign FFI_C "idris_mongoc_write_concern_w_default_code" (IO Int)

private
writeConcernWUnacknowledgedCode : IO Int
writeConcernWUnacknowledgedCode =
  foreign FFI_C "idris_mongoc_write_concern_w_unacknowledged_code" (IO Int)

private
writeConcernWMajorityCode : IO Int
writeConcernWMajorityCode =
  foreign FFI_C "idris_mongoc_write_concern_w_majority_code" (IO Int)

private
writeConcernWCode : WriteConcernW -> IO Int
writeConcernWCode W_DEFAULT = writeConcernWDefaultCode
writeConcernWCode W_UNACKNOWLEDGED = writeConcernWUnacknowledgedCode
writeConcernWCode W_MAJORITY = writeConcernWMajorityCode
writeConcernWCode (W_NODES nodes) = pure nodes

public export
data WriteConcern = MkWriteConcern CData

private
newWriteConcern : () -> IO WriteConcern
newWriteConcern () = do
  writeConcern <- foreign FFI_C "idris_mongoc_write_concern_new" (IO CData)
  pure $ MkWriteConcern writeConcern

private
setWriteConcernW : WriteConcern -> WriteConcernW -> IO ()
setWriteConcernW (MkWriteConcern writeConcern) w = do
  code <- writeConcernWCode w
  foreign FFI_C "idris_mongoc_write_concern_set_w"
    (CData -> Int -> IO ()) writeConcern code

private
setWriteConcernWTimeout : WriteConcern -> Int -> IO ()
setWriteConcernWTimeout (MkWriteConcern writeConcern) timeout = do
  foreign FFI_C "idris_mongoc_write_concern_set_wtimeout"
    (CData -> Int -> IO ()) writeConcern timeout

||| Specifies the level of acknowledgement required by the server for write
||| operations.
|||
||| @ w The acknowledgement level
||| @ timeout The write concern timeout. (0 specifies no timeout.)
writeConcern : {default W_DEFAULT w : WriteConcernW}
               -> {default 0 timeout : Int} -> IO WriteConcern
writeConcern {w} {timeout} =
  do
    writeConcern <- newWriteConcern ()
    () <- setWriteConcernW writeConcern w
    () <- setWriteConcernWTimeout writeConcern timeout
    pure $ writeConcern
