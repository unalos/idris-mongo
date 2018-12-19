module ISon

import BSon

%access export

public export
data Value : Type where
  Bits32Value : Bits32 -> Value
  UTF8Value   : String -> Value

public export
data Document : Type where
  MkDocument : List (String, Value) -> Document

bSon : Document -> IO BSon
bSon (MkDocument entries) =
  foldl append (BSon.init ()) entries where
  append : IO BSon -> (String, Value) -> IO BSon
  append accu (key, Bits32Value value) = do
    b <- accu
    () <- appendInt32 b key value
    pure b
  append accu (key, UTF8Value value) = do
    b <- accu
    () <- appendUTF8 b key value
    pure b
