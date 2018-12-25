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
test : String
       -> {default Nothing before : Maybe (Lazy (IO ()))}
       -> {default Nothing after : Maybe (Lazy (IO ()))}
       -> IO TestOutcome -> IO ()
test testName {before} {after} testProcedure = do
    () <- setUp before
    outcome <- testProcedure
    () <- setUp after
    case outcome of
      Success =>
        putStrLn ("Test " ++ testName ++ " passed.")
      Failure Nothing => do
        () <- putStrLn ("Test " ++ testName ++ " failed.")
        exitWith (ExitFailure (-1))
      Failure (Just message) => do
        () <- putStrLn ("Test " ++ testName ++ " failed: " ++ message)
        exitWith (ExitFailure (-1))
  where
    setUp : Maybe (Lazy (IO ())) -> IO ()
    setUp Nothing = pure ()
    setUp (Just action) = action

private
assertJust : IO (Maybe t) -> IO TestOutcome
assertJust expression = do
  Just _ <- expression
    | Nothing => pure (Failure Nothing)
  pure Success

private
assertEquals : Eq a => Show a => a -> a -> IO TestOutcome
assertEquals x y =
  case x == y of
    True => pure Success
    False => pure $ Failure $ Just ((show x) ++ " does not equal " ++ (show y))

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
documentRelaxedJSon : String
documentRelaxedJSon = "{ \"String\" : \"string\", \"Int32\" : 42, \"Int64\" : 42, \"Subdocument\" : { \"foo\" : \"bar\" } }"

private
documentCanonicalJSon : String
documentCanonicalJSon = "{ \"String\" : \"string\", \"Int32\" : { \"$numberInt\" : \"42\" }, \"Int64\" : { \"$numberLong\" : \"42\"}, \"Subdocument\" : { \"foo\" : \"bar\" } }"

testRelaxedJSon : IO ()
testRelaxedJSon = test "testRelaxedJSon" $ do
  Just bSon <- bSon document
    | Nothing => pure (Failure $ Just "bSon conversion failed.")
  jSon <- relaxedExtendedJSon bSon
  assertEquals jSon documentRelaxedJSon

testCanonicalJSon : IO ()
testCanonicalJSon = test "testCanonicalJSon" $ do
  Just bSon <- bSon document
  jSon <- canonicalExtendedJSon bSon
  assertEquals jSon documentCanonicalJSon

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
testPing = test "testPing" {before = Just $ Mongo.init ()} {after = Just $ cleanUp ()} $ do
  client <- getClient ()
  pingReply <- ping client
  assertEquals pingReply "{ \"ok\" : { \"$numberDouble\" : \"1.0\" } }"

testDataBase : IO ()
testDataBase = test "testDataBase" {before = Just $ Mongo.init ()} {after = Just $ cleanUp ()} $ do
  client <- getClient ()
  dataBase <- dataBase client "idris_mongo_test"
  pure Success

private
insert : Collection -> IO ()
insert collection = do
  Just () <- insertOne collection document
  pure ()

testInsertCollection : IO ()
testInsertCollection = test "testInsertCollection" {before = Just $ Mongo.init ()} {after = Just $ cleanUp ()} $ do
  client <- getClient ()
  collection <- collection client "idris_mongo_test" "testCollection"
  () <- insert collection
  pure Success

testInsertMany : IO ()
testInsertMany = test "testInsertMany" {before = Just $ Mongo.init ()} {after = Just $ cleanUp ()} $ do
  client <- getClient ()
  collection <- collection client "idris_mongo_test" "testCollection"
  Just () <- insertMany collection [document, document]
  pure Success

testDropCollection : IO ()
testDropCollection = test "testDropCollection" {before = Just $ Mongo.init ()} {after = Just $ cleanUp ()} $ do
  client <- getClient ()
  collection <- collection client "idris_mongo_test" "testCollection"
  Just () <- dropCollection collection
  pure Success

testCloneCollectionAsCapped : IO ()
testCloneCollectionAsCapped = test "testCloneCollectionAsCapped" {before = Just $ Mongo.init ()} {after = Just $ cleanUp ()} $ do
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
  pure Success

testDistinct : IO ()
testDistinct = test "testDistinct" {before = Just $ Mongo.init ()} {after = Just $ cleanUp ()} $ do
  client <- getClient ()
  let query = MkDocument [
    ("y", DocumentValue $ MkDocument [
      ("$gt", UTF8Value "one")
    ])
  ]
  let distinctCommand = distinct "testCollection" "hello" query
  readPrefs <- readPreferences SECONDARY
  concern <- readConcern {level = Just MAJORITY}
  Just opts <- readConcernOptions concern (MkDocument [
    ("collation", DocumentValue $ MkDocument [
      ("locale", UTF8Value "en_US"),
      ("caseFirst", UTF8Value "lower")
    ])])
    | Nothing => pure (Failure Nothing)
  Right reply <- readCommand client "idris_mongo_test"
    distinctCommand readPrefs opts
    | Left error => do
      errorMessage <- show error
      pure $ Failure Nothing
  pure Success
