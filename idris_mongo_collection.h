#include "idris_rts.h"

CData idris_mongoc_client_get_collection(const CData client_cdata,
                                         const char * db_name,
                                         const char * name);

bool idris_mongoc_collection_drop_with_opts(const CData collection_cdata,
                                            const CData error_cdata);

bool idris_mongoc_collection_insert_one(const CData collection_cdata,
					const CData document_cdata,
					const CData options_cdata,
					const CData error_cdata);

bool idris_mongoc_collection_insert_many(const CData collection_cdata,
                                         const VAL documents,
                                         const int number_documents);
