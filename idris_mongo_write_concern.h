#include "idris_rts.h"

const int idris_mongoc_write_concern_w_default_code();

const int idris_mongoc_write_concern_w_unacknowledged_code();

const int idris_mongoc_write_concern_w_majority_code();

const CData idris_mongoc_write_concern_new();

void idris_mongoc_write_concern_set_w(const CData write_concern_cdata,
				      const int w);

void idris_mongoc_write_concern_set_wtimeout(const CData write_concern_cdata,
					     const int timeout);
