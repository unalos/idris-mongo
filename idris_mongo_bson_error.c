#include "idris_rts.h"
#include <mongoc/mongoc.h>

static void idris_bson_error_finalize(void * bson_error)
{
  free(bson_error);
}

CData idris_bson_error_new()
{
  size_t size = sizeof(bson_error_t);
  bson_error_t * bson_error = malloc(size);
  return cdata_manage(bson_error, size, idris_bson_error_finalize);
}

int idris_mongoc_bson_json_error_read_corrupt_js_code()
{
  return BSON_JSON_ERROR_READ_CORRUPT_JS;
}

int idris_mongoc_bson_json_error_read_invalid_param_code()
{
  return BSON_JSON_ERROR_READ_INVALID_PARAM;
}

int idris_mongoc_bson_json_error_read_cb_failure_code()
{
  return BSON_JSON_ERROR_READ_CB_FAILURE;
}

int idris_mongoc_bson_error_reader_bad_fd_code()
{
  return BSON_ERROR_READER_BADFD;
}

int idris_mongoc_mongoc_error_client_too_big_code()
{
  return MONGOC_ERROR_CLIENT_TOO_BIG;
}

int idris_mongoc_mongoc_error_client_authenticate_code()
{
  return MONGOC_ERROR_CLIENT_AUTHENTICATE;
}

int idris_mongoc_mongoc_error_client_no_acceptable_peer_code()
{
  return MONGOC_ERROR_CLIENT_NO_ACCEPTABLE_PEER;
}

int idris_mongoc_mongoc_error_client_in_exhaust_code()
{
  return MONGOC_ERROR_CLIENT_IN_EXHAUST;
}

int idris_mongoc_mongoc_error_client_session_failure_code()
{
  return MONGOC_ERROR_CLIENT_SESSION_FAILURE;
}

int idris_mongoc_mongoc_error_stream_name_resolution_code()
{
  return MONGOC_ERROR_STREAM_NAME_RESOLUTION;
}

int idris_mongoc_mongoc_error_stream_socket_code()
{
  return MONGOC_ERROR_STREAM_SOCKET;
}

int idris_mongoc_mongoc_error_stream_connect_code()
{
  return MONGOC_ERROR_STREAM_CONNECT;
}

int idris_mongoc_mongoc_error_protocol_invalid_reply_code()
{
  return MONGOC_ERROR_PROTOCOL_INVALID_REPLY;
}

int idris_mongoc_mongoc_error_protocol_bad_wire_version_code()
{
  return MONGOC_ERROR_PROTOCOL_BAD_WIRE_VERSION;
}

int idris_mongoc_mongoc_error_cursor_invalid_cursor_code()
{
  return MONGOC_ERROR_CURSOR_INVALID_CURSOR;
}

int idris_mongoc_mongoc_error_change_stream_no_resume_token_code()
{
  return MONGOC_ERROR_CHANGE_STREAM_NO_RESUME_TOKEN;
}

int idris_mongoc_mongoc_error_query_failure_code()
{
  return MONGOC_ERROR_QUERY_FAILURE;
}

int idris_mongoc_mongoc_error_bson_invalid_code()
{
  return MONGOC_ERROR_BSON_INVALID;
}

int idris_mongoc_mongoc_error_namespace_invalid_code()
{
  return MONGOC_ERROR_NAMESPACE_INVALID;
}

int idris_mongoc_mongoc_error_command_invalid_arg_code()
{
  return MONGOC_ERROR_COMMAND_INVALID_ARG;
}

int idris_mongoc_mongoc_error_command_protocol_bad_wire_version_code()
{
  return MONGOC_ERROR_PROTOCOL_BAD_WIRE_VERSION;
}

int idris_mongoc_mongoc_error_command_duplicate_key_code()
{
  return MONGOC_ERROR_DUPLICATE_KEY;
}

int idris_mongoc_mongoc_error_collection_insert_failed_code()
{
  return MONGOC_ERROR_COLLECTION_INSERT_FAILED;
}

int idris_mongoc_mongoc_error_collection_update_failed_code()
{
  return MONGOC_ERROR_COLLECTION_UPDATE_FAILED;
}

int idris_mongoc_mongoc_error_collection_delete_failed_code()
{
  return MONGOC_ERROR_COLLECTION_DELETE_FAILED;
}

int idris_mongoc_mongoc_error_gridfs_chunk_missing_code()
{
  return MONGOC_ERROR_GRIDFS_CHUNK_MISSING;
}

int idris_mongoc_mongoc_error_gridfs_corrupt_code()
{
  return MONGOC_ERROR_GRIDFS_CORRUPT;
}

int idris_mongoc_mongoc_error_gridfs_invalid_filename_code()
{
  return MONGOC_ERROR_GRIDFS_INVALID_FILENAME;
}

int idris_mongoc_mongoc_error_gridfs_protocol_error_code()
{
  return MONGOC_ERROR_GRIDFS_PROTOCOL_ERROR;
}

int idris_mongoc_mongoc_error_scram_protocol_error_code()
{
  return MONGOC_ERROR_SCRAM_PROTOCOL_ERROR;
}

int idris_mongoc_mongoc_error_server_selection_failure_code()
{
  return MONGOC_ERROR_SERVER_SELECTION_FAILURE;
}

int idris_mongoc_mongoc_error_transaction_invalid_code()
{
  return MONGOC_ERROR_TRANSACTION_INVALID_STATE;
}

int idris_mongoc_bson_error_json_code()
{
  return BSON_ERROR_JSON;
}

int idris_mongoc_bson_error_reader_code()
{
  return BSON_ERROR_READER;
}

int idris_mongoc_mongoc_error_client_code()
{
  return MONGOC_ERROR_CLIENT;
}

int idris_mongoc_mongoc_error_stream_code()
{
  return MONGOC_ERROR_STREAM;
}

int idris_mongoc_mongoc_error_protocol_code()
{
  return MONGOC_ERROR_PROTOCOL;
}

int idris_mongoc_mongoc_error_cursor_code()
{
  return MONGOC_ERROR_CURSOR;
}

int idris_mongoc_mongoc_error_server_code()
{
  return MONGOC_ERROR_SERVER;
}

int idris_mongoc_mongoc_error_sasl_code()
{
  return MONGOC_ERROR_SASL;
}

int idris_mongoc_mongoc_error_bson_code()
{
  return MONGOC_ERROR_BSON;
}

int idris_mongoc_mongoc_error_namespace_code()
{
  return MONGOC_ERROR_NAMESPACE;
}

int idris_mongoc_mongoc_error_collection_code()
{
  return MONGOC_ERROR_COMMAND;
}

int idris_mongoc_mongoc_error_gridfs_code()
{
  return MONGOC_ERROR_GRIDFS;
}

int idris_mongoc_mongoc_error_scram_code()
{
  return MONGOC_ERROR_SCRAM;
}

int idris_mongoc_mongoc_error_server_selection_code()
{
  return MONGOC_ERROR_SERVER_SELECTION;
}

int idris_mongoc_mongoc_error_write_concern_code()
{
  return MONGOC_ERROR_WRITE_CONCERN;
}

int idris_mongoc_mongoc_error_transaction_code()
{
  return MONGOC_ERROR_TRANSACTION;
}

int idris_bson_error_domain(const CData error_cdata)
{
  const bson_error_t * error = (const bson_error_t *) error_cdata->data;
  return error->domain;
}

int idris_bson_error_code(const CData error_cdata)
{
  const bson_error_t * error = (const bson_error_t *) error_cdata->data;
  return error->code;
}

VAL idris_bson_error_message(const CData error_cdata)
{
  const bson_error_t * error = (const bson_error_t *) error_cdata->data;
  return MKSTR(get_vm(), error->message);
}
