#include "idris_rts.h"
#include <bson/bson.h>

static void idris_bson_error_finalize(void * bson_error)
{
  free(bson_error);
}

const CData idris_bson_error_new()
{
  size_t size = sizeof(bson_error_t);
  const bson_error_t * bson_error = malloc(size);
  return cdata_manage(bson_error, size, idris_bson_error_finalize);
}
