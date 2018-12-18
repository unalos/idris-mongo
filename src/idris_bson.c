#include <bson/bson.h>

void idris_bson_finalize(void * bson)
{
  free(bson);
}

bson_t * idris_bson_allocate()
{
  return malloc(sizeof(bson_t));
}

CData idris_bson_manage(bson_t * bson)
{
  return cdata_manage(bson, sizeof(bson_t), idris_bson_finalize);
}

CData idris_bson_init()
{
  bson_t * bson = idris_bson_allocate();
  bson_init(bson);
  return idris_bson_manage(bson);
}

void idris_bson_append_int32(const CData bson, const char * key, const int32_t value)
{
  bson_append_int32((bson_t *) bson->data, key, -1, value);
}

void idris_bson_append_utf8(const CData bson, const char * key, const char * value)
{
  bson_append_utf8((bson_t *) bson->data, key, -1, value, -1);
}

const char * idris_bson_as_canonical_extended_json(const CData bson)
{
  return bson_as_canonical_extended_json((bson_t *) bson->data, NULL);
}
