#include "idris_rts.h"

bool idris_mongoc_write_concern_append(const CData write_concern_cdata,
                                             const CData command_cdata);

bool idris_mongoc_read_concern_append(const CData read_concern_cdata,
                                            const CData command_cdata);
