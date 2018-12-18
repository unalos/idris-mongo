#include <bson/bson.h>

static void idris_bson_finalizer(void * bson)
{
  free(bson);
}

CData idris_bson_init ()
{
  size_t b_size = sizeof(bson_t);
  bson_t * b = malloc(b_size);
  bson_init(b);
  return cdata_manage(b, b_size, idris_bson_finalizer);
}

void idris_bson_append_int32(const CData bson, const char * key, const int32_t value)
{
  bson_append_int32((bson_t *)bson->data, key, -1, value);
}
