module BSonError

%lib     C "bson-1.0"
%link    C "idris_mongo_bson_error.o"
%include C "idris_mongo_bson_error.h"

%access export

private
cond : List (Lazy Bool, Lazy a) -> Lazy a -> a
cond [] def = def
cond ((x, y) :: xs) def = if x then y else cond xs def

||| Errors with error domain `BSON_ERROR_JSON`.
|||
||| BSON_JSON_ERROR_READ_CORRUPT_JS: `C` `bson_json_reader_t` tried to parse
||| invalid MongoDB Extended JSON.
|||
||| BSON_JSON_ERROR_READ_INVALID_PARAM: Tried to parse a valid JSON document
||| that is invalid as MongoDBExtended JSON.
|||
||| BSON_JSON_ERROR_READ_CB_FAILURE: An internal callback failure during JSON
||| parsing.
private
data BSonErrorJSon =
    BSON_JSON_ERROR_READ_CORRUPT_JS
  | BSON_JSON_ERROR_READ_INVALID_PARAM
  | BSON_JSON_ERROR_READ_CB_FAILURE
  | UNSUPPORTED_BSON_ERROR_JSON Int

private total
Show BSonErrorJSon where
  show BSON_JSON_ERROR_READ_CORRUPT_JS =
    "BSON_JSON_ERROR_READ_CORRUPT_JS"
  show BSON_JSON_ERROR_READ_INVALID_PARAM =
    "BSON_JSON_ERROR_READ_INVALID_PARAM"
  show BSON_JSON_ERROR_READ_CB_FAILURE =
    "BSON_JSON_ERROR_READ_CB_FAILURE"
  show (UNSUPPORTED_BSON_ERROR_JSON code) =
    "Unsupported " ++ (show code)

private
bSonJSonErrorReadCorruptJSCode : IO Int
bSonJSonErrorReadCorruptJSCode = foreign FFI_C
  "idris_mongoc_bson_json_error_read_corrupt_js_code" (IO Int)

private
bSonJSonErrorReadInvalidParamCode : IO Int
bSonJSonErrorReadInvalidParamCode = foreign FFI_C
  "idris_mongoc_bson_json_error_read_invalid_param_code" (IO Int)

private
bSonJSonErrorReadCBFailureCode : IO Int
bSonJSonErrorReadCBFailureCode = foreign FFI_C
  "idris_mongoc_bson_json_error_read_cb_failure_code" (IO Int)

private
bSonErrorJSonType : Int -> IO BSonErrorJSon
bSonErrorJSonType code = do
  bSonJSonErrorReadCorruptJS <-
    bSonJSonErrorReadCorruptJSCode
  bSonJSonErrorReadInvalidParam <-
    bSonJSonErrorReadInvalidParamCode
  bSonJSonErrorReadCBFailure <-
    bSonJSonErrorReadCBFailureCode
  cond [
    (code == bSonJSonErrorReadCorruptJS,
      pure BSON_JSON_ERROR_READ_CORRUPT_JS),
    (code == bSonJSonErrorReadInvalidParam,
      pure BSON_JSON_ERROR_READ_INVALID_PARAM),
    (code == bSonJSonErrorReadCBFailure,
      pure BSON_JSON_ERROR_READ_CB_FAILURE)
  ] (pure $ UNSUPPORTED_BSON_ERROR_JSON code)

||| Errors with error domain `BSON_ERROR_READER`.
|||
||| BSON_ERROR_READER_BADFD: `bson_json_reader_new_from_file()` could not open
||| the file.
private
data BSonErrorReader =
    BSON_ERROR_READER_BADFD
  | UNSUPPORTED_BSON_ERROR_READER Int

private total
Show BSonErrorReader where
  show BSON_ERROR_READER_BADFD =
    "BSON_ERROR_READER_BADFD"
  show (UNSUPPORTED_BSON_ERROR_READER code) =
    "Unsupported " ++ (show code)

private
bSonErrorReaderBadFDCode : IO Int
bSonErrorReaderBadFDCode = foreign FFI_C
  "idris_mongoc_bson_error_reader_bad_fd_code" (IO Int)

private
bSonErrorReaderType : Int -> IO BSonErrorReader
bSonErrorReaderType code = do
  bSonErrorReaderBadFD <-
    bSonErrorReaderBadFDCode
  cond [
    (code == bSonErrorReaderBadFD,
      pure BSON_ERROR_READER_BADFD)
  ] (pure $ UNSUPPORTED_BSON_ERROR_READER code)

||| Errors with error domain `MONGOC_ERROR_CLIENT`.
|||
||| MONGOC_ERROR_CLIENT_TOO_BIG: You tried to send a message larger than the
||| server’s max message size.
|||
||| MONGOC_ERROR_CLIENT_AUTHENTICATE: Wrong credentials, or failure sending or
||| receiving authentication messages.
|||
||| MONGOC_ERROR_CLIENT_NO_ACCEPTABLE_PEER: You tried an SSL connection but the
||| driver was not built with SSL.
|||
||| MONGOC_ERROR_CLIENT_IN_EXHAUST: You began iterating an exhaust cursor, then
||| tried to begin another operation with the same `C` `mongoc_client_t`.
|||
||| MONGOC_ERROR_CLIENT_SESSION_FAILURE: Failure related to creating or using a
||| logical session.
private
data MongoCErrorClient =
    MONGOC_ERROR_CLIENT_TOO_BIG
  | MONGOC_ERROR_CLIENT_AUTHENTICATE
  | MONGOC_ERROR_CLIENT_NO_ACCEPTABLE_PEER
  | MONGOC_ERROR_CLIENT_IN_EXHAUST
  | MONGOC_ERROR_CLIENT_SESSION_FAILURE
  | UNSUPPORTED_MONGOC_ERROR_CLIENT Int

private total
Show MongoCErrorClient where
  show MONGOC_ERROR_CLIENT_TOO_BIG =
    "MONGOC_ERROR_CLIENT_TOO_BIG"
  show MONGOC_ERROR_CLIENT_AUTHENTICATE =
    "MONGOC_ERROR_CLIENT_AUTHENTICATE"
  show MONGOC_ERROR_CLIENT_NO_ACCEPTABLE_PEER =
    "MONGOC_ERROR_CLIENT_NO_ACCEPTABLE_PEER"
  show MONGOC_ERROR_CLIENT_IN_EXHAUST =
    "MONGOC_ERROR_CLIENT_IN_EXHAUST"
  show MONGOC_ERROR_CLIENT_SESSION_FAILURE =
    "MONGOC_ERROR_CLIENT_SESSION_FAILURE"
  show (UNSUPPORTED_MONGOC_ERROR_CLIENT code) =
    "Unsupported " ++ (show code)

private
mongoCErrorClientTooBigCode : IO Int
mongoCErrorClientTooBigCode = foreign FFI_C
  "idris_mongoc_mongoc_error_client_too_big_code" (IO Int)

private
mongoCErrorClientAuthenticateCode : IO Int
mongoCErrorClientAuthenticateCode = foreign FFI_C
  "idris_mongoc_mongoc_error_client_authenticate_code" (IO Int)

private
mongoCErrorClientNoAcceptablePeerCode : IO Int
mongoCErrorClientNoAcceptablePeerCode = foreign FFI_C
  "idris_mongoc_mongoc_error_client_no_acceptable_peer_code" (IO Int)

private
mongoCErrorClientInExhaustCode : IO Int
mongoCErrorClientInExhaustCode = foreign FFI_C
  "idris_mongoc_mongoc_error_client_in_exhaust_code" (IO Int)

private
mongoCErrorClientSessionFailureCode : IO Int
mongoCErrorClientSessionFailureCode = foreign FFI_C
  "idris_mongoc_mongoc_error_client_session_failure_code" (IO Int)

private
mongoCErrorClientType : Int -> IO MongoCErrorClient
mongoCErrorClientType code = do
  mongoCErrorClientTooBig <-
    mongoCErrorClientTooBigCode
  mongoCErrorClientAuthenticate <-
    mongoCErrorClientAuthenticateCode
  mongoCErrorClientNoAcceptablePeer <-
    mongoCErrorClientNoAcceptablePeerCode
  mongoCErrorClientInExhaust <-
    mongoCErrorClientInExhaustCode
  mongoCErrorClientSessionFailure <-
    mongoCErrorClientSessionFailureCode
  cond [
    (code == mongoCErrorClientTooBig,
      pure MONGOC_ERROR_CLIENT_TOO_BIG),
    (code == mongoCErrorClientAuthenticate,
      pure MONGOC_ERROR_CLIENT_AUTHENTICATE),
    (code == mongoCErrorClientNoAcceptablePeer,
      pure MONGOC_ERROR_CLIENT_NO_ACCEPTABLE_PEER),
    (code == mongoCErrorClientInExhaust,
      pure MONGOC_ERROR_CLIENT_IN_EXHAUST),
    (code == mongoCErrorClientSessionFailure,
      pure MONGOC_ERROR_CLIENT_SESSION_FAILURE)
  ] (pure $ UNSUPPORTED_MONGOC_ERROR_CLIENT code)

||| Errors with error domain `MONGOC_ERROR_STREAM`.
|||
||| MONGOC_ERROR_STREAM_NAME_RESOLUTION: DNS failure.
|||
||| MONGOC_ERROR_STREAM_SOCKET: Timeout communicating with server, or connection
||| closed.
|||
||| MONGOC_ERROR_STREAM_CONNECT: Failed to connect to server.
private
data MongoCErrorStream =
    MONGOC_ERROR_STREAM_NAME_RESOLUTION
  | MONGOC_ERROR_STREAM_SOCKET
  | MONGOC_ERROR_STREAM_CONNECT
  | UNSUPPORTED_MONGOC_ERROR_STREAM Int

private total
Show MongoCErrorStream where
  show MONGOC_ERROR_STREAM_NAME_RESOLUTION =
    "MONGOC_ERROR_STREAM_NAME_RESOLUTION"
  show MONGOC_ERROR_STREAM_SOCKET =
    "MONGOC_ERROR_STREAM_SOCKET"
  show MONGOC_ERROR_STREAM_CONNECT =
    "MONGOC_ERROR_STREAM_CONNECT"
  show (UNSUPPORTED_MONGOC_ERROR_STREAM code) =
    "Unsupported " ++ (show code)

private
mongoCErrorStreamNameResolutionCode : IO Int
mongoCErrorStreamNameResolutionCode = foreign FFI_C
  "idris_mongoc_mongoc_error_stream_name_resolution_code" (IO Int)

private
mongoCErrorStreamSocketCode : IO Int
mongoCErrorStreamSocketCode = foreign FFI_C
  "idris_mongoc_mongoc_error_stream_socket_code" (IO Int)

private
mongoCErrorStreamConnectCode : IO Int
mongoCErrorStreamConnectCode = foreign FFI_C
  "idris_mongoc_mongoc_error_stream_connect_code" (IO Int)

private
mongoCErrorStreamType : Int -> IO MongoCErrorStream
mongoCErrorStreamType code = do
  mongoCErrorStreamNameResolution <-
    mongoCErrorStreamNameResolutionCode
  mongoCErrorStreamSocket <-
    mongoCErrorStreamSocketCode
  mongoCErrorStreamConnect <-
    mongoCErrorStreamConnectCode
  cond [
    (code == mongoCErrorStreamNameResolution,
      pure MONGOC_ERROR_STREAM_NAME_RESOLUTION),
    (code == mongoCErrorStreamSocket,
      pure MONGOC_ERROR_STREAM_SOCKET),
    (code == mongoCErrorStreamConnect,
      pure MONGOC_ERROR_STREAM_CONNECT)
  ] (pure $ UNSUPPORTED_MONGOC_ERROR_STREAM code)

||| Errors with error domain `MONGOC_ERROR_PROTOCOL`.
|||
||| MONGOC_ERROR_PROTOCOL_INVALID_REPLY: Corrupt response from server.
|||
||| MONGOC_ERROR_PROTOCOL_BAD_WIRE_VERSION: The server version is too old or too
||| new to communicate with the driver.
private
data MongoCErrorProtocol =
    MONGOC_ERROR_PROTOCOL_INVALID_REPLY
  | MONGOC_ERROR_PROTOCOL_BAD_WIRE_VERSION
  | UNSUPPORTED_MONGOC_ERROR_PROTOCOL Int

private total
Show MongoCErrorProtocol where
  show MONGOC_ERROR_PROTOCOL_INVALID_REPLY =
    "MONGOC_ERROR_PROTOCOL_INVALID_REPLY"
  show MONGOC_ERROR_PROTOCOL_BAD_WIRE_VERSION =
    "MONGOC_ERROR_PROTOCOL_BAD_WIRE_VERSION"
  show (UNSUPPORTED_MONGOC_ERROR_PROTOCOL code) =
    "Unsupported " ++ (show code)

private
mongoCErrorProtocolInvalidReplyCode : IO Int
mongoCErrorProtocolInvalidReplyCode = foreign FFI_C
  "idris_mongoc_mongoc_error_protocol_invalid_reply_code" (IO Int)

private
mongoCErrorProtocolBadWireVersionCode : IO Int
mongoCErrorProtocolBadWireVersionCode = foreign FFI_C
  "idris_mongoc_mongoc_error_protocol_bad_wire_version_code" (IO Int)

private
mongoCErrorProtocolType : Int -> IO MongoCErrorProtocol
mongoCErrorProtocolType code = do
  mongoCErrorProtocolInvalidReply <-
    mongoCErrorProtocolInvalidReplyCode
  mongoCErrorProtocolBadWireVersion <-
    mongoCErrorProtocolBadWireVersionCode
  cond [
    (code == mongoCErrorProtocolInvalidReply,
      pure MONGOC_ERROR_PROTOCOL_INVALID_REPLY),
    (code == mongoCErrorProtocolBadWireVersion,
      pure MONGOC_ERROR_PROTOCOL_BAD_WIRE_VERSION)
  ] (pure $ UNSUPPORTED_MONGOC_ERROR_PROTOCOL code)

||| Errors with error domain `MONGOC_ERROR_CURSOR`.
|||
||| MONGOC_ERROR_CURSOR_INVALID_CURSOR: You passed bad arguments to
||| `C` `mongoc_collection_find_with_opts()`, or you called
||| `mongoc_cursor_next()` on a completed or failed cursor, or the cursor timed
||| out on the server.
|||
||| MONGOC_ERROR_CHANGE_STREAM_NO_RESUME_TOKEN: A resume token was not returned
||| in a document found with `mongoc_change_stream_next()`.
private
data MongoCErrorCursor =
    MONGOC_ERROR_CURSOR_INVALID_CURSOR
  | MONGOC_ERROR_CHANGE_STREAM_NO_RESUME_TOKEN
  | UNSUPPORTED_MONGOC_ERROR_CURSOR Int

private total
Show MongoCErrorCursor where
  show MONGOC_ERROR_CURSOR_INVALID_CURSOR =
    "MONGOC_ERROR_CURSOR_INVALID_CURSOR"
  show MONGOC_ERROR_CHANGE_STREAM_NO_RESUME_TOKEN =
    "MONGOC_ERROR_CHANGE_STREAM_NO_RESUME_TOKEN"
  show (UNSUPPORTED_MONGOC_ERROR_CURSOR code) =
    "Unsupported " ++ (show code)

private
mongoCErrorCursorInvalidCursorCode : IO Int
mongoCErrorCursorInvalidCursorCode = foreign FFI_C
  "idris_mongoc_mongoc_error_cursor_invalid_cursor_code" (IO Int)

private
mongoCErrorChangeStreamNoResumeTokenCode : IO Int
mongoCErrorChangeStreamNoResumeTokenCode = foreign FFI_C
  "idris_mongoc_mongoc_error_change_stream_no_resume_token_code" (IO Int)

private
mongoCErrorCursorType : Int -> IO MongoCErrorCursor
mongoCErrorCursorType code = do
  mongoCErrorCursorInvalidCursor <-
    mongoCErrorCursorInvalidCursorCode
  mongoCErrorChangeStreamNoResumeToken <-
    mongoCErrorChangeStreamNoResumeTokenCode
  cond [
    (code == mongoCErrorCursorInvalidCursor,
      pure MONGOC_ERROR_CURSOR_INVALID_CURSOR),
    (code == mongoCErrorChangeStreamNoResumeToken,
      pure MONGOC_ERROR_CHANGE_STREAM_NO_RESUME_TOKEN)
  ] (pure $ UNSUPPORTED_MONGOC_ERROR_CURSOR code)

||| Errors with error domain `MONGOC_ERROR_SERVER`.
|||
||| MONGOC_ERROR_QUERY_FAILURE: Server error from command or query. The server
||| error message is in `message`.
|||
||| MONGOC_ERROR_SERVER_CODE: Server error code. The server error message is in
||| `message`.
private
data MongoCErrorServer =
    MONGOC_ERROR_QUERY_FAILURE
  | MONGOC_ERROR_SERVER_CODE Int

private total
Show MongoCErrorServer where
  show MONGOC_ERROR_QUERY_FAILURE =
    "MONGOC_ERROR_QUERY_FAILURE"
  show (MONGOC_ERROR_SERVER_CODE code) =
    "MONGOC_ERROR_SERVER_CODE " ++ (show code)

private
mongoCErrorQueryFailureCode : IO Int
mongoCErrorQueryFailureCode = foreign FFI_C
  "idris_mongoc_mongoc_error_query_failure_code" (IO Int)

private
mongoCErrorServerType : Int -> IO MongoCErrorServer
mongoCErrorServerType code = do
  mongoCErrorQueryFailure <-
    mongoCErrorQueryFailureCode
  cond [
    (code == mongoCErrorQueryFailure,
      pure MONGOC_ERROR_QUERY_FAILURE)
  ] (pure $ MONGOC_ERROR_SERVER_CODE code)

||| Errors with error domain `MONGOC_ERROR_SASL`.
|||
||| See `man sasl_errors` for a list of codes.
private
MongoCErrorSASL : Type
MongoCErrorSASL = Int

private
mongoCErrorSASLType : Int -> IO MongoCErrorSASL
mongoCErrorSASLType code = pure code

||| Errors with error domain `MONGOC_ERROR_BSON`.
|||
||| MONGOC_ERROR_BSON_INVALID: You passed an invalid or oversized BSON document
||| as a parameter, or called `C` `mongoc_collection_create_index()` with
||| invalid keys, or the server reply was corrupt.
private
data MongoCErrorBSon =
    MONGOC_ERROR_BSON_INVALID
  | UNSUPPORTED_MONGOC_ERROR_BSON Int

private total
Show MongoCErrorBSon where
  show MONGOC_ERROR_BSON_INVALID =
    "MONGOC_ERROR_BSON_INVALID"
  show (UNSUPPORTED_MONGOC_ERROR_BSON code) =
    "Unsupported " ++ (show code)

private
mongoCErrorBSonInvalidCode : IO Int
mongoCErrorBSonInvalidCode = foreign FFI_C
  "idris_mongoc_mongoc_error_bson_invalid_code" (IO Int)

private
mongoCErrorBSonType : Int -> IO MongoCErrorBSon
mongoCErrorBSonType code = do
  mongoCErrorBSonInvalid <-
    mongoCErrorBSonInvalidCode
  cond [
    (code == mongoCErrorBSonInvalid,
      pure MONGOC_ERROR_BSON_INVALID)
  ] (pure $ UNSUPPORTED_MONGOC_ERROR_BSON code)

||| Errors with error domain `MONGOC_ERROR_NAMESPACE`.
|||
||| MONGOC_ERROR_NAMESPACE_INVALID: You tried to create a collection with an
||| invalid name.
private
data MongoCErrorNameSpace =
    MONGOC_ERROR_NAMESPACE_INVALID
  | UNSUPPORTED_MONGOC_ERROR_NAMESPACE Int

private total
Show MongoCErrorNameSpace where
  show MONGOC_ERROR_NAMESPACE_INVALID =
    "MONGOC_ERROR_NAMESPACE_INVALID"
  show (UNSUPPORTED_MONGOC_ERROR_NAMESPACE code) =
    "Unsupported " ++ (show code)

private
mongoCErrorNameSpaceInvalidCode : IO Int
mongoCErrorNameSpaceInvalidCode = foreign FFI_C
  "idris_mongoc_mongoc_error_namespace_invalid_code" (IO Int)

private
mongoCErrorNameSpaceType : Int -> IO MongoCErrorNameSpace
mongoCErrorNameSpaceType code = do
  mongoCErrorNameSpaceInvalid <-
    mongoCErrorNameSpaceInvalidCode
  cond [
    (code == mongoCErrorNameSpaceInvalid,
      pure MONGOC_ERROR_NAMESPACE_INVALID)
  ] (pure $ UNSUPPORTED_MONGOC_ERROR_NAMESPACE code)

||| Errors with error domain `MONGOC_ERROR_COMMAND`.
|||
||| MONGOC_ERROR_COMMAND_INVALID_ARG: Many functions set this error code when
||| passed bad parameters. Print the error message for details.
|||
||| MONGOC_ERROR_COMMAND_PROTOCOL_BAD_WIRE_VERSION: You tried to use a command
||| option the server does not support.
|||
||| MONGOC_ERROR_COMMAND_DUPLICATE_KEY: An insert or update failed because
||| because of a duplicate `_id` or other unique-index violation.
private
data MongoCErrorCommand =
    MONGOC_ERROR_COMMAND_INVALID_ARG
  | MONGOC_ERROR_COMMAND_PROTOCOL_BAD_WIRE_VERSION
  | MONGOC_ERROR_COMMAND_DUPLICATE_KEY
  | UNSUPPORTED_MONGOC_ERROR_COMMAND Int

private total
Show MongoCErrorCommand where
  show MONGOC_ERROR_COMMAND_INVALID_ARG =
    "MONGOC_ERROR_COMMAND_INVALID_ARG"
  show MONGOC_ERROR_COMMAND_PROTOCOL_BAD_WIRE_VERSION =
    "MONGOC_ERROR_PROTOCOL_BAD_WIRE_VERSION"
  show MONGOC_ERROR_COMMAND_DUPLICATE_KEY =
    "MONGOC_ERROR_DUPLICATE_KEY"
  show (UNSUPPORTED_MONGOC_ERROR_COMMAND code) =
    "Unsupported " ++ (show code)

private
mongoCErrorCommandInvalidArgCode : IO Int
mongoCErrorCommandInvalidArgCode = foreign FFI_C
  "idris_mongoc_mongoc_error_command_invalid_arg_code" (IO Int)

private
mongoCErrorCommandProtocolBadWireVersionCode : IO Int
mongoCErrorCommandProtocolBadWireVersionCode = foreign FFI_C
  "idris_mongoc_mongoc_error_command_protocol_bad_wire_version_code" (IO Int)

private
mongoCErrorCommandDuplicateKeyCode : IO Int
mongoCErrorCommandDuplicateKeyCode = foreign FFI_C
  "idris_mongoc_mongoc_error_command_duplicate_key_code" (IO Int)

private
mongoCErrorCommandType : Int -> IO MongoCErrorCommand
mongoCErrorCommandType code = do
  mongoCErrorCommandInvalidArg <-
    mongoCErrorCommandInvalidArgCode
  mongoCErrorCommandProtocolBadWireVersion <-
    mongoCErrorCommandProtocolBadWireVersionCode
  mongoCErrorCommandDuplicateKey <-
    mongoCErrorCommandDuplicateKeyCode
  cond [
    (code == mongoCErrorCommandInvalidArg,
      pure MONGOC_ERROR_COMMAND_INVALID_ARG),
    (code == mongoCErrorCommandProtocolBadWireVersion,
      pure MONGOC_ERROR_COMMAND_PROTOCOL_BAD_WIRE_VERSION),
    (code == mongoCErrorCommandDuplicateKey,
      pure MONGOC_ERROR_COMMAND_DUPLICATE_KEY)
  ] (pure $ UNSUPPORTED_MONGOC_ERROR_COMMAND code)

||| Errors with error domain `MONGOC_ERROR_COLLECTION`.
|||
||| Invalid or empty input to `C`functions `mongoc_collection_insert_one()`,
||| `mongoc_collection_insert_bulk()`, `mongoc_collection_update_one()`,
||| `mongoc_collection_update_many()`, `mongoc_collection_replace_one()`,
||| `mongoc_collection_delete_one()`, or `mongoc_collection_delete_many()`.
private
data MongoCErrorCollection =
    MONGOC_ERROR_COLLECTION_INSERT_FAILED
  | MONGOC_ERROR_COLLECTION_UPDATE_FAILED
  | MONGOC_ERROR_COLLECTION_DELETE_FAILED
  | UNSUPPORTED_MONGOC_ERROR_COLLECTION Int

private total
Show MongoCErrorCollection where
  show MONGOC_ERROR_COLLECTION_INSERT_FAILED =
    "MONGOC_ERROR_COLLECTION_INSERT_FAILED"
  show MONGOC_ERROR_COLLECTION_UPDATE_FAILED =
    "MONGOC_ERROR_COLLECTION_UPDATE_FAILED"
  show MONGOC_ERROR_COLLECTION_DELETE_FAILED =
    "MONGOC_ERROR_COLLECTION_DELETE_FAILED"
  show (UNSUPPORTED_MONGOC_ERROR_COLLECTION code) =
    "Unsupported " ++ (show code)

private
mongoCErrorCollectionInsertFailedCode : IO Int
mongoCErrorCollectionInsertFailedCode = foreign FFI_C
  "idris_mongoc_mongoc_error_collection_insert_failed_code" (IO Int)

private
mongoCErrorCollectionUpdateFailedCode : IO Int
mongoCErrorCollectionUpdateFailedCode = foreign FFI_C
  "idris_mongoc_mongoc_error_collection_update_failed_code" (IO Int)

private
mongoCErrorCollectionDeleteFailedCode : IO Int
mongoCErrorCollectionDeleteFailedCode = foreign FFI_C
  "idris_mongoc_mongoc_error_collection_delete_failed_code" (IO Int)

private
mongoCErrorCollectionType : Int -> IO MongoCErrorCollection
mongoCErrorCollectionType code = do
  mongoCErrorCollectionInsertFailed <-
    mongoCErrorCollectionInsertFailedCode
  mongoCErrorCollectionUpdateFailed <-
    mongoCErrorCollectionUpdateFailedCode
  mongoCErrorCollectionDeleteFailed <-
    mongoCErrorCollectionDeleteFailedCode
  cond [
    (code == mongoCErrorCollectionInsertFailed,
      pure MONGOC_ERROR_COLLECTION_INSERT_FAILED),
    (code == mongoCErrorCollectionUpdateFailed,
      pure MONGOC_ERROR_COLLECTION_UPDATE_FAILED),
    (code == mongoCErrorCollectionDeleteFailed,
      pure MONGOC_ERROR_COLLECTION_DELETE_FAILED)
  ] (pure $ UNSUPPORTED_MONGOC_ERROR_COLLECTION code)

||| Errors with error domain `MONGOC_ERROR_GRIDFS`.
|||
||| MONGOC_ERROR_GRIDFS_CHUNK_MISSING: The GridFS file is missing a document in
||| its `chunks` collection.
|||
||| MONGOC_ERROR_GRIDFS_CORRUPT: A data inconsistency was detected in GridFS.
|||
||| MONGOC_ERROR_GRIDFS_INVALID_FILENAME: You passed a `NULL` filename to `C`
||| `mongoc_gridfs_remove_by_filename()`.
|||
||| MONGOC_ERROR_GRIDFS_PROTOCOL_ERROR: You called `mongoc_gridfs_file_set_id()`
||| after `mongoc_gridfs_file_save()`.
private
data MongoCErrorGridFS =
    MONGOC_ERROR_GRIDFS_CHUNK_MISSING
  | MONGOC_ERROR_GRIDFS_CORRUPT
  | MONGOC_ERROR_GRIDFS_INVALID_FILENAME
  | MONGOC_ERROR_GRIDFS_PROTOCOL_ERROR
  | UNSUPPORTED_MONGOC_ERROR_GRIDFS Int

private total
Show MongoCErrorGridFS where
  show MONGOC_ERROR_GRIDFS_CHUNK_MISSING =
    "MONGOC_ERROR_GRIDFS_CHUNK_MISSING"
  show MONGOC_ERROR_GRIDFS_CORRUPT =
    "MONGOC_ERROR_GRIDFS_CORRUPT"
  show MONGOC_ERROR_GRIDFS_INVALID_FILENAME =
    "MONGOC_ERROR_GRIDFS_INVALID_FILENAME"
  show MONGOC_ERROR_GRIDFS_PROTOCOL_ERROR =
    "MONGOC_ERROR_GRIDFS_PROTOCOL_ERROR"
  show (UNSUPPORTED_MONGOC_ERROR_GRIDFS code) =
    "Unsupported " ++ (show code)

private
mongoCErrorGridFSChunkMissingCode : IO Int
mongoCErrorGridFSChunkMissingCode = foreign FFI_C
  "idris_mongoc_mongoc_error_gridfs_chunk_missing_code" (IO Int)

private
mongoCErrorGridFSCorruptCode : IO Int
mongoCErrorGridFSCorruptCode = foreign FFI_C
  "idris_mongoc_mongoc_error_gridfs_corrupt_code" (IO Int)

private
mongoCErrorGridFSInvalidFileNameCode : IO Int
mongoCErrorGridFSInvalidFileNameCode = foreign FFI_C
  "idris_mongoc_mongoc_error_gridfs_invalid_filename_code" (IO Int)

private
mongoCErrorGridFSProtocolErrorCode : IO Int
mongoCErrorGridFSProtocolErrorCode = foreign FFI_C
  "idris_mongoc_mongoc_error_gridfs_protocol_error_code" (IO Int)

private
mongoCErrorGridFSType : Int -> IO MongoCErrorGridFS
mongoCErrorGridFSType code = do
  mongoCErrorGridFSChunkMissing <-
    mongoCErrorGridFSChunkMissingCode
  mongoCErrorGridFSCorrupt <-
    mongoCErrorGridFSCorruptCode
  mongoCErrorGridFSInvalidFileName <-
    mongoCErrorGridFSInvalidFileNameCode
  mongoCErrorGridFSProtocolError <-
    mongoCErrorGridFSProtocolErrorCode
  cond [
    (code == mongoCErrorGridFSChunkMissing,
      pure MONGOC_ERROR_GRIDFS_CHUNK_MISSING),
    (code == mongoCErrorGridFSCorrupt,
      pure MONGOC_ERROR_GRIDFS_CORRUPT),
    (code == mongoCErrorGridFSInvalidFileName,
      pure MONGOC_ERROR_GRIDFS_INVALID_FILENAME),
    (code == mongoCErrorGridFSProtocolError,
      pure MONGOC_ERROR_GRIDFS_PROTOCOL_ERROR)
  ] (pure $ UNSUPPORTED_MONGOC_ERROR_GRIDFS code)

||| Errors with error domain `MONGOC_ERROR_SCRAM`.
|||
||| MONGOC_ERROR_SCRAM_PROTOCOL_ERROR: Failure in SCRAM-SHA-1 authentication.
private
data MongoCErrorSCRAM =
    MONGOC_ERROR_SCRAM_PROTOCOL_ERROR
  | UNSUPPORTED_MONGOC_ERROR_SCRAM Int

private total
Show MongoCErrorSCRAM where
  show MONGOC_ERROR_SCRAM_PROTOCOL_ERROR =
    "MONGOC_ERROR_SCRAM_PROTOCOL_ERROR"
  show (UNSUPPORTED_MONGOC_ERROR_SCRAM code) =
    "Unsupported " ++ (show code)

private
mongoCErrorSCRAMProtocolErrorCode : IO Int
mongoCErrorSCRAMProtocolErrorCode = foreign FFI_C
  "idris_mongoc_mongoc_error_scram_protocol_error_code" (IO Int)

private
mongoCErrorSCRAMType : Int -> IO MongoCErrorSCRAM
mongoCErrorSCRAMType code = do
  mongoCErrorSCRAMProtocolError <-
    mongoCErrorSCRAMProtocolErrorCode
  cond [
    (code == mongoCErrorSCRAMProtocolError,
      pure MONGOC_ERROR_SCRAM_PROTOCOL_ERROR)
  ] (pure $ UNSUPPORTED_MONGOC_ERROR_SCRAM code)

||| Errors with error domain `MONGOC_ERROR_SERVER_SELECTION`.
|||
||| MONGOC_ERROR_SERVER_SELECTION_FAILURE: No replica set member or mongos is
||| available, or none matches your read preference, or you supplied an invalid
||| `mongoc_read_prefs_t`.
private
data MongoCErrorServerSelection =
    MONGOC_ERROR_SERVER_SELECTION_FAILURE
  | UNSUPPORTED_MONGOC_ERROR_SERVER_SELECTION Int

private total
Show MongoCErrorServerSelection where
  show MONGOC_ERROR_SERVER_SELECTION_FAILURE =
    "MONGOC_ERROR_SERVER_SELECTION_FAILURE"
  show (UNSUPPORTED_MONGOC_ERROR_SERVER_SELECTION code) =
    "Unsupported " ++ (show code)

private
mongoCErrorServerSelectionFailureCode : IO Int
mongoCErrorServerSelectionFailureCode = foreign FFI_C
  "idris_mongoc_mongoc_error_server_selection_failure_code" (IO Int)

private
mongoCErrorServerSelectionType : Int -> IO MongoCErrorServerSelection
mongoCErrorServerSelectionType code = do
  mongoCErrorServerSelectionFailure <-
    mongoCErrorServerSelectionFailureCode
  cond [
    (code == mongoCErrorServerSelectionFailure,
      pure MONGOC_ERROR_SERVER_SELECTION_FAILURE)
  ] (pure $ UNSUPPORTED_MONGOC_ERROR_SERVER_SELECTION code)

||| Errors with error domain `MONGOC_ERROR_WRITE_CONCERN`.
|||
||| Error code from server. There was a write concern error or timeout from the
||| server.
private
MongoCErrorWriteConcern : Type
MongoCErrorWriteConcern = Int

private
mongoCErrorWriteConcernType : Int -> IO MongoCErrorWriteConcern
mongoCErrorWriteConcernType code = pure code

||| Errors with error domain `MONGOC_ERROR_TRANSACTION`.
|||
||| MONGOC_ERROR_TRANSACTION_INVALID: You attempted to start a transaction when
||| one is already in progress, or commit or abort when there is no transaction.
private
data MongoCErrorTransaction =
    MONGOC_ERROR_TRANSACTION_INVALID_STATE
  | UNSUPPORTED_MONGOC_ERROR_TRANSACTION Int

private total
Show MongoCErrorTransaction where
  show MONGOC_ERROR_TRANSACTION_INVALID_STATE =
    "MONGOC_ERROR_TRANSACTION_INVALID_STATE"
  show (UNSUPPORTED_MONGOC_ERROR_TRANSACTION code) =
    "Unsupported " ++ (show code)

private
mongoCErrorTransactionInvalidCode : IO Int
mongoCErrorTransactionInvalidCode = foreign FFI_C
  "idris_mongoc_mongoc_error_transaction_invalid_code" (IO Int)

private
mongoCErrorTransactionType : Int -> IO MongoCErrorTransaction
mongoCErrorTransactionType code = do
  mongoCErrorTransactionInvalid <-
    mongoCErrorTransactionInvalidCode
  cond [
    (code == mongoCErrorTransactionInvalid,
      pure MONGOC_ERROR_TRANSACTION_INVALID_STATE)
  ] (pure $ UNSUPPORTED_MONGOC_ERROR_TRANSACTION code)

||| Abstract and parsed BSon errors.
|||
||| ONLY ERROR API VERSION 2 SUPPORTED!
|||
||| The constructor is related isomorphically to the BSon error domain, while
||| the argument to the constructor is related isomorphically to the BSon error
||| code.
private
data BSonErrorType =
    BSON_ERROR_JSON BSonErrorJSon
  | BSON_ERROR_READER BSonErrorReader
  | MONGOC_ERROR_CLIENT MongoCErrorClient
  | MONGOC_ERROR_STREAM MongoCErrorStream
  | MONGOC_ERROR_PROTOCOL MongoCErrorProtocol
  | MONGOC_ERROR_CURSOR MongoCErrorCursor
  | MONGOC_ERROR_SERVER MongoCErrorServer
  | MONGOC_ERROR_SASL MongoCErrorSASL
  | MONGOC_ERROR_BSON MongoCErrorBSon
  | MONGOC_ERROR_NAMESPACE MongoCErrorNameSpace
  | MONGOC_ERROR_COMMAND MongoCErrorCommand
  | MONGOC_ERROR_COLLECTION MongoCErrorCollection
  | MONGOC_ERROR_GRIDFS MongoCErrorGridFS
  | MONGOC_ERROR_SCRAM MongoCErrorSCRAM
  | MONGOC_ERROR_SERVER_SELECTION MongoCErrorServerSelection
  | MONGOC_ERROR_WRITE_CONCERN MongoCErrorWriteConcern
  | MONGOC_ERROR_TRANSACTION MongoCErrorTransaction
  | UNSUPPORTED_ERROR Int Int

private total
Show BSonErrorType where
  show (BSON_ERROR_JSON codeType) =
    "BSON_ERROR_JSON." ++ (show codeType)
  show (BSON_ERROR_READER codeType) =
    "BSON_ERROR_READER." ++ (show codeType)
  show (MONGOC_ERROR_CLIENT codeType) =
    "MONGOC_ERROR_CLIENT." ++ (show codeType)
  show (MONGOC_ERROR_STREAM codeType) =
    "MONGOC_ERROR_STREAM." ++ (show codeType)
  show (MONGOC_ERROR_PROTOCOL codeType) =
    "MONGOC_ERROR_PROTOCOL." ++ (show codeType)
  show (MONGOC_ERROR_CURSOR codeType) =
    "MONGOC_ERROR_CURSOR." ++ (show codeType)
  show (MONGOC_ERROR_SERVER codeType) =
    "MONGOC_ERROR_SERVER." ++ (show codeType)
  show (MONGOC_ERROR_SASL codeType) =
    "MONGOC_ERROR_SASL." ++ (show codeType)
  show (MONGOC_ERROR_BSON codeType) =
    "MONGOC_ERROR_BSON." ++ (show codeType)
  show (MONGOC_ERROR_NAMESPACE codeType) =
    "MONGOC_ERROR_NAMESPACE." ++ (show codeType)
  show (MONGOC_ERROR_COMMAND codeType) =
    "MONGOC_ERROR_COMMAND." ++ (show codeType)
  show (MONGOC_ERROR_COLLECTION codeType) =
    "MONGOC_ERROR_COLLECTION." ++ (show codeType)
  show (MONGOC_ERROR_GRIDFS codeType) =
    "MONGOC_ERROR_GRIDFS." ++ (show codeType)
  show (MONGOC_ERROR_SCRAM codeType) =
    "MONGOC_ERROR_SCRAM." ++ (show codeType)
  show (MONGOC_ERROR_SERVER_SELECTION codeType) =
    "MONGOC_ERROR_SERVER_SELECTION." ++ (show codeType)
  show (MONGOC_ERROR_WRITE_CONCERN codeType) =
    "MONGOC_ERROR_WRITE_CONCERN." ++ (show codeType)
  show (MONGOC_ERROR_TRANSACTION codeType) =
    "MONGOC_ERROR_TRANSACTION." ++ (show codeType)
  show (UNSUPPORTED_ERROR codeDomain codeError) =
    "Unsupported " ++ (show codeDomain) ++ "." ++ (show codeError)

private
bSonErrorJSonCode : IO Int
bSonErrorJSonCode = foreign FFI_C
  "idris_mongoc_bson_error_json_code" (IO Int)

private
bSonErrorReaderCode : IO Int
bSonErrorReaderCode = foreign FFI_C
  "idris_mongoc_bson_error_reader_code" (IO Int)

private
mongoCErrorClientCode : IO Int
mongoCErrorClientCode = foreign FFI_C
  "idris_mongoc_mongoc_error_client_code" (IO Int)

private
mongoCErrorStreamCode : IO Int
mongoCErrorStreamCode = foreign FFI_C
  "idris_mongoc_mongoc_error_stream_code" (IO Int)

private
mongoCErrorProtocolCode : IO Int
mongoCErrorProtocolCode = foreign FFI_C
  "idris_mongoc_mongoc_error_protocol_code" (IO Int)

private
mongoCErrorCursorCode : IO Int
mongoCErrorCursorCode = foreign FFI_C
  "idris_mongoc_mongoc_error_cursor_code" (IO Int)

private
mongoCErrorServerCode : IO Int
mongoCErrorServerCode = foreign FFI_C
  "idris_mongoc_mongoc_error_server_code" (IO Int)

private
mongoCErrorSASLCode : IO Int
mongoCErrorSASLCode = foreign FFI_C
  "idris_mongoc_mongoc_error_sasl_code" (IO Int)

private
mongoCErrorBSonCode : IO Int
mongoCErrorBSonCode = foreign FFI_C
  "idris_mongoc_mongoc_error_bson_code" (IO Int)

private
mongoCErrorNameSpaceCode : IO Int
mongoCErrorNameSpaceCode = foreign FFI_C
  "idris_mongoc_mongoc_error_namespace_code" (IO Int)

private
mongoCErrorCollectionCode : IO Int
mongoCErrorCollectionCode = foreign FFI_C
  "idris_mongoc_mongoc_error_collection_code" (IO Int)

private
mongoCErrorGridFSCode : IO Int
mongoCErrorGridFSCode = foreign FFI_C
  "idris_mongoc_mongoc_error_gridfs_code" (IO Int)

private
mongoCErrorSCRAMCode : IO Int
mongoCErrorSCRAMCode = foreign FFI_C
  "idris_mongoc_mongoc_error_scram_code" (IO Int)

private
mongoCErrorServerSelectionCode : IO Int
mongoCErrorServerSelectionCode = foreign FFI_C
  "idris_mongoc_mongoc_error_server_selection_code" (IO Int)

private
mongoCErrorWriteConcernCode : IO Int
mongoCErrorWriteConcernCode = foreign FFI_C
  "idris_mongoc_mongoc_error_write_concern_code" (IO Int)

private
mongoCErrorTransactionCode : IO Int
mongoCErrorTransactionCode = foreign FFI_C
  "idris_mongoc_mongoc_error_transaction_code" (IO Int)

private
type : Int -> Int -> IO BSonErrorType
type domain code = do
  bSonErrorJSon <-
    bSonErrorJSonCode
  bSonErrorReader <-
    bSonErrorReaderCode
  mongoCErrorClient <-
    mongoCErrorClientCode
  mongoCErrorStream <-
    mongoCErrorStreamCode
  mongoCErrorProtocol <-
    mongoCErrorProtocolCode
  mongoCErrorCursor <-
    mongoCErrorCursorCode
  mongoCErrorServer <-
    mongoCErrorServerCode
  mongoCErrorSASL <-
    mongoCErrorSASLCode
  mongoCErrorBSon <-
    mongoCErrorBSonCode
  mongoCErrorNameSpace <-
    mongoCErrorNameSpaceCode
  mongoCErrorCollection <-
    mongoCErrorCollectionCode
  mongoCErrorGridFS <-
    mongoCErrorGridFSCode
  mongoCErrorSCRAM <-
    mongoCErrorSCRAMCode
  mongoCErrorServerSelection <-
    mongoCErrorServerSelectionCode
  mongoCErrorWriteConcern <-
    mongoCErrorWriteConcernCode
  mongoCErrorTransaction <-
    mongoCErrorTransactionCode
  cond [
    (domain == bSonErrorJSon, do
      type <- bSonErrorJSonType code
      pure $ BSON_ERROR_JSON $ type),
    (domain == bSonErrorReader, do
      type <- bSonErrorReaderType code
      pure $ BSON_ERROR_READER $ type),
    (domain == mongoCErrorClient, do
      type <- mongoCErrorClientType code
      pure $ MONGOC_ERROR_CLIENT $ type),
    (domain == mongoCErrorStream, do
      type <- mongoCErrorStreamType code
      pure $ MONGOC_ERROR_STREAM $ type),
    (domain == mongoCErrorProtocol, do
      type <- mongoCErrorProtocolType code
      pure $ MONGOC_ERROR_PROTOCOL $ type),
    (domain == mongoCErrorCursor, do
      type <- mongoCErrorCursorType code
      pure $ MONGOC_ERROR_CURSOR $ type),
    (domain == mongoCErrorServer, do
      type <- mongoCErrorServerType code
      pure $ MONGOC_ERROR_SERVER $ type),
    (domain == mongoCErrorSASL, do
      type <- mongoCErrorSASLType code
      pure $ MONGOC_ERROR_SASL $ type),
    (domain == mongoCErrorBSon, do
      type <- mongoCErrorBSonType code
      pure $ MONGOC_ERROR_BSON $ type),
    (domain == mongoCErrorNameSpace, do
      type <- mongoCErrorNameSpaceType code
      pure $ MONGOC_ERROR_NAMESPACE $ type),
    (domain == mongoCErrorCollection, do
      type <- mongoCErrorCollectionType code
      pure $ MONGOC_ERROR_COLLECTION $ type),
    (domain == mongoCErrorGridFS, do
      type <- mongoCErrorGridFSType code
      pure $ MONGOC_ERROR_GRIDFS $ type),
    (domain == mongoCErrorSCRAM, do
      type <- mongoCErrorSCRAMType code
      pure $ MONGOC_ERROR_SCRAM $ type),
    (domain == mongoCErrorServerSelection, do
      type <- mongoCErrorServerSelectionType code
      pure $ MONGOC_ERROR_SERVER_SELECTION $ type),
    (domain == mongoCErrorWriteConcern, do
      type <- mongoCErrorWriteConcernType code
      pure $ MONGOC_ERROR_WRITE_CONCERN $ type),
    (domain == mongoCErrorTransaction, do
      type <- mongoCErrorTransactionType code
      pure $ MONGOC_ERROR_TRANSACTION $ type)
  ] (pure $ UNSUPPORTED_ERROR domain code)

public export
data BSonError = MkBSonError CData

||| PRIVATE. Creates a new error placeholder.
|||
||| This is intended to be used by low-level binding code.
||| It is intended to be populated by C code with a given error.
newErrorPlaceHolder : () -> IO BSonError
newErrorPlaceHolder () = do
  errorPlaceHolder <- foreign FFI_C "idris_bson_error_new" (IO CData)
  pure $ MkBSonError errorPlaceHolder

||| Gets the BSon error domain of a BSon error.
|||
||| @ error The BSon error.
errorDomain : (error : BSonError) -> IO Int
errorDomain (MkBSonError error) =
  foreign FFI_C "idris_bson_error_domain" (CData -> IO Int) error

||| Gets the BSon error code of a BSon error.
|||
||| @ error The BSon error.
errorCode : (error : BSonError) -> IO Int
errorCode (MkBSonError error) =
  foreign FFI_C "idris_bson_error_code" (CData -> IO Int) error

||| Gets the BSon error message of a BSon error
|||
||| @ error the BSon error
errorMessage : (error : BSonError) -> IO String
errorMessage (MkBSonError error) = do
  MkRaw message <- foreign FFI_C "idris_bson_error_message"
    (CData -> IO (Raw String)) error
  pure message

||| Shows a `BSonError`.
|||
||| @ error The error to show.
show : (error : BSonError) -> IO String
show error = do
  domain <- errorDomain error
  code <- errorCode error
  message <- errorMessage error
  type <- type domain code
  pure $ (show type) ++ ": " ++ message
