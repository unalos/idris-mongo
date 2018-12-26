#include "idris_rts.h"
#include <mongoc/mongoc.h>

static void idris_mongoc_collection_finalizer(void * collection) {
  mongoc_collection_destroy((mongoc_collection_t *) collection);
}

CData idris_mongoc_client_get_collection(const CData client_cdata,
					 const char * db_name,
					 const char * name)
{
  mongoc_client_t * client = (mongoc_client_t *) client_cdata->data;
  mongoc_collection_t * collection =
    mongoc_client_get_collection(client, db_name, name);
  return cdata_manage(collection, 0, idris_mongoc_collection_finalizer);
}

bool idris_mongoc_collection_drop_with_opts(const CData collection_cdata,
					    const CData error_cdata)
{
  mongoc_collection_t * collection =
    (mongoc_collection_t *) collection_cdata->data;
  bson_error_t * error = (bson_error_t *) error_cdata->data;
  return mongoc_collection_drop_with_opts(collection, NULL, error);
}

bool idris_mongoc_collection_insert_one(const CData collection_cdata,
                                        const CData document_cdata,
					const CData options_cdata)
{
  mongoc_collection_t * collection =
    (mongoc_collection_t *) collection_cdata->data;
  const bson_t * document = (const bson_t *) document_cdata->data;
  const bson_t * options = (const bson_t *) options_cdata->data;
  return mongoc_collection_insert_one(collection, document, options, NULL, NULL);
}

bool idris_mongoc_collection_insert_many(const CData collection_cdata,
                                         const VAL documents,
                                         const int number_documents)
{
  mongoc_collection_t * collection =
    (mongoc_collection_t *) collection_cdata->data;
  const bson_t ** documents_array = malloc(number_documents * sizeof(bson_t *));
  int index = 0;
  VAL cursor = documents;
  while (cursor->hdr.ty == CT_CON && cursor->hdr.u16 == 2)
    {
      documents_array[index] =
        (bson_t *) ((CDataC *) ((Con *) cursor)->args[0])->item->data;
      index++;
      cursor = ((Con *) cursor)->args[1];
    }
  return mongoc_collection_insert_many(collection, documents_array,
                                       number_documents, NULL, NULL, NULL);
}
