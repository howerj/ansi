DEFINES=-DPICKLE_EXTEND
CFLAGS=-std=gnu99 -Wall -Wextra -Ipickle -Lpickle
TARGET=ansi

ifeq ($(OS),Windows_NT)
EXE=.exe
else # Assume Unixen
EXE=
endif

.PHONY: all clean test run

all: ${TARGET}${EXE}

test: all ansi.tcl
	./${TARGET}${EXE} ansi.tcl

run: test

pickle/libpickle.a:
	make -C pickle libpickle.a

${TARGET}${EXE}: pickle/main.o extend.o pickle/libpickle.a
	${CC} ${CFLAGS} $^ ${LDFLAGS} -o $@
	

clean:
	make -C pickle clean
	rm -fv *.o *.a ${TARGET}${EXE}
