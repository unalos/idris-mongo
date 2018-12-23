#include "idris_rts.h"

void idris_mongoc_init();

void idris_mongoc_cleanup();

CData idris_mongoc_uri_new_with_error(const char * uri_string);
