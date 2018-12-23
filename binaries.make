CFLAGS=$(shell idris --include) $(shell pkg-config --cflags libmongoc-1.0)

all: idris_common.o idris_bson.o idris_mongo.o idris_mongo_write_concern.o idris_mongo_client.o idris_mongo_collection.o

%.o: %.c
	$(CC) $(CFLAGS) -c $^

clean:
	rm -f *.o
