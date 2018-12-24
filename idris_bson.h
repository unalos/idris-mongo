#include "idris_rts.h"

const CData idris_bson_new();

const bool idris_bson_append_utf8(const CData bson_cdata,
                                  const char * key,
                                  const char * value);

const bool idris_bson_append_document(const CData bson_cdata,
                                      const char * key,
                                      const CData value_cdata);

const bool idris_bson_append_int32(const CData bson_cdata,
                                   const char * key,
                                   const int32_t value);

const bool idris_bson_append_int64(const CData bson_cdata,
                                   const char * key,
                                   const int64_t value);

const CData idris_bson_new_from_json(const char * json);

const VAL idris_bson_as_canonical_extended_json(const CData bson_cdata);

const VAL idris_bson_as_relaxed_extended_json(const CData bson_cdata);

const CData idris_bson_iter_init(const CData bson_cdata);

const bool idris_bson_iter_next(const CData iter_cdata);

const char * idris_bson_iter_key(const CData iter_cdata);

const int idris_bson_iter_type(const CData iter_cdata);

const int idris_bson_type_utf8();

const int idris_bson_type_document();

const int idris_bson_type_int32();

const int idris_bson_type_int64();

const bool idris_bson_utf8_validate(const char * utf8);

const VAL idris_bson_iter_utf8(const CData iter_cdata);

const CData idris_bson_iter_recurse(const CData iter_cdata);

const int idris_bson_iter_int32(const CData iter_cdata);

const int idris_bson_iter_int64(const CData iter_cdata);
