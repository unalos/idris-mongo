#include "idris_rts.h"
#include <bson/bson.h>

bson_t * idris_bson_allocate()
{
  return malloc(sizeof(bson_t));
}

void idris_bson_finalize(void * bson)
{
  free(bson);
}

const CData idris_bson_manage(bson_t * bson)
{
  return cdata_manage(bson, sizeof(bson_t), idris_bson_finalize);
}

const CData idris_bson_init()
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

const VAL idris_bson_as_canonical_extended_json(const CData bson)
{
  size_t length;
  char * json = bson_as_canonical_extended_json((const bson_t *) bson->data, &length);
  const VAL raw_json = MKSTRlen(get_vm(), json, length);
  bson_free(json);
  return raw_json;
}

const char * idris_bson_as_relaxed_extended_json(const CData bson)
{
  return bson_as_relaxed_extended_json((const bson_t *) bson->data, NULL);
}

bson_iter_t * idris_bson_iter_allocate()
{
  return malloc(sizeof(bson_iter_t));
}

void idris_bson_iter_finalize(void * iter)
{
  free(iter);
}

const CData idris_bson_iter_manage(bson_iter_t * iter)
{
  return cdata_manage(iter, sizeof(bson_iter_t), idris_bson_iter_finalize);
}

const CData idris_bson_iter_init(const CData bson)
{
  bson_iter_t * iter = idris_bson_iter_allocate();
  bson_iter_init(iter, (const bson_t *) bson->data);
  return idris_bson_iter_manage(iter);
}

const bool idris_bson_iter_next(const CData iter)
{
  return bson_iter_next((bson_iter_t *) iter->data);
}

const char * idris_bson_iter_key(const CData iter)
{
  return bson_iter_key((const bson_iter_t *) iter->data);
}

const int idris_bson_iter_type(const CData iter)
{
  return (int) bson_iter_type((const bson_iter_t *) iter->data);
}

const int idris_bson_type_utf8()
{
  return (int) BSON_TYPE_UTF8;
}

const int idris_bson_type_int32()
{
  return (int) BSON_TYPE_INT32;
}

const char * idris_bson_iter_utf8(const CData iter)
{
  return bson_iter_utf8((const bson_iter_t *) iter->data, NULL);
}

const int idris_bson_iter_int32(const CData iter)
{
  return bson_iter_int32((const bson_iter_t *) iter->data);
}
