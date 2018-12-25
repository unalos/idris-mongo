module Collection

import Common
import BSon
import ISon
import Mongo
import Client

%lib     C "mongoc-1.0"
%link    C "idris_mongo_collection.o"
%include C "idris_mongo_collection.h"

%access export
%default covering

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
  Just (MkBSon bSonDocument) <- bSon document
    | Nothing => pure Nothing
  success <- foreign FFI_C "idris_mongoc_collection_insert_one"
    (CData -> CData -> IO Int) collection bSonDocument
  case success of
    0 => pure Nothing
    _ => pure $ Just ()

insertMany : Collection -> List Document -> IO (Maybe ())
insertMany (MkCollection collection) documents =
  do
    Just bSons <- auxToBSons (pure $ Just []) documents
      | Nothing => pure Nothing
    success <- foreign FFI_C "idris_mongoc_collection_insert_many"
      (CData -> Raw (List BSon) -> Int -> IO Int) collection (MkRaw bSons) (size bSons)
    case success of
      0 => pure Nothing
      _ => pure $ Just ()
  where

    auxToBSons : IO (Maybe (List BSon)) -> List Document -> IO (Maybe (List BSon))
    auxToBSons bSonsIO (head::tail) = do
      Just bSons <- bSonsIO
        | Nothing => pure Nothing
      Just bSon <- bSon head
        | Nothing => pure Nothing
      auxToBSons (pure $ Just (bSon::bSons)) tail
    auxToBSons bSonsIO [] = do
      Just bSons <- bSonsIO
        | Nothing => pure Nothing
      pure $ Just $ reverse bSons

    size : List BSon -> Int
    size list = aux 0 list where
      aux : Int -> List BSon -> Int
      aux counted (_::tail) = aux (counted + 1) tail
      aux counted [] = counted
