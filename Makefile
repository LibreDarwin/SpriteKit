# Copyright (C) 2026, LibreDarwin
# SPDX-License-Identifier: BSD-3-Clause
# Clean-room reimplementation of Apple's SpriteKit build (IDESpriteKitSupport):
# currently the atlasc texture-atlas compiler (bin: TextureAtlas).
#
# Build layout: every artifact lives under build/; the tool goes to
# build/release/ or build/debug/ per CONFIG.
#
# Portable to both GNU make and BSD make (bmake): no pattern rules, no
# ifeq/ifdef/.if conditionals and no $(if)/$(shell) functions.  Per-config
# flags come from make/<CONFIG>.mk so both make variants behave identically.

CONFIG ?= release
SDK    ?= /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
CC     := /Users/sunneva/xnuports-root/devel/xcode-tools/build/release/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang

-include make/$(CONFIG).mk

PREFIX  ?= /usr/local
DESTDIR ?=

BUILD_DIR := build/$(CONFIG)
OBJDIR    := $(BUILD_DIR)/obj

MFLAGS := $(OPT) -isysroot "$(SDK)" -Wall -Wextra -Wno-deprecated-declarations
OBJCFLAGS := $(MFLAGS) -fobjc-exceptions -fobjc-arc
LFLAGS := -framework Foundation -framework CoreGraphics -framework ImageIO -lz

TOOL      := $(BUILD_DIR)/TextureAtlas
TOOL_SRCS := src/atlasc/TextureAtlas.m src/atlasc/maxrects.c src/atlasc/introsort.c
TOOL_OBJS := $(TOOL_SRCS:src/%=$(OBJDIR)/%)
TOOL_OBJS := $(TOOL_OBJS:.m=.o)
TOOL_OBJS := $(TOOL_OBJS:.c=.o)

all: $(TOOL)

$(TOOL): $(TOOL_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(TOOL_OBJS) $(LFLAGS)

$(OBJDIR)/atlasc/TextureAtlas.o: src/atlasc/TextureAtlas.m
	@mkdir -p $(OBJDIR)/atlasc
	$(CC) $(OBJCFLAGS) -c -o $@ src/atlasc/TextureAtlas.m

$(OBJDIR)/atlasc/maxrects.o: src/atlasc/maxrects.c src/atlasc/maxrects.h
	@mkdir -p $(OBJDIR)/atlasc
	$(CC) $(MFLAGS) -c -o $@ src/atlasc/maxrects.c

$(OBJDIR)/atlasc/introsort.o: src/atlasc/introsort.c src/atlasc/introsort.h
	@mkdir -p $(OBJDIR)/atlasc
	$(CC) $(MFLAGS) -c -o $@ src/atlasc/introsort.c

install: all
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 0755 $(TOOL) $(DESTDIR)$(PREFIX)/bin/TextureAtlas

# Black-box conformance suite: compares build/<CONFIG>/TextureAtlas against the
# committed Apple goldens under tools/conformance/TextureAtlas.  For details and
# --verify-oracle (re-record vs. the real Apple binary) see run_tests.py.
TEST_PY ?= python3

test: all
	$(TEST_PY) tools/conformance/run_tests.py TextureAtlas --build-dir $(BUILD_DIR)

clean:
	rm -rf build

.PHONY: all install clean test