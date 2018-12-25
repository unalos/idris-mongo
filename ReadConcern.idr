module ReadConcern

import BSon

%lib     C "mongoc-1.0"
%link    C "idris_mongo_read_concern.o"
%include C "idris_mongo_read_concern.h"

%access export

public export
data ReadConcern = MkReadConcern CData

private
newReadConcern : () -> IO ReadConcern
newReadConcern () = do
  readConcern <- foreign FFI_C "idris_mongoc_read_concern_new" (IO CData)
  pure $ MkReadConcern readConcern

public export
data Level =
    LOCAL
  | MAJORITY
  | LINEARIZABLE
  | AVAILABLE
  | SNAPSHOT

private
levelLocal : IO String
levelLocal = do
  MkRaw code <- foreign FFI_C
    "idris_mongoc_read_concern_level_local" (IO (Raw String))
  pure code

private
levelMajority : IO String
levelMajority = do
  MkRaw code <- foreign FFI_C
    "idris_mongoc_read_concern_level_majority" (IO (Raw String))
  pure code

private
levelLinearizable : IO String
levelLinearizable = do
  MkRaw code <- foreign FFI_C
    "idris_mongoc_read_concern_level_linearizable" (IO (Raw String))
  pure code

private
levelAvailable : IO String
levelAvailable = do
  MkRaw code <- foreign FFI_C
    "idris_mongoc_read_concern_level_available" (IO (Raw String))
  pure code

private
levelSnapshot : IO String
levelSnapshot = do
  MkRaw code <- foreign FFI_C
    "idris_mongoc_read_concern_level_snapshot" (IO (Raw String))
  pure code

private total
levelCode : Level -> IO String
levelCode LOCAL = levelLocal
levelCode MAJORITY = levelMajority
levelCode LINEARIZABLE = levelLinearizable
levelCode AVAILABLE = levelAvailable
levelCode SNAPSHOT = levelSnapshot

private
setLevel : ReadConcern -> Level -> IO ()
setLevel (MkReadConcern readConcern) level = do
  code <- levelCode level
  foreign FFI_C "idris_mongoc_read_concern_set_level"
    (CData -> String -> IO ()) readConcern code

readConcern : {default Nothing level : Maybe Level} -> IO ReadConcern
readConcern {level} =
  do
    MkReadConcern readConcern <- newReadConcern ()
    () <- auxSetLevel level (MkReadConcern readConcern)
    pure $ MkReadConcern readConcern
  where
    auxSetLevel : Maybe Level -> ReadConcern -> IO ()
    auxSetLevel Nothing _ = pure ()
    auxSetLevel (Just level) readConcern = setLevel readConcern level
