module ReadPreferences

%access private

public export
data ReadMode =
    PRIMARY
  | SECONDARY
  | PRIMARY_PREFERRED
  | SECONDARY_PREFERRED
  | NEAREST

data ReadModeCode = MkReadModeCode Int

readModePrimary : IO ReadModeCode
readModePrimary = do
  code <- foreign FFI_C "idris_mongoc_read_mode_primary" (IO Int)
  pure $ MkReadModeCode code

readModeSecondary : IO ReadModeCode
readModeSecondary = do
  code <- foreign FFI_C "idris_mongoc_read_mode_secondary" (IO Int)
  pure $ MkReadModeCode code

readModePrimaryPreferred : IO ReadModeCode
readModePrimaryPreferred = do
  code <- foreign FFI_C "idris_mongoc_read_mode_primary_preferred" (IO Int)
  pure $ MkReadModeCode code

readModeSecondaryPreferred : IO ReadModeCode
readModeSecondaryPreferred = do
  code <- foreign FFI_C "idris_mongoc_read_mode_secondary_preferred" (IO Int)
  pure $ MkReadModeCode code

readModeNearest : IO ReadModeCode
readModeNearest = do
  code <- foreign FFI_C "idris_mongoc_read_mode_nearest" (IO Int)
  pure $ MkReadModeCode code

total
readMode : ReadMode -> IO ReadModeCode
readMode PRIMARY             = readModePrimary
readMode SECONDARY           = readModeSecondary
readMode PRIMARY_PREFERRED   = readModePrimaryPreferred
readMode SECONDARY_PREFERRED = readModeSecondaryPreferred
readMode NEAREST             = readModeNearest

public export
data ReadPreferences = MkReadPreferences CData

export
readPreferences : ReadMode -> IO ReadPreferences
readPreferences mode = do
  MkReadModeCode code <- readMode mode
  preferences <- foreign FFI_C "idris_mongoc_read_prefs_new" (Int -> IO CData) code
  pure $ MkReadPreferences preferences
