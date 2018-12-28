#include "idris_rts.h"

CData idris_bson_error_new();

int idris_mongoc_bson_json_error_read_corrupt_js_code();

int idris_mongoc_bson_json_error_read_invalid_param_code();

int idris_mongoc_bson_json_error_read_cb_failure_code();

int idris_mongoc_bson_error_reader_bad_fd_code();

int idris_mongoc_mongoc_error_client_too_big_code();

int idris_mongoc_mongoc_error_client_authenticate_code();

int idris_mongoc_mongoc_error_client_no_acceptable_peer_code();

int idris_mongoc_mongoc_error_client_in_exhaust_code();

int idris_mongoc_mongoc_error_client_session_failure_code();

int idris_mongoc_mongoc_error_stream_name_resolution_code();

int idris_mongoc_mongoc_error_stream_socket_code();

int idris_mongoc_mongoc_error_stream_connect_code();

int idris_mongoc_mongoc_error_protocol_invalid_reply_code();

int idris_mongoc_mongoc_error_protocol_bad_wire_version_code();

int idris_mongoc_mongoc_error_cursor_invalid_cursor_code();

int idris_mongoc_mongoc_error_change_stream_no_resume_token_code();

int idris_mongoc_mongoc_error_query_failure_code();

int idris_mongoc_mongoc_error_bson_invalid_code();

int idris_mongoc_mongoc_error_namespace_invalid_code();

int idris_mongoc_mongoc_error_command_invalid_arg_code();

int idris_mongoc_mongoc_error_command_protocol_bad_wire_version_code();

int idris_mongoc_mongoc_error_command_duplicate_key_code();

int idris_mongoc_mongoc_error_collection_insert_failed_code();

int idris_mongoc_mongoc_error_collection_update_failed_code();

int idris_mongoc_mongoc_error_collection_delete_failed_code();

int idris_mongoc_mongoc_error_gridfs_chunk_missing_code();

int idris_mongoc_mongoc_error_gridfs_corrupt_code();

int idris_mongoc_mongoc_error_gridfs_invalid_filename_code();

int idris_mongoc_mongoc_error_gridfs_protocol_error_code();

int idris_mongoc_mongoc_error_scram_protocol_error_code();

int idris_mongoc_mongoc_error_server_selection_failure_code();

int idris_mongoc_mongoc_error_transaction_invalid_code();

int idris_mongoc_bson_error_json_code();

int idris_mongoc_bson_error_reader_code();

int idris_mongoc_mongoc_error_client_code();

int idris_mongoc_mongoc_error_stream_code();

int idris_mongoc_mongoc_error_protocol_code();

int idris_mongoc_mongoc_error_cursor_code();

int idris_mongoc_mongoc_error_server_code();

int idris_mongoc_mongoc_error_sasl_code();

int idris_mongoc_mongoc_error_bson_code();

int idris_mongoc_mongoc_error_namespace_code();

int idris_mongoc_mongoc_error_collection_code();

int idris_mongoc_mongoc_error_gridfs_code();

int idris_mongoc_mongoc_error_scram_code();

int idris_mongoc_mongoc_error_server_selection_code();

int idris_mongoc_mongoc_error_write_concern_code();

int idris_mongoc_mongoc_error_transaction_code();

int idris_bson_error_domain(const CData error_cdata);

int idris_bson_error_code(const CData error_cdata);

VAL idris_bson_error_message(const CData error_cdata);
