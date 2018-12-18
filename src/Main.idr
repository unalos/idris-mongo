module Main

import BSon
import Mongo

connectionUri : IO String
connectionUri = do
  [_, uri] <- getArgs
  pure uri

pingDocument : IO BSon
pingDocument = do
  bSon <- BSon.init ()
  () <- appendInt32 bSon "ping" 1
  pure bSon

document : IO BSon
document = do
  bSon <- BSon.init ()
  () <- appendUTF8 bSon "hello" "world"
  pure bSon

getClient : () -> IO Client
getClient () = do
  uri_string <- connectionUri
  Just uri <- uri uri_string
  Just client <- client uri "connect-example"
  pure client

ping : Client -> IO ()
ping client = do
  command <- pingDocument
  Just reply <- simpleCommand client "admin" command
  replyJSon <- canonicalExtendedJSon reply
  putStrLn replyJSon

insert : Collection -> IO ()
insert collection = do
  documentToInsert <- document
  Just () <- insertOne collection documentToInsert
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
