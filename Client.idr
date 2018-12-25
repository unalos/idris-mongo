module Mongo

import Common
import BSonError
import BSon
import ISon
import Mongo
import Options
import ReadPreferences

%lib C "mongoc-1.0"
%link C "idris_mongo_client.o"
%include C "idris_mongo_client.h"

%access export

public export
data Client = MkClient CData

private
mkClient : URI -> IO Client
mkClient (MkURI uri) = do
  clientCData <- foreign FFI_C "idris_mongoc_client_new_from_uri"
    (CData -> IO CData) uri
  pure $ MkClient clientCData

public export
data APIVersion =
    VERSION_LEGACY
  | VERSION_2

private
apiVersionLegacy : IO Int
apiVersionLegacy =
  foreign FFI_C "idris_mongoc_error_api_version_legacy" (IO Int)

private
apiVersion2 : IO Int
apiVersion2 =
  foreign FFI_C "idris_mongoc_error_api_version_2" (IO Int)

private
versionAsInt : APIVersion -> IO Int
versionAsInt VERSION_LEGACY = apiVersionLegacy
versionAsInt VERSION_2      = apiVersion2

private
clientSetErrorAPI : Client -> APIVersion -> IO (Maybe ())
clientSetErrorAPI (MkClient client) version = do
  apiVersion <- versionAsInt version
  success <- foreign FFI_C "idris_mongoc_client_set_error_api"
    (CData -> Int -> IO Int) client apiVersion
  case success of
    0 => pure Nothing
    _ => pure $ Just ()

private
clientSetAppName : Client -> String -> IO (Maybe ())
clientSetAppName (MkClient client) appName = do
  success <- foreign FFI_C "idris_mongoc_client_set_appname"
    (CData -> String -> IO Int) client appName
  case success of
    0 => pure Nothing
    _ => pure $ Just ()


client : URI -> {default VERSION_2 version : APIVersion} -> String -> IO (Maybe Client)
client uri {version} appName = do
  client <- mkClient uri
  success1 <- clientSetErrorAPI client version
  success2 <- clientSetAppName client appName
  case (success1, success2) of
    (Just (), Just ()) => pure $ Just client
    _ => pure Nothing

simpleCommand : Client -> String -> Document -> IO (Maybe BSon)
simpleCommand (MkClient client) db command = do
  Just (MkBSon bSonCommand) <- bSon command
    | Nothing => pure Nothing
  reply <- foreign FFI_C "idris_mongoc_client_command_simple"
    (CData -> String -> CData -> IO CData) client db bSonCommand
  failure <- isCDataPtrNull reply
  case failure of
    True => pure Nothing
    False => pure $ Just $ MkBSon reply

public export
data WriteCommandException =
    WriteCommandCException BSonError
  | BSonWriteCommandGenerationException

writeCommand : Client -> String -> Document
               -> Options -> IO (Either WriteCommandException BSon)
writeCommand (MkClient client) dbName command (MkOptions options) = do
  Just (MkBSon bSonCommand) <- bSon command
    | Nothing => pure (Left BSonWriteCommandGenerationException)
  MkBSonError errorPlaceholder <- newErrorPlaceholder ()
  reply <- foreign FFI_C "idris_mongoc_client_write_command_with_opts"
    (CData -> String -> CData -> CData -> CData -> IO CData)
    client dbName bSonCommand options errorPlaceholder
  failure <- isCDataPtrNull reply
  case failure of
    True => pure $ Left (WriteCommandCException (MkBSonError errorPlaceholder))
    False => pure $ Right $ MkBSon reply

public export
data ReadCommandException =
    ReadCommandCException BSonError
  | BSonReadCommandGenerationException

show : ReadCommandException -> IO String
show (ReadCommandCException error) = do
  errorMessage <- show error
  pure $ "ReadCommandCException: " ++ errorMessage
show (BSonReadCommandGenerationException) =
  pure "BSonReadCommandGenerationException"

readCommand : Client -> String -> Document -> ReadPreferences
              -> Options -> IO (Either ReadCommandException BSon)
readCommand (MkClient client) dbName command
  (MkReadPreferences readPreferences) (MkOptions options) = do
  Just (MkBSon bSonCommand) <- bSon command
    | Nothing => pure (Left BSonReadCommandGenerationException)
  MkBSonError errorPlaceholder <- newErrorPlaceholder ()
  reply <- foreign FFI_C "idris_mongoc_client_read_command_with_opts"
    (CData -> String -> CData -> CData -> CData -> CData -> IO CData)
    client dbName bSonCommand readPreferences options errorPlaceholder
  failure <- isCDataPtrNull reply
  case failure of
    True => pure $ Left (ReadCommandCException (MkBSonError errorPlaceholder))
    False => pure $ Right $ MkBSon reply

data DataBase = MkDataBase CData

dataBase : Client -> String -> IO DataBase
dataBase (MkClient clientCData) name = do
  cData <- foreign FFI_C "idris_mongoc_client_get_database"
    (CData -> String -> IO CData) clientCData name
  pure $ MkDataBase cData
