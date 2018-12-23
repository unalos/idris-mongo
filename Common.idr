module Common

%link C "idris_common.o"
%include C "idris_common.h"

%access export

isCDataPtrNull : CData -> IO Bool
isCDataPtrNull cData = do
  success <- foreign FFI_C "idris_common_is_C_data_ptr_null"
    (CData -> IO Int) cData
  case success of
    0 => pure False
    _ => pure True
