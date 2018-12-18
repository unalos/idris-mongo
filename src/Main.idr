module Main

import BSon
import Mongo

connectionUri : IO String
connectionUri = do
  [_, uri] <- getArgs
  pure uri

ping : IO BSon
ping = do
  bSon <- BSon.init ()
  () <- appendInt32 bSon "ping" 1
  pure bSon

document : IO BSon
document = do
  bSon <- BSon.init ()
  () <- appendUTF8 bSon "hello" "world"
  pure bSon

main : IO ()
main = do
  () <- Mongo.init ()
  uri_string <- connectionUri
  Just uri <- uri uri_string
  () <- cleanup ()
  Just client <- client uri "connect-example"
  database <- database client "db_name"
  collection <- collection client "db_name" "coll_name"
  command <- ping
  Just reply <- simpleCommand client "admin" command
  replyJSon <- canonicalExtendedJSon reply
  putStrLn replyJSon
  documentToInsert <- document
  Just () <- insertOne collection documentToInsert
  pure ()
