module ISon

import BSon

%access export

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

  append : IO (Maybe BSon) -> (String, Value) -> IO (Maybe BSon)
  append accu (key, Int32Value value) = do
    Just b <- accu
      | Nothing => pure Nothing
    Just () <- appendInt32 b key value
      | Nothing => pure Nothing
    pure $ Just b
  append accu (key, UTF8Value value) = do
    Just b <- accu
      | Nothing => pure Nothing
    Just () <- appendUTF8 b key value
      | Nothing => pure Nothing
    pure $ Just b
