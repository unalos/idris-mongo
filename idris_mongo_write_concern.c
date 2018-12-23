#include "idris_rts.h"
#include <mongoc/mongoc.h>

static void idris_mongoc_write_concern_finalize(void * write_concern)
{
  mongoc_write_concern_destroy(write_concern);
}

const CData idris_mongoc_write_concern_new()
{
  mongoc_write_concern_t * write_concern = mongoc_write_concern_new();
  return cdata_manage(write_concern, 0, idris_mongoc_write_concern_finalize);
}
