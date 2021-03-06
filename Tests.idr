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
%default covering

private
uriString : String
uriString = "mongodb://localhost"

private
dataBaseName : String
dataBaseName = "idris_mongo_test"

private
data TestOutcome =
    Success
  | Failure (Maybe String)

private
noopBefore : IO (Maybe ())
noopBefore = pure $ Just ()

private
noopAfter : IO ()
noopAfter = pure ()

private
failWith : String -> IO ()
failWith message = do
  () <- putStrLn message
  exitWith (ExitFailure (-1))

private
test : String
       -> {default noopBefore before : Lazy (IO (Maybe t))}
       -> {default noopAfter after : Lazy (IO ())}
       -> (t -> IO TestOutcome) -> IO ()
test testName {before} {after} testProcedure = do
    Just initialized <- before
      | Nothing => failWith ("Test " ++ testName ++ " failed: Setup failed.")
    outcome <- testProcedure initialized
    () <- after
    case outcome of
      Success =>
        putStrLn ("Test " ++ testName ++ " passed.")
      Failure Nothing =>
        failWith ("Test " ++ testName ++ " failed.")
      Failure (Just message) =>
        failWith ("Test " ++ testName ++ " failed: " ++ message)

private
assertRight : IO (Either BSonError right) -> IO TestOutcome
assertRight expression = do
  Right _ <- expression
    | Left error => do
      message <- show error
      pure (Failure $ Just message)
  pure Success

private
assertEquals : Eq a => Show a => a -> a -> IO TestOutcome
assertEquals x y =
  case x == y of
    True => pure Success
    False => pure $ Failure $ Just ((show x) ++ " does not equal " ++ (show y))

||| Tests conversion of JSon to BSon.
testBSonFromJSon : IO ()
testBSonFromJSon = test "testBSonFromJSon" procedure where
  procedure : () -> IO TestOutcome
  procedure () = do
    assertRight $ fromJSon "{ \"hello\" : \"world\" }"

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
getClient : () -> IO (Maybe Client)
getClient () = do
  Just uri <- uri uriString
    | Nothing => pure Nothing
  Just client <- client uri "idris_mongo_test"
    | Nothing => pure Nothing
  pure $ Just client

private
noop : Client -> IO (Maybe ())
noop _ = pure $ Just ()

private
mongoTest : String -> {default noop setUp: Client -> IO (Maybe ())}
            -> (Client -> IO TestOutcome) -> IO ()
mongoTest testName {setUp} = test testName
  {before = (do
    () <- Mongo.init ()
    Just client <- getClient ()
      | Nothing => pure Nothing
    Just () <- setUp client
      | Nothing => pure Nothing
    pure $ Just client)}
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
    dataBase <- dataBase client dataBaseName
    pure Success

private
data InsertException =
    OptionsGenerationException
  | MkInsertException InsertOneException

private
insert : Collection -> IO (Either InsertException ())
insert collection = do
  concern <- writeConcern
  Just options <- writeConcernOptions concern
    | Nothing => pure (Left OptionsGenerationException)
  Right () <- insertOne collection document options
    | Left exception => pure (Left $ MkInsertException exception)
  pure $ Right ()

||| Should successfully insert a document in a collection.
testInsertCollection : IO ()
testInsertCollection = mongoTest "testInsertCollection" procedure where
  procedure : Client -> IO TestOutcome
  procedure client = do
    collection <- collection client dataBaseName "testCollection"
    Right () <- insert collection
      | Left OptionsGenerationException =>
        pure (Failure $ Just "Could not generate options.")
      | Left (MkInsertException DocumentGenerationException) =>
        pure (Failure $ Just "Failed to pass document as argument.")
      | Left (MkInsertException (InsertOneCException error)) => do
        message <- show error
        pure (Failure $ Just message)
    pure Success

testInsertMany : IO ()
testInsertMany = mongoTest "testInsertMany" procedure where
  procedure : Client -> IO TestOutcome
  procedure client = do
    collection <- collection client dataBaseName "testCollection"
    Just () <- insertMany collection [document, document]
    pure Success

private
testDropCollectionSetUp : Client -> IO (Maybe ())
testDropCollectionSetUp client = do
  collection <- collection client dataBaseName "testCollection"
  Right () <- insert collection
  pure $ Just ()

||| Should successfully drop a collection.
testDropCollection : IO ()
testDropCollection =
  mongoTest "testDropCollection" {setUp = testDropCollectionSetUp} procedure
  where
    procedure : Client -> IO TestOutcome
    procedure client = do
      collection <- collection client dataBaseName "testCollection"
      Right () <- dropCollection collection
        | Left _ => pure (Failure Nothing)
      pure Success

private
testDropDropCollectionSetUp : Client -> IO (Maybe ())
testDropDropCollectionSetUp client = do
  collection <- collection client dataBaseName "testCollection"
  Right () <- dropCollection collection
    | Left error => do
      code <- errorCode error
      if 26 == code then pure (Just ()) else pure Nothing
  pure $ Just ()

||| Should fail with error code 26 when dropping an non existent collection.
testDropDropCollection : IO ()
testDropDropCollection =
  mongoTest "testDropDropCollection" {setUp = testDropDropCollectionSetUp} procedure
  where
    procedure : Client -> IO TestOutcome
    procedure client = do
      collection <- collection client dataBaseName "testCollection"
      Right () <- dropCollection collection
        | Left error => do
          code <- errorCode error
          if 26 == code
            then pure Success
            else pure (Failure Nothing)
      pure Success

||| Should successfully clone a collection as a capped collection.
testCloneCollectionAsCapped : IO ()
testCloneCollectionAsCapped = mongoTest "testCloneCollectionAsCapped" procedure where
  procedure : Client -> IO TestOutcome
  procedure client = do
    srcCollection <- collection client dataBaseName "testCollection"
    Right () <- insert srcCollection
    destCollection <- collection client dataBaseName "clonedCollection"
    Right () <- dropCollection destCollection
    let cloneCollectionAsCappedCommand =
      cloneCollectionAsCapped "testCollection" "clonedCollection" (1024 * 1024)
    concern <- writeConcern {w = W_MAJORITY}
    Just opts <- writeConcernOptions concern
    Right reply <- writeCommand client dataBaseName
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
    Right reply <- readCommand client dataBaseName
      distinctCommand readPrefs opts
      | Left error => do
        errorMessage <- show error
        pure $ Failure Nothing
    pure Success
