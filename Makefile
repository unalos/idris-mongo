IDRIS=idris
IDRIS_CFLAGS=$(shell pkg-config --cflags libmongoc-1.0)
IDRIS_PKG=mongo.ipkg

export IDRIS_CFLAGS

all: build test

build:
	$(IDRIS) --build $(IDRIS_PKG)

test:
	$(IDRIS) --testpkg $(IDRIS_PKG)

install:
	$(IDRIS) --install $(IDRIS_PKG)

clean:
	$(IDRIS) --clean $(IDRIS_PKG)
	find . -name '*.ibc' | xargs rm -f
