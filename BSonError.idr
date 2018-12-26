module BSonError

%lib     C "bson-1.0"
%link    C "idris_mongo_bson_error.o"
%include C "idris_mongo_bson_error.h"

%access export

public export
data BSonError = MkBSonError CData

||| PRIVATE. Creates a new error placeholder.
|||
||| This is intended to be used by low-level binding code.
||| It is intended to be populated by C code with a given error.
newErrorPlaceHolder : () -> IO BSonError
newErrorPlaceHolder () = do
  errorPlaceHolder <- foreign FFI_C "idris_bson_error_new" (IO CData)
  pure $ MkBSonError errorPlaceHolder

||| Gets the BSon error code of a BSon error.
|||
||| @ error The BSon error.
errorCode : (error : BSonError) -> IO Int
errorCode (MkBSonError error) =
  foreign FFI_C "idris_bson_error_code" (CData -> IO Int) error

errorMessage : BSonError -> IO String
errorMessage (MkBSonError error) = do
  MkRaw message <- foreign FFI_C "idris_bson_error_message"
    (CData -> IO (Raw String)) error
  pure message

||| Shows a `BSonError`.
|||
||| @ error The error to show.
show : (error : BSonError) -> IO String
show error = do
  code <- errorCode error
  message <- errorMessage error
  pure $ (show code) ++ ": " ++ message
