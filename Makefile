all: idrisMongo.bin

idrisMongo.bin:
	idris --build idris-mongo.ipkg

clean:
	idris --clean idris-mongo.ipkg
