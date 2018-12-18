#include <mongoc/mongoc.h>

int idris_mongoc_init_is_ptr_null(const void * ptr) {
  return (int) (NULL == ptr);
}

mongoc_uri_t * idris_mongoc_uri_new_with_error(const char * uri_string) {
  bson_error_t error;
  return mongoc_uri_new_with_error(uri_string, &error);
}
