#include "idris_rts.h"
#include <bson/bson.h>

static void noop() {}

void idris_bson_finalize(void * bson)
{
  bson_destroy(bson);
}

const CData idris_bson_manage(bson_t * bson)
{
  return cdata_manage(bson, sizeof(bson_t), idris_bson_finalize);
}

const CData idris_bson_new()
{
  bson_t * bson = bson_new();
  return idris_bson_manage(bson);
}

const bool idris_bson_append_utf8(const CData bson_cdata,
				                          const char * key,
				                          const char * value)
{
  return bson_append_utf8((bson_t *) bson_cdata->data, key, -1, value, -1);
}

const bool idris_bson_append_document(const CData bson_cdata,
                                      const char * key,
                                      const CData value_cdata)
{
  bson_t * bson = (bson_t *) bson_cdata->data;
  const bson_t * value = (const bson_t *) value_cdata->data;
  return bson_append_document(bson, key, -1, value);
}

const bool idris_bson_append_int32(const CData bson_cdata,
				   const char * key,
				   const int32_t value)
{
  return bson_append_int32((bson_t *) bson_cdata->data, key, -1, value);
}

const bool idris_bson_append_int64(const CData bson_cdata,
				                           const char * key,
				                           const int64_t value)
{
  return bson_append_int64((bson_t *) bson_cdata->data, key, -1, value);
}

const CData idris_bson_new_from_json(const char * json)
{
  bson_t * bson = bson_new_from_json((const uint8_t *) json, -1, NULL);
  return cdata_manage(bson, sizeof(bson_t), idris_bson_finalize);
}

const VAL idris_bson_as_canonical_extended_json(const CData bson)
{
  size_t length;
  char * json = bson_as_canonical_extended_json((const bson_t *) bson->data, &length);
  const VAL raw_json = MKSTRlen(get_vm(), json, length);
  bson_free(json);
  return raw_json;
}

const VAL idris_bson_as_relaxed_extended_json(const CData bson)
{
  size_t length;
  char * json = bson_as_relaxed_extended_json((const bson_t *) bson->data, &length);
  const VAL raw_json = MKSTRlen(get_vm(), json, length);
  bson_free(json);
  return raw_json;
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

const int idris_bson_type_document()
{
  return (int) BSON_TYPE_DOCUMENT;
}

const int idris_bson_type_int32()
{
  return (int) BSON_TYPE_INT32;
}

const int idris_bson_type_int64()
{
  return (int) BSON_TYPE_INT64;
}

const bool idris_bson_utf8_validate(const char * utf8)
{
  return bson_utf8_validate(utf8, strlen(utf8) ,false);
}

const VAL idris_bson_iter_utf8(const CData iter_cdata)
{
  uint32_t length;
  const bson_iter_t * iter = (const bson_iter_t *) iter_cdata->data;
  const char * utf8 = bson_iter_utf8(iter, &length);
  const VAL raw_utf8 = MKSTRlen(get_vm(), utf8, length);
  return raw_utf8;
}

const CData idris_bson_iter_recurse(const CData iter_cdata) {
  bson_iter_t * child;
  const bson_iter_t * iter = (const bson_iter_t *) iter_cdata->data;
  const bool success = bson_iter_recurse(iter, child);
  if (!success)
  {
    return cdata_manage(NULL, 0, noop);
  } else {
    return idris_bson_iter_manage(child);
  }
}

const int idris_bson_iter_int32(const CData iter_cdata)
{
  return bson_iter_int32((const bson_iter_t *) iter_cdata->data);
}

const int idris_bson_iter_int64(const CData iter_cdata)
{
  return bson_iter_int64((const bson_iter_t *) iter_cdata->data);
}
