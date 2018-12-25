module Tests

import System
import BSon
import ISon
import BSonError
import Mongo
import ReadPreferences
import Command
import WriteConcern
import ReadConcern
import Options
import Client
import Collection

%access export
--%default covering

private
uriString : String
uriString = "mongodb://localhost"

private
data TestOutcome =
    Success
  | Failure (Maybe String)

private
test : String -> IO TestOutcome -> IO ()
test testName testProcedure = do
  outcome <- testProcedure
  case outcome of
    Success =>
      putStrLn ("Test " ++ testName ++ " passed.")
    Failure Nothing => do
      () <- putStrLn ("Test " ++ testName ++ " failed.")
      exitWith (ExitFailure (-1))
    Failure (Just message) => do
      () <- putStrLn ("Test " ++ testName ++ " failed: " ++ message)
      exitWith (ExitFailure (-1))

--private
--failWith : String -> IO ()
--failWith message = do
--  () <- putStrLn message
--  exitWith (ExitFailure (-1))

--private
--succeedsWith : String -> IO ()
--succeedsWith message = putStrLn message

private
assertJust : IO (Maybe t) -> IO TestOutcome
assertJust expression = do
  Just _ <- expression
    | Nothing => pure (Failure Nothing)
  pure Success

testBSonFromJSon : IO ()
testBSonFromJSon = test "testBSonFromJSon" $ do
  assertJust $ fromJSon "{ \"hello\" : \"world\" }"

private
document : Document
document = MkDocument
  [
    ("String"     , UTF8Value "string"),
    ("Int32"      , Int32Value 42),
    ("Int64"      , Int64Value 42),
    ("Subdocument", DocumentValue $ MkDocument
      [
        ("foo", UTF8Value "bar")
      ])
  ]

private
documentJSon : String
documentJSon = "{ \"String\" : \"string\", \"Int32\" : 42, \"Int64\" : 42, \"Subdocument\" : { \"foo\" : \"bar\" } }"

testRelaxedJSon : IO ()
testRelaxedJSon = test "testRelaxedJSon" $ do
  Just bSon <- bSon document
    | Nothing => pure (Failure $ Just "bSon conversion failed.")
  jSon <- relaxedExtendedJSon bSon
  case (jSon == documentJSon) of
    True => pure Success
    False => pure $ Failure $ Just jSon

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
  Just opts <- writeConcernOptions concern
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

--testDistinct : IO ()
--testDistinct = do
--  () <- Mongo.init ()
--  client <- getClient ()
--  let query = MkDocument [
--    ("y", DocumentValue $ MkDocument [
--      ("$gt", UTF8Value "one")
--    ])
--  ]
--  let distinctCommand = distinct "testCollection" "hello" query
--  readPrefs <- readPreferences SECONDARY
--  concern <- readConcern {level = Just MAJORITY}
--  Just opts <- readConcernOptions concern (MkDocument [
--    ("collation", DocumentValue $ MkDocument [
--      ("locale", UTF8Value "en_US"),
--      ("caseFirst", UTF8Value "lower")
--    ])])
--    | Nothing => failWith "Could not create read concern options"
--  Right reply <- readCommand client "idris_mongo_test"
--    distinctCommand readPrefs opts
--    | Left error => do
--      errorMessage <- show error
--      failWith errorMessage
--  cleanUp ()
