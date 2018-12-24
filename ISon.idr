module ISon

import BSon

%access export
%default total

public export
data Document : Type where
  MkDocument : List (String, Value) -> Document

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
  append accu (key, Int32Value value) = appendUsing appendInt32 accu key value
  append accu (key, Int64Value value) = appendUsing appendInt64 accu key value
  append accu (key, UTF8Value value)  = appendUsing appendUTF8  accu key value
