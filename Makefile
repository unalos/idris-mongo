IDRIS=idris
IDRIS_CFLAGS=$(shell pkg-config --cflags libbson-1.0) $(shell pkg-config --cflags libmongoc-1.0)

export IDRIS_CFLAGS

all:
	$(IDRIS) --build idris-mongo.ipkg

clean:
	$(IDRIS) --clean idris-mongo.ipkg
	rm -f src/*.ibc
