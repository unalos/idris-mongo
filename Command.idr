module Command

import BSon
import ISon

%access export

ping : Document
ping = MkDocument [("ping", Int32Value 1)]
