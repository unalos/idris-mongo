#include "idris_rts.h"

int idris_common_is_C_data_ptr_null(const CData c_data)
{
  return (int) (NULL == c_data->data);
}
