#include "idris_rts.h"
#include <mongoc/mongoc.h>
#include "idris_bson_manage.h"

static void idris_mongoc_client_finalizer(void * client)
{
  mongoc_client_destroy((mongoc_client_t *) client);
}

const CData idris_mongoc_client_new_from_uri(const CData uri_cdata)
{
  mongoc_client_t * client = mongoc_client_new_from_uri((mongoc_uri_t *) uri_cdata->data);
  return cdata_manage(client, 0, idris_mongoc_client_finalizer);
}

const int idris_mongoc_error_api_version_legacy()
{
  return MONGOC_ERROR_API_VERSION_LEGACY;
}

const int idris_mongoc_error_api_version_2()
{
  return MONGOC_ERROR_API_VERSION_2;
}

const int idris_mongoc_client_set_error_api(const CData client_cdata,
					    const int version)
{
  mongoc_client_t * client = (mongoc_client_t *) client_cdata->data;
  return mongoc_client_set_error_api(client, version);
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

CData idris_mongoc_client_command_simple(const CData clientCData,
                                       const char * db_name,
                                       const CData commandCData)
{
  mongoc_client_t * client = (mongoc_client_t *) clientCData->data;
  const bson_t * command = (bson_t *) commandCData->data;
  bson_t * reply = bson_new();
  const int success = mongoc_client_command_simple(client, db_name, command, NULL, reply, NULL);
  if (!success) {
    idris_bson_finalize(reply);
    reply = NULL;
  }
  return idris_bson_manage(reply);
}
