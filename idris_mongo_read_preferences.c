#include "idris_rts.h"
#include <mongoc/mongoc.h>

int idris_mongoc_read_mode_primary()
{
  return MONGOC_READ_PRIMARY;
}

int idris_mongoc_read_mode_secondary()
{
  return MONGOC_READ_SECONDARY;
}

int idris_mongoc_read_mode_primary_preferred()
{
  return MONGOC_READ_PRIMARY_PREFERRED;
}

int idris_mongoc_read_mode_secondary_preferred()
{
  return MONGOC_READ_SECONDARY_PREFERRED;
}

int idris_mongoc_read_mode_nearest()
{
  return MONGOC_READ_NEAREST;
}

static void idris_mongoc_read_prefs_finalize(void * read_prefs)
{
  mongoc_read_prefs_destroy(read_prefs);
}

const CData idris_mongoc_read_prefs_new(int read_mode)
{
  mongoc_read_prefs_t * read_prefs = mongoc_read_prefs_new(read_mode);
  return cdata_manage(read_prefs, 0, idris_mongoc_read_prefs_finalize);
}
