module ISon

import BSon

%access export
%default total

public export
data Document : Type where
  MkDocument : List (String, Value) -> Document

bSon : Document -> IO BSon
bSon (MkDocument entries) = foldl append (BSon.bSon ()) entries where

  appendUsing : (BSon -> String -> t -> IO ()) -> IO BSon -> String -> t -> IO BSon
  appendUsing appender accu key value = do
    bSon <- accu
    () <- appender bSon key value
    pure bSon

  append : IO BSon -> (String, Value) -> IO BSon
  append accu (key, Int32Value value) = appendUsing appendInt32 accu key value
  append accu (key, Int64Value value) = appendUsing appendInt64 accu key value
  append accu (key, UTF8Value value)  = appendUsing appendUTF8  accu key value
