#include "idris_rts.h"

void idris_mongoc_init();

void idris_mongoc_cleanup();

CData idris_mongoc_uri_new_with_error(const char * uri_string);

CData idris_mongoc_client_new_from_uri(const CData uri);

int idris_mongoc_client_set_appname(const CData client,
				    const char * appname);

CData idris_mongoc_client_get_database(const CData clientCData,
				       const char * name);

CData idris_mongoc_client_get_collection(const CData clientCData,
					 const char * db_name,
					 const char * name);

CData idris_mongoc_client_command_simple(const CData clientCData,
					 const char * db_name,
					 const CData commandCData);

const bool idris_mongoc_collection_insert_one(const CData collectionCData,
					      const CData documentCData);

const bool idris_mongoc_collection_insert_many(const CData collection_cdata,
					       const VAL documents,
					       const int number_documents);
