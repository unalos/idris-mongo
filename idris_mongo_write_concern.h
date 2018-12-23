#include "idris_rts.h"

const CData idris_mongoc_write_concern_new();

void idris_mongoc_write_concern_set_wmajority(const CData write_concern_cdata);

const bool idris_mongoc_write_concern_append(const CData write_concern_cdata,
					     const CData command_cdata);
