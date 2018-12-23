#include "idris_rts.h"

CData idris_mongoc_client_get_collection(const CData client_cdata,
					 const char * db_name,
					 const char * name);

const bool idris_mongoc_collection_drop_with_opts(const CData collection_cdata);

const bool idris_mongoc_collection_insert_one(const CData collectionCData,
					      const CData documentCData);

const bool idris_mongoc_collection_insert_many(const CData collection_cdata,
					       const VAL documents,
					       const int number_documents);
