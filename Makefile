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

# Clean-room SpriteKit.framework runtime.  Currently the SKAction class
# cluster; parity binaries drive the library against the Apple goldens in
# tools/conformance/SpriteKit.
SK_OBJS   := $(OBJDIR)/spritekit/SKAction.o $(OBJDIR)/spritekit/SKNode.o
SK_FLAGS  := -I src/spritekit

PARITY_ACTIONS := $(BUILD_DIR)/sk_action_parity
PARITY_ACTIONS_OBJ := $(OBJDIR)/spritekit/sk_action_parity.o
ACTIONS_GOLDEN := tools/conformance/SpriteKit/actions_moveAndScale.skeep

PARITY_NODE := $(BUILD_DIR)/sk_node_parity
PARITY_NODE_OBJ := $(OBJDIR)/spritekit/sk_node_parity.o
NODE_GOLDEN := tools/conformance/SpriteKit/oracle_node.skeep

PARITY_SPRITE := $(BUILD_DIR)/sk_sprite_parity
PARITY_SPRITE_OBJ := $(OBJDIR)/spritekit/sk_sprite_parity.o
SPRITE_GOLDEN := tools/conformance/SpriteKit/oracle_sprite.skeep

PARITY_LABEL := $(BUILD_DIR)/sk_label_parity
PARITY_LABEL_OBJ := $(OBJDIR)/spritekit/sk_label_parity.o
LABEL_GOLDEN := tools/conformance/SpriteKit/oracle_label.skeep

PARITY_EFFECT := $(BUILD_DIR)/sk_effect_parity
PARITY_EFFECT_OBJ := $(OBJDIR)/spritekit/sk_effect_parity.o
EFFECT_GOLDEN := tools/conformance/SpriteKit/oracle_effect.skeep

PARITY_SHAPE := $(BUILD_DIR)/sk_shape_parity
PARITY_SHAPE_OBJ := $(OBJDIR)/spritekit/sk_shape_parity.o
SHAPE_GOLDEN := tools/conformance/SpriteKit/oracle_shape.skeep

all: $(TOOL) $(PARITY_ACTIONS) $(PARITY_NODE) $(PARITY_SPRITE) $(PARITY_LABEL) $(PARITY_EFFECT) $(PARITY_SHAPE)

$(TOOL): $(TOOL_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(TOOL_OBJS) $(LFLAGS)

$(OBJDIR)/spritekit/SKAction.o: src/spritekit/SKAction.m src/spritekit/SKAction.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ src/spritekit/SKAction.m

$(OBJDIR)/spritekit/SKNode.o: src/spritekit/SKNode.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ src/spritekit/SKNode.m

$(PARITY_ACTIONS_OBJ): tools/sk_action_parity.m src/spritekit/SKAction.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_action_parity.m

$(PARITY_ACTIONS): $(PARITY_ACTIONS_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_ACTIONS_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_NODE_OBJ): tools/sk_node_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_node_parity.m

$(PARITY_NODE): $(PARITY_NODE_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_NODE_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_SPRITE_OBJ): tools/sk_sprite_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_sprite_parity.m

$(PARITY_SPRITE): $(PARITY_SPRITE_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_SPRITE_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_LABEL_OBJ): tools/sk_label_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_label_parity.m

$(PARITY_LABEL): $(PARITY_LABEL_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_LABEL_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_EFFECT_OBJ): tools/sk_effect_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_effect_parity.m

$(PARITY_EFFECT): $(PARITY_EFFECT_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_EFFECT_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_SHAPE_OBJ): tools/sk_shape_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_shape_parity.m

$(PARITY_SHAPE): $(PARITY_SHAPE_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_SHAPE_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

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

test: all test-atlasc test-spritekit

test-atlasc: $(TOOL)
	$(TEST_PY) tools/conformance/run_tests.py TextureAtlas --build-dir $(BUILD_DIR)

# Byte-identical archive parity against Apple-recorded SpriteKit goldens.
test-spritekit: $(PARITY_ACTIONS) $(PARITY_NODE) $(PARITY_SPRITE) $(PARITY_LABEL) $(PARITY_EFFECT) $(PARITY_SHAPE)
	$(PARITY_ACTIONS) $(ACTIONS_GOLDEN)
	$(PARITY_NODE) $(NODE_GOLDEN)
	$(PARITY_SPRITE) $(SPRITE_GOLDEN)
	$(PARITY_LABEL) $(LABEL_GOLDEN)
	$(PARITY_EFFECT) $(EFFECT_GOLDEN)
	$(PARITY_SHAPE) $(SHAPE_GOLDEN)

# Re-record the Apple goldens (development aid; links the real SpriteKit).
# Not part of `all` -- run by hand when adding a new node class to the suite.
oracle-spritekit: tools/sk_oracle.m
	@mkdir -p $(BUILD_DIR)
	$(CC) $(OBJCFLAGS) -o $(BUILD_DIR)/sk_oracle tools/sk_oracle.m \
	    -framework Foundation -framework CoreGraphics -framework AppKit -framework SpriteKit
	$(BUILD_DIR)/sk_oracle

clean:
	rm -rf build

.PHONY: all install clean test test-atlasc test-spritekit