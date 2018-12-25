module ISon

import BSon

%access export
%default covering

mutual

  public export
  data Value : Type where
    UTF8Value     : String   -> Value
    DocumentValue : Document -> Value
    Int32Value    : Bits32   -> Value
    Int64Value    : Bits64   -> Value

  public export
  data Document : Type where
    MkDocument : List (String, Value) -> Document

mutual

  Show Value where
    show (UTF8Value string)       = show string
    show (DocumentValue document) = show document
    show (Int32Value int32)       = show int32
    show (Int64Value int64)       = show int64

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
      pure $ Just $ MkDocument $ reverse document
    where
      append : List (String, Value) -> String -> Value -> List (String, Value)
      append keyValues key value = (key, value)::keyValues

  private
  foldIterator : (acc -> String -> Value -> acc) -> acc
                 -> Iterator -> IO (Maybe acc)
  foldIterator func accu iterator = do
    code <- iterNext iterator
    case code of
      0 => pure $ Just accu
      _ => do
        key <- iterKey iterator
        Just value <- iterValue iterator
        foldIterator func (func accu key value) iterator

  private
  iterValue : Iterator -> IO (Maybe Value)
  iterValue iterator = do
      typeCode <- iterType iterator
      utf8 <- typeUTF8
      document <- typeDocument
      int32 <- typeInt32
      int64 <- typeInt64
      cond [
        (typeCode == utf8, extractUTF8 iterator),
        (typeCode == document, extractDocument iterator),
        (typeCode == int32, extractInt32 iterator),
        (typeCode == int64, extractInt64 iterator)
      ] (pure Nothing)
    where

      extractUTF8 : Iterator -> IO (Maybe Value)
      extractUTF8 iterator = do
        utf8Value <- iterUTF8 iterator
        Just () <- UTF8Validate utf8Value
          | Nothing => pure Nothing
        pure $ Just (UTF8Value utf8Value)

      extractDocument : Iterator -> IO (Maybe Value)
      extractDocument iterator = do
        Just childIterator <- iterRecurse iterator
          | Nothing => pure Nothing
        Just document <- documentValue childIterator
          | Nothing => pure Nothing
        pure $ Just (DocumentValue document)

      extractInt32 : Iterator -> IO (Maybe Value)
      extractInt32 iterator = do
        int32Value <- iterInt32 iterator
        pure $ Just (Int32Value int32Value)

      extractInt64 : Iterator -> IO (Maybe Value)
      extractInt64 iterator = do
        int64Value <- iterInt64 iterator
        pure $ Just (Int64Value int64Value)

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
  append accu (key, UTF8Value value) =
    appendUsing appendUTF8  accu key value
  append accu (key, DocumentValue value) = do
    Just bSonValue <- bSon value
      | Nothing => pure Nothing
    appendUsing appendDocument accu key (bSonValue)
  append accu (key, Int32Value value) =
    appendUsing appendInt32 accu key value
  append accu (key, Int64Value value) =
    appendUsing appendInt64 accu key value
