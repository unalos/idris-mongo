CFLAGS=$(shell idris --include) $(shell pkg-config --cflags libmongoc-1.0)

all: idris_bson.o idris_mongo.o

idris_bson.o: idris_bson.c
	$(CC) $(CFLAGS) -c $^

idris_mongo.o: idris_mongo.c
	$(CC) $(CFLAGS) -c $^

clean:
	rm -f *.o
