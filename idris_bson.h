#include "idris_rts.h"

const CData idris_bson_new();

void idris_bson_append_int32(const CData bson, const char * key, const int32_t value);

const bool idris_bson_append_utf8(const CData bson,
				  const char * key,
				  const char * value);

const CData idris_bson_new_from_json(const char * json);

const VAL idris_bson_as_canonical_extended_json(const CData bson);

const VAL idris_bson_as_relaxed_extended_json(const CData bson);

const CData idris_bson_iter_init(const CData bson);

const bool idris_bson_iter_next(const CData iter);

const char * idris_bson_iter_key(const CData iter);

const int idris_bson_iter_type(const CData iter);

const int idris_bson_type_utf8();

const int idris_bson_type_int32();

const VAL idris_bson_iter_utf8(const CData iter);

const bool idris_bson_utf8_validate(const char * utf8);

const int idris_bson_iter_int32(const CData iter);
