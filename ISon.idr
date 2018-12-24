module ISon

import BSon

%access export
%default total

mutual

  public export
  data Value : Type where
    Int32Value    : Bits32 -> Value
    Int64Value    : Bits64 -> Value
    UTF8Value     : String -> Value
    DocumentValue : Document -> Value

  public export
  data Document : Type where
    MkDocument : List (String, Value) -> Document

mutual

  Show Value where
    show (Int32Value int32) = show int32
    show (Int64Value int64) = show int64
    show (UTF8Value string) = show string
    show (DocumentValue document) = show document

  Show Document where
    show (MkDocument keyValues) = "{" ++ (aux "" True keyValues) ++ "}" where
      aux : String -> Bool -> List (String, Value) -> String
      aux accu beginning ((key, value)::tail) =
        let commaOrNothing = if beginning then "" else ", " in
        aux (commaOrNothing ++ (show key) ++ ": " ++ (show value)) False tail
      aux accu _ [] = accu

private
cond : List (Lazy Bool, Lazy a) -> a -> a
cond [] def = def
cond ((x, y) :: xs) def = if x then y else cond xs def

mutual

  private
  documentValue : Iterator -> IO (Maybe Document)
  documentValue iterator = do
      Just document <- foldIterator append [] iterator
        | Nothing => pure Nothing
      pure $ Just $ MkDocument (reverse document)
    where
      append : List (String, Value) -> String -> Value -> List (String, Value)
      append keyValues key value = (key, value)::keyValues

  private
  iterValue : Iterator -> IO (Maybe Value)
  iterValue iterator = do
    typeCode <- iterType iterator
    utf8 <- typeUTF8
    int32 <- typeInt32
    int64 <- typeInt64
    document <- typeDocument
    cond [
      (typeCode == utf8, do
        utf8Value <- iterUTF8 iterator
        Just () <- UTF8Validate utf8Value
          | Nothing => pure Nothing
        pure $ Just (UTF8Value utf8Value)),
      (typeCode == int32, do
        int32Value <- iterInt32 iterator
        pure $ Just (Int32Value int32Value)),
      (typeCode == int64, do
        int64Value <- iterInt64 iterator
        pure $ Just (Int64Value int64Value)),
      (typeCode == document, do
        Just childIterator <- iterRecurse iterator
          | Nothing => pure Nothing
        Just document <- documentValue childIterator
          | Nothing => pure Nothing
        pure $ Just (DocumentValue document))
    ] (pure Nothing)

  private
  foldIterator : (acc -> String -> Value -> acc) -> acc
                 -> Iterator -> IO (Maybe acc)
  foldIterator func init iterator =
      aux iterator init
    where
      aux : Iterator -> acc -> IO (Maybe acc)
      aux iterator acc = do
        code <- iterNext iterator
        case code of
          0 => pure $ Just acc
          _ => do
            key <- iterKey iterator
            Just value <- iterValue iterator
            aux iterator (func acc key value)

partial
fold : (acc -> String -> Value -> acc) -> acc
       -> BSon -> IO (Maybe acc)
fold func init bSon = do
  iterator <- iterInit bSon
  foldIterator func init iterator

bSon : Document -> IO (Maybe BSon)
bSon (MkDocument entries) =
  foldl append init entries where

  init : IO (Maybe BSon)
  init = do
    bSon <- BSon.bSon ()
    pure $ Just bSon

  appendUsing : (BSon -> String -> t -> IO (Maybe ()))
    -> IO (Maybe BSon) -> String -> t -> IO (Maybe BSon)
  appendUsing appender accu key value = do
    Just bSon <- accu
      | Nothing => pure Nothing
    Just () <- appender bSon key value
      | Nothing => pure Nothing
    pure $ Just bSon

  append : IO (Maybe BSon) -> (String, Value) -> IO (Maybe BSon)
  append accu (key, Int32Value value) =
    appendUsing appendInt32 accu key value
  append accu (key, Int64Value value) =
    appendUsing appendInt64 accu key value
  append accu (key, UTF8Value value) =
    appendUsing appendUTF8  accu key value
  append accu (key, DocumentValue value) =
    appendUsing appendDocument accu key value
