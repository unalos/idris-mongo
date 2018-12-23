module Tests

import BSon
import ISon
import Mongo

%access export

private
uriString : String
uriString = "mongodb://localhost"

private
document : Document
document = MkDocument [("hello", UTF8Value "world")]

testRelaxedJSon : IO ()
testRelaxedJSon = do
  bSon <- bSon document
  jSon <- relaxedExtendedJSon bSon
  let True = jSon == "{ \"hello\" : \"world\" }"
  pure ()

testCanonicalJSon : IO ()
testCanonicalJSon = do
  bSon <- bSon document
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
pingCommand : Document
pingCommand = MkDocument [("ping", Int32Value 1)]

private
ping : Client -> IO String
ping client = do
  Just reply <- simpleCommand client "admin" pingCommand
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
  do bSon <- bSon document
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
