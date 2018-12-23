CFLAGS=$(shell idris --include) $(shell pkg-config --cflags libmongoc-1.0)

SOURCES = $(wildcard *.c)
OBJECTS = $(patsubst %.c, %.o, $(SOURCES))

all: $(OBJECTS)

%.o: %.c
	$(CC) $(CFLAGS) -c $^

clean:
	rm -f *.o
