#include <bson/bson.h>

static void idris_bson_finalizer(void * bson) {
  free(bson);
}

CData idris_bson_init () {
  size_t b_size = sizeof(bson_t);
  bson_t * b = malloc(b_size);
  return cdata_manage(b, b_size, idris_bson_finalizer);
}
