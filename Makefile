IDRIS_CFLAGS=$(shell pkg-config --cflags libbson-1.0) $(shell pkg-config --cflags libmongoc-1.0)
export IDRIS_CFLAGS

all: idrisMongo.bin

idrisMongo.bin:
	idris --build idris-mongo.ipkg

clean:
	idris --clean idris-mongo.ipkg
