IDRIS=idris
IDRIS_PKG=mongo.ipkg

IDRIS_CFLAGS=-Wignored-qualifiers -Werror

export IDRIS_CFLAGS

all: build test

build:
	$(IDRIS) --build $(IDRIS_PKG)

test:
	$(IDRIS) --testpkg $(IDRIS_PKG)

install:
	$(IDRIS) --install $(IDRIS_PKG)

doc:
	$(IDRIS) --mkdoc $(IDRIS_PKG)

clean:
	$(IDRIS) --clean $(IDRIS_PKG)
	find . -name '*.ibc' | xargs rm -f
