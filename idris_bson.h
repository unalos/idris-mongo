#include "idris_rts.h"

CData idris_bson_new();

bool idris_bson_append_utf8(const CData bson_cdata,
                                  const char * key,
                                  const char * value);

bool idris_bson_append_document(const CData bson_cdata,
                                      const char * key,
                                      const CData value_cdata);

bool idris_bson_append_int32(const CData bson_cdata,
                                   const char * key,
                                   const int32_t value);

bool idris_bson_append_int64(const CData bson_cdata,
                                   const char * key,
                                   const int64_t value);

CData idris_bson_new_from_json(const char * json);

VAL idris_bson_as_canonical_extended_json(const CData bson_cdata);

VAL idris_bson_as_relaxed_extended_json(const CData bson_cdata);

CData idris_bson_iter_init(const CData bson_cdata);

bool idris_bson_iter_next(const CData iter_cdata);

const char * idris_bson_iter_key(const CData iter_cdata);

int idris_bson_iter_type(const CData iter_cdata);

int idris_bson_type_utf8();

int idris_bson_type_document();

int idris_bson_type_int32();

int idris_bson_type_int64();

bool idris_bson_utf8_validate(const char * utf8);

VAL idris_bson_iter_utf8(const CData iter_cdata);

CData idris_bson_iter_recurse(const CData iter_cdata);

int idris_bson_iter_int32(const CData iter_cdata);

int idris_bson_iter_int64(const CData iter_cdata);
