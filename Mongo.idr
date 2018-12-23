module Mongo

import BSon
import ISon

%lib C "mongoc-1.0"
%link C "idris_mongo.o"
%include C "idris_mongo.h"
%access export

private
isCDataPtrNull : CData -> IO Bool
isCDataPtrNull cData = do
  success <- foreign FFI_C "idris_mongoc_is_C_data_ptr_null"
    (CData -> IO Int) cData
  case success of
    0 => pure False
    _ => pure True

init : () -> IO ()
init () = foreign FFI_C "idris_mongoc_init" (IO ())

cleanUp : () -> IO ()
cleanUp () = foreign FFI_C "idris_mongoc_cleanup" (IO ())

data URI = MkURI CData

uri : String -> IO (Maybe URI)
uri uriString = do
  cData <- foreign FFI_C "idris_mongoc_uri_new_with_error"
    (String -> IO CData) uriString
  isError <- isCDataPtrNull cData
  case isError of
    True => pure Nothing
    False => pure (Just $ MkURI cData)

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

insertMany : Collection -> List Document -> IO (Maybe ())
insertMany (MkCollection collection) documents =
  do
    bSons <- auxToBSon (pure []) documents
    success <- foreign FFI_C "idris_mongoc_collection_insert_many"
      (CData -> Raw (List BSon) -> Int -> IO Int) collection (MkRaw bSons) (size bSons)
    case success of
      0 => pure Nothing
      _ => pure $ Just ()
  where
  
    auxToBSon : IO (List BSon) -> List Document -> IO (List BSon)
    auxToBSon bSonsIO [] = bSonsIO
    auxToBSon bSonsIO (head::tail) = do
      bSon <- bSon head
      bSons <- bSonsIO
      auxToBSon (pure (bSon::bSons)) tail
    
    size : List BSon -> Int
    size list = aux 0 list where
      aux : Int -> List BSon -> Int
      aux counted (_::tail) = aux (counted + 1) tail
      aux counted [] = counted
