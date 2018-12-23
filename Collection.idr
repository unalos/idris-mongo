module Collection

import Common
import BSon
import ISon
import Mongo

%lib C "mongoc-1.0"
%link C "idris_mongo.o"
%include C "idris_mongo.h"

%access export

data Collection = MkCollection CData

collection : Client -> String -> String -> IO Collection
collection (MkClient clientCData) db name = do
  cData <- foreign FFI_C "idris_mongoc_client_get_collection"
    (CData -> String -> String -> IO CData) clientCData db name
  pure $ MkCollection cData

dropCollection : Collection -> IO (Maybe ())
dropCollection (MkCollection collection) = do
  success <- foreign FFI_C "idris_mongoc_collection_drop_with_opts"
    (CData -> IO Int) collection
  case success of
    0 => pure Nothing
    _ => pure $ Just ()

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
