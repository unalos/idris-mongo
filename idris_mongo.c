#include "idris_rts.h"
#include <mongoc/mongoc.h>
#include "idris_bson_manage.h"

void idris_mongoc_init()
{
  mongoc_init();
}

void idris_mongoc_cleanup()
{
  mongoc_cleanup();
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

CData idris_mongoc_client_get_database(const CData clientCData,
				       const char * name)
{
  mongoc_client_t * client = (mongoc_client_t *) clientCData->data;
  mongoc_database_t * database = mongoc_client_get_database(client, name);
  return cdata_manage(database, 0, idris_mongoc_database_finalizer);
}

static void idris_mongoc_collection_finalizer(void * collection) {
  mongoc_collection_destroy((mongoc_collection_t *) collection);
}

CData idris_mongoc_client_get_collection(const CData clientCData,
					 const char * db_name,
					 const char * name)
{
  mongoc_client_t * client = (mongoc_client_t *) clientCData->data;
  mongoc_collection_t * collection = mongoc_client_get_collection(client, db_name, name);
  return cdata_manage(collection, 0, idris_mongoc_collection_finalizer);
}

CData idris_mongoc_client_command_simple(const CData clientCData,
				       const char * db_name,
				       const CData commandCData)
{
  mongoc_client_t * client = (mongoc_client_t *) clientCData->data;
  const bson_t * command = (bson_t *) commandCData->data;
  bson_t * reply = idris_bson_allocate();
  const int success = mongoc_client_command_simple(client, db_name, command, NULL, reply, NULL);
  if (!success) {
    idris_bson_finalize(reply);
    reply = NULL;
  }
  return idris_bson_manage(reply);
}

const bool idris_mongoc_collection_insert_one(const CData collectionCData,
                                              const CData documentCData)
{
  mongoc_collection_t * collection = (mongoc_collection_t *) collectionCData->data;
  bson_t * document = (bson_t *) documentCData->data;
  return mongoc_collection_insert_one(collection, document, NULL, NULL, NULL);
}

const bool idris_mongoc_collection_insert_many(const CData collection_cdata,
					       const VAL documents,
					       const int number_documents)
{
  mongoc_collection_t * collection = (mongoc_collection_t *) collection_cdata->data;
  const bson_t ** documents_array = malloc(number_documents * sizeof(bson_t *));
  int index = 0;
  VAL cursor = documents;
  while (cursor->hdr.ty == CT_CON && cursor->hdr.u16 == 2)
    {
      documents_array[index] = (bson_t *) ((CDataC *) ((Con *) cursor)->args[0])->item->data;
      index++;
      cursor = ((Con *) cursor)->args[1];
    }
  return mongoc_collection_insert_many(collection, documents_array, number_documents, NULL, NULL, NULL);
}
