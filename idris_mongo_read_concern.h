#include "idris_rts.h"

CData idris_mongoc_read_concern_new();

VAL idris_mongoc_read_concern_level_local();

VAL idris_mongoc_read_concern_level_majority();

VAL idris_mongoc_read_concern_level_linearizable();

VAL idris_mongoc_read_concern_level_available();

VAL idris_mongoc_read_concern_level_snapshot();

void idris_mongoc_read_concern_set_level(const CData read_concern_cdata,
                                         const char * level);
