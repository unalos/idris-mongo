#include "idris_rts.h"
#include <mongoc/mongoc.h>

int idris_mongoc_init_is_C_data_ptr_null(const CData c_data) {
  return (int) (NULL == c_data->data);
}

static void idris_mongoc_uri_finalizer(void * uri) { /* TODO */}

CData idris_mongoc_uri_new_with_error(const char * uri_string) {
  mongoc_uri_t * uri = mongoc_uri_new_with_error(uri_string, NULL);
  return cdata_manage(uri, 0, idris_mongoc_uri_finalizer);
}

static void idris_mongoc_client_finalizer(void * client) {
  mongoc_client_destroy((mongoc_client_t *) client);
}

CData idris_mongoc_client_new_from_uri(const CData uri) {
  mongoc_client_t * client = mongoc_client_new_from_uri((mongoc_uri_t *) uri->data);
  return cdata_manage(client, 0, idris_mongoc_client_finalizer);
}

int idris_mongoc_client_set_appname(const CData client, const char * appname) {
  int success = mongoc_client_set_appname((mongoc_client_t *) client->data, appname);
  return success;
}
