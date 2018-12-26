module Collection

import Common
import BSon
import ISon
import BSonError
import Mongo
import Client
import Options

%lib     C "mongoc-1.0"
%link    C "idris_mongo_collection.o"
%include C "idris_mongo_collection.h"

%access export
%default covering

data Collection = MkCollection CData

collection : Client -> String -> String -> IO Collection
collection (MkClient client) db name = do
  cData <- foreign FFI_C "idris_mongoc_client_get_collection"
    (CData -> String -> String -> IO CData) client db name
  pure $ MkCollection cData

private
handleSuccessCode : IO Int -> IO (Maybe ())
handleSuccessCode successIO = do
  success <- successIO
  case success of
    0 => pure Nothing
    _ => pure $ Just ()

||| Drops a collection.
|||
||| If the collection does not exist, fails with error code 26.
|||
||| @ collection The collection to be dropped.
dropCollection : (collection : Collection) -> IO (Either BSonError ())
dropCollection (MkCollection collection) = do
  MkBSonError errorPlaceHolder <- newErrorPlaceHolder ()
  success <- foreign FFI_C "idris_mongoc_collection_drop_with_opts"
    (CData -> CData -> IO Int) collection errorPlaceHolder
  case success of
    0 => pure $ Left $ MkBSonError errorPlaceHolder
    _ => pure $ Right ()

||| Exception potentially raised by `insertOne`.
|||
||| InsertOneCException: `BSonError` raised by `insertOne`.
|||
||| DocumentGenerationException: Raised when failed to pass the document as
||| argument to `insertOne`.
public export
data InsertOneException =
    InsertOneCException BSonError
  | DocumentGenerationException

||| Inserts a document in a collection.
|||
||| @ collection The collection in which to insert.
||| @ document The document to insert.
insertOne : (collection : Collection) -> (document: Document)
            -> Options -> IO (Either InsertOneException ())
insertOne (MkCollection collection) document (MkOptions options) = do
  Just (MkBSon bSonDocument) <- bSon document
    | Nothing => pure (Left DocumentGenerationException)
  MkBSonError errorPlaceHolder <- newErrorPlaceHolder ()
  success <- foreign FFI_C "idris_mongoc_collection_insert_one"
    (CData -> CData -> CData -> CData -> IO Int)
    collection bSonDocument options errorPlaceHolder
  case success of
    0 => pure $ Left $ InsertOneCException $ MkBSonError errorPlaceHolder
    _ => pure $ Right ()

insertMany : Collection -> List Document -> IO (Maybe ())
insertMany (MkCollection collection) documents =
  do
    Just bSons <- auxToBSons (pure $ Just []) documents
      | Nothing => pure Nothing
    handleSuccessCode $ foreign FFI_C "idris_mongoc_collection_insert_many"
      (CData -> Raw (List BSon) -> Int -> IO Int)
      collection (MkRaw bSons) (size bSons)
  where

    auxToBSons : IO (Maybe (List BSon)) -> List Document
                 -> IO (Maybe (List BSon))
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
