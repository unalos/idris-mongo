module Main

import BSon
import ISon
import Mongo

connectionUri : IO String
connectionUri = do
  [_, uri] <- getArgs
  pure uri

pingCommand : Document
pingCommand = MkDocument [("ping", Int32Value 1)]

document : Document
document = MkDocument [("hello", UTF8Value "world")]

getClient : () -> IO Client
getClient () = do
  uri_string <- connectionUri
  Just uri <- uri uri_string
  Just client <- client uri "connect-example"
  pure client

ping : Client -> IO ()
ping client = do
  Just reply <- simpleCommand client "admin" pingCommand
  replyJSon <- canonicalExtendedJSon reply
  putStrLn replyJSon

print : Document -> IO ()
print document =
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
  () <- print document
  Just () <- insertOne collection document
  pure ()

main : IO ()
main = do
  () <- Mongo.init ()
  client <- getClient ()
  database <- database client "db_name"
  collection <- collection client "db_name" "coll_name"
  () <- ping client
  () <- insert collection
  cleanup ()
