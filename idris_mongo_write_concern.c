#include "idris_rts.h"
#include <mongoc/mongoc.h>

int idris_mongoc_write_concern_w_default_code()
{
  return MONGOC_WRITE_CONCERN_W_DEFAULT;
}

int idris_mongoc_write_concern_w_unacknowledged_code()
{
  return MONGOC_WRITE_CONCERN_W_UNACKNOWLEDGED;
}

int idris_mongoc_write_concern_w_majority_code()
{
  return MONGOC_WRITE_CONCERN_W_MAJORITY;
}

static void idris_mongoc_write_concern_finalize(void * write_concern)
{
  mongoc_write_concern_destroy(write_concern);
}

CData idris_mongoc_write_concern_new()
{
  mongoc_write_concern_t * write_concern = mongoc_write_concern_new();
  return cdata_manage(write_concern, 0, idris_mongoc_write_concern_finalize);
}

void idris_mongoc_write_concern_set_w(const CData write_concern_cdata,
				      const int w)
{
  mongoc_write_concern_t * write_concern = (mongoc_write_concern_t *) write_concern_cdata->data;
  mongoc_write_concern_set_w(write_concern, w);
}

void idris_mongoc_write_concern_set_wtimeout(const CData write_concern_cdata,
					    const int timeout)
{
  mongoc_write_concern_t * write_concern = (mongoc_write_concern_t *) write_concern_cdata->data;
  mongoc_write_concern_set_wtimeout(write_concern, timeout);
}
