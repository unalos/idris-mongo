#include "idris_rts.h"

const CData idris_mongoc_read_concern_new();

const VAL idris_mongoc_read_concern_level_local();

const VAL idris_mongoc_read_concern_level_majority();

const VAL idris_mongoc_read_concern_level_linearizable();

const VAL idris_mongoc_read_concern_level_available();

const VAL idris_mongoc_read_concern_level_snapshot();

void idris_mongoc_read_concern_set_level(const CData read_concern_cdata,
                                         const char * level);
