#include "idris_rts.h"

int idris_mongoc_read_mode_primary();

int idris_mongoc_read_mode_secondary();

int idris_mongoc_read_mode_primary_preferred();

int idris_mongoc_read_mode_secondary_preferred();

int idris_mongoc_read_mode_nearest();

CData idris_mongoc_read_prefs_new(int read_mode);
