#include "idris_rts.h"
#include <mongoc/mongoc.h>

static void idris_mongoc_read_concern_finalize(void * read_concern)
{
  mongoc_read_concern_destroy(read_concern);
}

CData idris_mongoc_read_concern_new()
{
  mongoc_read_concern_t * read_concern = mongoc_read_concern_new();
  return cdata_manage(read_concern, 0, idris_mongoc_read_concern_finalize);
}

VAL idris_mongoc_read_concern_level_local()
{
  return MKSTR(get_vm(), MONGOC_READ_CONCERN_LEVEL_LOCAL);
}

VAL idris_mongoc_read_concern_level_majority()
{
  return MKSTR(get_vm(), MONGOC_READ_CONCERN_LEVEL_MAJORITY);
}

VAL idris_mongoc_read_concern_level_linearizable()
{
  return MKSTR(get_vm(), MONGOC_READ_CONCERN_LEVEL_LINEARIZABLE);
}

VAL idris_mongoc_read_concern_level_available()
{
  return MKSTR(get_vm(), MONGOC_READ_CONCERN_LEVEL_AVAILABLE);
}

VAL idris_mongoc_read_concern_level_snapshot()
{
  return MKSTR(get_vm(), MONGOC_READ_CONCERN_LEVEL_SNAPSHOT);
}

void idris_mongoc_read_concern_set_level(const CData read_concern_cdata,
                                         const char * level)
{
  mongoc_read_concern_t * read_concern =
    (mongoc_read_concern_t *) read_concern_cdata->data;
  mongoc_read_concern_set_level(read_concern, level);
}
