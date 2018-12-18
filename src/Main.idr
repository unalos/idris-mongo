module Main

import BSon
import Mongo

connectionUri : IO String
connectionUri = do
  [_, uri] <- getArgs
  pure uri

main : IO ()
main = do
  () <- Mongo.init ()
  uri_string <- connectionUri
  putStrLn uri_string
  Just uri <- uri uri_string
  () <- cleanup ()
  Just client <- client uri "connect-example"
  database <- database client "db_name"
  collection <- collection client "db_name" "coll_name"
  bSon <- BSon.init ()
  pure ()
