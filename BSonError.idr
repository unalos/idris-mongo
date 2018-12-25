module BSonError

%lib C "bson-1.0"
%link C "idris_mongo_bson_error.o"
%include C "idris_mongo_bson_error.h"

%access export

public export
data BSonError = MkBSonError CData

newErrorPlaceholder : () -> IO BSonError
newErrorPlaceholder () = do
  errorPlaceholder <- foreign FFI_C "idris_bson_error_new" (IO CData)
  pure $ MkBSonError errorPlaceholder

errorMessage : BSonError -> IO String
errorMessage (MkBSonError error) = do
  MkRaw message <- foreign FFI_C "idris_bson_error_message"
    (CData -> IO (Raw String)) error
  pure message

show : BSonError -> IO String
show error = errorMessage error
