module Mongo

import BSon
import ISon

%lib C "mongoc-1.0"
%include C "idris_mongo.c"
%access export

isCDataPtrNull: CData -> IO Bool
isCDataPtrNull cData = do
  code <- foreign FFI_C "idris_mongoc_is_C_data_ptr_null"
    (CData -> IO Int) cData
  case code of
    0 => pure False
    _ => pure True

init : () -> IO ()
init () = foreign FFI_C "mongoc_init" (IO ())

cleanUp : () -> IO ()
cleanUp () = foreign FFI_C "mongoc_cleanup" (IO ())

data URI = MkURI CData

uri : String -> IO (Maybe URI)
uri uriString = do
  cData <- foreign FFI_C "idris_mongoc_uri_new_with_error"
    (String -> IO CData) uriString
  isError <- isCDataPtrNull cData
  pure $ case isError of
    True => Nothing
    False => Just $ MkURI cData

data Client = MkClient CData

private
mkClient : URI -> IO Client
mkClient (MkURI uri) = do
  clientCData <- foreign FFI_C "idris_mongoc_client_new_from_uri"
    (CData -> IO CData) uri
  pure $ MkClient clientCData

private
clientSetAppName : Client -> String -> IO (Maybe ())
clientSetAppName (MkClient client) appName = do
  successCode <-
    foreign FFI_C "idris_mongoc_client_set_appname"
      (CData -> String -> IO Int) client appName
  case successCode of
    0 => pure Nothing
    _ => pure $ Just ()

client : URI -> String -> IO (Maybe Client)
client uri appName = do
  client' <- mkClient uri
  success <- clientSetAppName client' appName
  case success of
    Nothing => pure Nothing
    Just () => pure $ Just client'

simpleCommand : Client -> String -> Document -> IO (Maybe BSon)
simpleCommand (MkClient client) db command = do
  MkBSon bSonCommand <- bSon command
  reply <- foreign FFI_C "idris_mongoc_client_command_simple"
    (CData -> String -> CData -> IO CData) client db bSonCommand
  failure <- isCDataPtrNull reply
  case failure of
    True => pure Nothing
    False => pure $ Just $ MkBSon reply

data DataBase = MkDataBase CData

dataBase : Client -> String -> IO DataBase
dataBase (MkClient clientCData) name = do
  cData <- foreign FFI_C "idris_mongoc_client_get_database"
    (CData -> String -> IO CData) clientCData name
  pure $ MkDataBase cData

data Collection = MkCollection CData

collection : Client -> String -> String -> IO Collection
collection (MkClient clientCData) db name = do
  cData <- foreign FFI_C "idris_mongoc_client_get_collection"
    (CData -> String -> String -> IO CData) clientCData db name
  pure $ MkCollection cData

insertOne : Collection -> Document -> IO (Maybe ())
insertOne (MkCollection collection) document = do
  MkBSon bSonDocument <- bSon document
  success <- foreign FFI_C "idris_mongoc_collection_insert_one"
    (CData -> CData -> IO Int) collection bSonDocument
  case success of
    0 => pure Nothing
    _ => pure $ Just ()