FLAGS=-std=c11 -Wall -pedantic -D PC_TARGET 
SRC_DIR = ../src
SOURCES = $(wildcard $(SRC_DIR)/*.c)
TEMP = $(SOURCES:$(SRC_DIR)/%=%)
OBJECTS = $(TEMP:.c=.o)

all: ref

%.o: $(SRC_DIR)/%.c $(SRC_DIR)/cfg.h
	gcc -c $(FLAGS) $< -o $@

ref: $(OBJECTS)
	gcc  $(OBJECTS) -lrt -lm -o ref 

clean:
	rm -f *.o
	rm -f *~
	rm -f ref
	rm -f tempdata
	rm -fr __pycache__

.PHONY: clean
