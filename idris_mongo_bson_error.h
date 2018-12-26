#include "idris_rts.h"

CData idris_bson_error_new();

int idris_bson_error_code(const CData error_cdata);

VAL idris_bson_error_message(const CData error_cdata);
