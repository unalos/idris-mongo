#include "idris_rts.h"

const bool idris_mongoc_write_concern_append(const CData write_concern_cdata,
                                             const CData command_cdata);

const bool idris_mongoc_read_concern_append(const CData read_concern_cdata,
                                            const CData command_cdata);
