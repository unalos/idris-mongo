#include "idris_rts.h"
#include <mongoc/mongoc.h>

int idris_mongoc_init_is_C_data_ptr_null(const CData c_data) {
  return (int) (NULL == c_data->data);
}

static void idris_mongoc_uri_finalizer(void * uri) { /* TODO */}

CData idris_mongoc_uri_new_with_error(const char * uri_string) {
  bson_error_t error;
  mongoc_uri_t * uri = mongoc_uri_new_with_error(uri_string, &error);
  return cdata_manage(uri, 0, idris_mongoc_uri_finalizer);
}
