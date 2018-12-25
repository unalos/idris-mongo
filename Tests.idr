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
noop : IO ()
noop = pure ()

private
test : String
       -> {default noop before : Lazy (IO t)}
       -> {default noop after : Lazy (IO ())}
       -> (t -> IO TestOutcome) -> IO ()
test testName {before} {after} testProcedure = do
    initialized <- before
    outcome <- testProcedure initialized
    () <- after
    case outcome of
      Success =>
        putStrLn ("Test " ++ testName ++ " passed.")
      Failure Nothing => do
        () <- putStrLn ("Test " ++ testName ++ " failed.")
        exitWith (ExitFailure (-1))
      Failure (Just message) => do
        () <- putStrLn ("Test " ++ testName ++ " failed: " ++ message)
        exitWith (ExitFailure (-1))

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
testBSonFromJSon = test "testBSonFromJSon" procedure where
  procedure : () -> IO TestOutcome
  procedure () = do
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
testRelaxedJSon = test "testRelaxedJSon" procedure where
  procedure : () -> IO TestOutcome
  procedure () = do
    Just bSon <- bSon document
      | Nothing => pure (Failure $ Just "bSon conversion failed.")
    jSon <- relaxedExtendedJSon bSon
    assertEquals jSon documentRelaxedJSon

testCanonicalJSon : IO ()
testCanonicalJSon = test "testCanonicalJSon" procedure where
  procedure : () -> IO TestOutcome
  procedure () = do
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
mongoTest : String -> (Client -> IO TestOutcome) -> IO ()
mongoTest testName = test testName
  {before = (do
    () <- Mongo.init ()
    client <- getClient ()
    pure client)}
  {after = cleanUp ()}

private
ping : Client -> IO String
ping client = do
  Just reply <- simpleCommand client "admin" Command.ping
  canonicalExtendedJSon reply

testPing : IO ()
testPing = mongoTest "testPing" procedure where
  procedure : Client -> IO TestOutcome
  procedure client = do
    pingReply <- ping client
    assertEquals pingReply "{ \"ok\" : { \"$numberDouble\" : \"1.0\" } }"

testDataBase : IO ()
testDataBase = mongoTest "testDataBase" procedure where
  procedure : Client -> IO TestOutcome
  procedure client = do
    dataBase <- dataBase client "idris_mongo_test"
    pure Success

private
insert : Collection -> IO ()
insert collection = do
  Just () <- insertOne collection document
  pure ()

testInsertCollection : IO ()
testInsertCollection = mongoTest "testInsertCollection" procedure where
  procedure : Client -> IO TestOutcome
  procedure client = do
    collection <- collection client "idris_mongo_test" "testCollection"
    () <- insert collection
    pure Success

testInsertMany : IO ()
testInsertMany = mongoTest "testInsertMany" procedure where
  procedure : Client -> IO TestOutcome
  procedure client = do
    collection <- collection client "idris_mongo_test" "testCollection"
    Just () <- insertMany collection [document, document]
    pure Success

testDropCollection : IO ()
testDropCollection = mongoTest "testDropCollection" procedure where
  procedure : Client -> IO TestOutcome
  procedure client = do
    collection <- collection client "idris_mongo_test" "testCollection"
    Just () <- dropCollection collection
    pure Success

testCloneCollectionAsCapped : IO ()
testCloneCollectionAsCapped = mongoTest "testCloneCollectionAsCapped" procedure where
  procedure : Client -> IO TestOutcome
  procedure client = do
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
testDistinct = mongoTest "testDistinct" procedure where
  procedure : Client -> IO TestOutcome
  procedure client = do
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
