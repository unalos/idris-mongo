#include <bson/bson.h>

void idris_bson_finalize(void * bson);

bson_t * idris_bson_allocate();

const CData idris_bson_manage(bson_t * bson);
