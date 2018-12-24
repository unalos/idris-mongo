module Command

import BSon
import ISon

%access export

ping : Document
ping = MkDocument [("ping", Int32Value 1)]

cloneCollectionAsCapped : String -> String -> Bits64 -> Document
cloneCollectionAsCapped existingCollection cappedCollection size = MkDocument
  [
    ("cloneCollectionAsCapped", UTF8Value existingCollection),
    ("toCollection",            UTF8Value cappedCollection),
    ("size",                    Int64Value size)
  ]

distinct : String -> String -> Document -> Document
distinct collection field query = MkDocument
  [
    ("distinct", UTF8Value collection),
    ("key",      UTF8Value field),
    ("query",    DocumentValue query)
  ]
