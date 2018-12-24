module Tests

import System
import BSon
import ISon
import BSonError
import Mongo
import Command
import WriteConcern
import Options
import Client
import Collection

%access export

private
uriString : String
uriString = "mongodb://localhost"

testBSonFromJSon : IO ()
testBSonFromJSon = do
  Just _ <- fromJSon "{ \"hello\" : \"world\" }"
  pure ()

private
document : Document
document = MkDocument [("hello", UTF8Value "world")]

testRelaxedJSon : IO ()
testRelaxedJSon = do
  Just bSon <- bSon document
  jSon <- relaxedExtendedJSon bSon
  let True = jSon == "{ \"hello\" : \"world\" }"
  pure ()

testCanonicalJSon : IO ()
testCanonicalJSon = do
  Just bSon <- bSon document
  jSon <- canonicalExtendedJSon bSon
  let True = jSon == "{ \"hello\" : \"world\" }"
  pure ()

private
getClient : () -> IO Client
getClient () = do
  Just uri <- uri uriString
  Just client <- client uri "idris_mongo_test"
  pure client

private
ping : Client -> IO String
ping client = do
  Just reply <- simpleCommand client "admin" Command.ping
  canonicalExtendedJSon reply

testPing : IO ()
testPing = do
  () <- Mongo.init ()
  client <- getClient ()
  pingReply <- ping client
  let True = pingReply == "{ \"ok\" : { \"$numberDouble\" : \"1.0\" } }"
  cleanUp ()

testDataBase : IO ()
testDataBase = do
  () <- Mongo.init ()
  client <- getClient ()
  dataBase <- dataBase client "idris_mongo_test"
  cleanUp()

private
printDocument : Document -> IO ()
printDocument document =
  do Just bSon <- bSon document
     Just action <- fold aux (pure ()) bSon
     action
  where
    aux : IO () -> String -> Value -> IO ()
    aux accu key value = do
      () <- accu
      putStrLn key
      putStrLn (show value)

private
insert : Collection -> IO ()
insert collection = do
  () <- printDocument document
  Just () <- insertOne collection document
  pure ()

testInsertCollection : IO ()
testInsertCollection = do
  () <- Mongo.init ()
  client <- getClient ()
  collection <- collection client "idris_mongo_test" "testCollection"
  () <- insert collection
  cleanUp ()

testInsertMany : IO ()
testInsertMany = do
  () <- Mongo.init ()
  client <- getClient ()
  collection <- collection client "idris_mongo_test" "testCollection"
  Just () <- insertMany collection [document, document]
  cleanUp ()

testDropCollection : IO ()
testDropCollection = do
  () <- Mongo.init ()
  client <- getClient ()
  collection <- collection client "idris_mongo_test" "testCollection"
  Just () <- dropCollection collection
  cleanUp ()

testCloneCollectionAsCapped : IO ()
testCloneCollectionAsCapped = do
  () <- Mongo.init ()
  client <- getClient ()
  srcCollection <- collection client "idris_mongo_test" "testCollection"
  () <- insert srcCollection
  destCollection <- collection client "idris_mongo_test" "clonedCollection"
  Just () <- dropCollection destCollection
  let cloneCollectionAsCappedCommand =
    cloneCollectionAsCapped "testCollection" "clonedCollection" (1024 * 1024)
  concern <- writeConcern {wMajority = True}
  Just opts <- options concern
  Right reply <- writeCommand client "idris_mongo_test"
                   cloneCollectionAsCappedCommand opts
    | Left (WriteCommandCException error) => do
        () <- putStrLn "WriteCommandCException"
        message <- errorMessage error
        () <- putStrLn message
        exitWith (ExitFailure (-1))
    | Left BSonWriteCommandGenerationException => do
        () <- putStrLn "BSonCommandGenerationException"
        exitWith (ExitFailure (-1))
  jSon <- canonicalExtendedJSon reply
  () <- putStrLn jSon
  cleanUp ()

testDistinct : IO ()
testDistinct = do
  () <- Mongo.init ()
  client <- getClient ()
  let distinctCommand = distinct
  -- TODO
  cleanUp ()
