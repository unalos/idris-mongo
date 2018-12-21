module Tests

import BSon
import ISon
import Mongo

%access private

uriString : String
uriString = "mongodb://localhost"

document : Document
document = MkDocument [("hello", UTF8Value "world")]

getClient : () -> IO Client
getClient () = do
  Just uri <- uri uriString
  Just client <- client uri "testdb"
  pure client

pingCommand : Document
pingCommand = MkDocument [("ping", Int32Value 1)]

ping : Client -> IO String
ping client = do
  Just reply <- simpleCommand client "admin" pingCommand
  canonicalExtendedJSon reply

export
test1 : IO ()
test1 = do
  () <- Mongo.init ()
  client <- getClient ()
  pingReply <- ping client
  putStrLn pingReply
  cleanup ()

export
test2 : IO ()
test2 = do
  () <- Mongo.init ()
  client <- getClient ()
  database <- database client "testDatabase"
  cleanup()

printDocument : Document -> IO ()
printDocument document =
  do bSon <- bSon document
     action <- fold aux (pure ()) bSon
     action
  where
    aux : IO () -> String -> Value -> IO ()
    aux accu key value = do
      () <- accu
      putStrLn key
      putStrLn (show value)

insert : Collection -> IO ()
insert collection = do
  () <- printDocument document
  Just () <- insertOne collection document
  pure ()

export
test3 : IO ()
test3 = do
  () <- Mongo.init ()
  client <- getClient ()
  collection <- collection client "testDatabase" "testCollection"
  () <- insert collection
  cleanup()
