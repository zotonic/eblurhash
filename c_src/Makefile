# Based on c_src.mk from erlang.mk by Loic Hoguin <essen@ninenines.eu>

CURDIR := $(shell pwd)
BASEDIR := $(abspath $(CURDIR)/..)

C_SRC_DIR = $(CURDIR)
C_SRC_OUTPUT ?= $(CURDIR)/../priv/blurhash

# System type and C compiler/flags.

UNAME_SYS := $(shell uname -s)
ifeq ($(UNAME_SYS), Darwin)
	CC ?= cc
	CFLAGS ?= -O3 -arch x86_64 -Wall -Wmissing-prototypes
	LDFLAGS ?= -arch x86_64 -flat_namespace -undefined suppress
else ifeq ($(UNAME_SYS), FreeBSD)
	CC ?= cc
	CFLAGS ?= -O3 -Wall -Wmissing-prototypes
else ifeq ($(UNAME_SYS), Linux)
	CC ?= gcc
	CFLAGS ?= -O3 -Wall -Wmissing-prototypes
endif
CFLAGS_BLURHASH=-std=c99 -finline-functions $(CFLAGS)
PROGRAM=blurhash

$(C_SRC_OUTPUT): blurhash_stb.c encode.c encode.h stb_image.h
	$(CC) -o $@ $(CPPFLAGS) $(CFLAGS_BLURHASH) blurhash_stb.c encode.c \
		$(LDFLAGS) -lm

.PHONY: clean
clean:
	rm -f *.o
	rm -f $(C_SRC_OUTPUT)
