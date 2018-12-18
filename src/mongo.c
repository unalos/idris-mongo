#include "idris_rts.h"
#include <mongoc/mongoc.h>

int idris_mongoc_init_is_C_data_ptr_null(const CData c_data)
{
  return (int) (NULL == c_data->data);
}

static void idris_mongoc_uri_finalizer(void * uri) {}

CData idris_mongoc_uri_new_with_error(const char * uri_string)
{
  mongoc_uri_t * uri = mongoc_uri_new_with_error(uri_string, NULL);
  return cdata_manage(uri, 0, idris_mongoc_uri_finalizer);
}

static void idris_mongoc_client_finalizer(void * client)
{
  mongoc_client_destroy((mongoc_client_t *) client);
}

CData idris_mongoc_client_new_from_uri(const CData uri)
{
  mongoc_client_t * client = mongoc_client_new_from_uri((mongoc_uri_t *) uri->data);
  return cdata_manage(client, 0, idris_mongoc_client_finalizer);
}

int idris_mongoc_client_set_appname(const CData client,
				    const char * appname)
{
  int success = mongoc_client_set_appname((mongoc_client_t *) client->data, appname);
  return success;
}

static void idris_mongoc_database_finalizer(void * database)
{
  mongoc_database_destroy((mongoc_database_t *) database);
} 

CData idris_mongoc_client_get_database(const CData client,
				       const char * name)
{
  mongoc_database_t * database = mongoc_client_get_database((mongoc_client_t *) client->data, name);
  return cdata_manage(database, 0, idris_mongoc_database_finalizer);
}

static void idris_mongoc_collection_finalizer(void * collection) {
  mongoc_collection_destroy((mongoc_collection_t *) collection);
}

CData idris_mongoc_client_get_collection(const CData clientCData,
					 const char * db,
					 const char * name)
{
  mongoc_client_t * client = (mongoc_client_t *) clientCData->data;
  mongoc_collection_t * collection = mongoc_client_get_collection(client, db, name);
  return cdata_manage(collection, 0, idris_mongoc_collection_finalizer);
}
