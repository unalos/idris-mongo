#include "idris_rts.h"
#include <mongoc/mongoc.h>
#include "idris_bson_manage.h"

void idris_mongoc_init()
{
  mongoc_init();
}

void idris_mongoc_cleanup()
{
  mongoc_cleanup();
}

static void idris_mongoc_uri_finalizer(void * uri) {}

CData idris_mongoc_uri_new_with_error(const char * uri_string)
{
  mongoc_uri_t * uri = mongoc_uri_new_with_error(uri_string, NULL);
  return cdata_manage(uri, 0, idris_mongoc_uri_finalizer);
}
