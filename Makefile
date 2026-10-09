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

PARITY_SCENE := $(BUILD_DIR)/sk_scene_parity
PARITY_SCENE_OBJ := $(OBJDIR)/spritekit/sk_scene_parity.o
SCENE_GOLDEN := tools/conformance/SpriteKit/oracle_scene.skeep

PARITY_SCENE_CANONICAL := $(BUILD_DIR)/sk_scene_canonical_parity
PARITY_SCENE_CANONICAL_OBJ := $(OBJDIR)/spritekit/sk_scene_canonical_parity.o
SCENE_CANONICAL_GOLDEN := tools/conformance/SpriteKit/oracle_scene_canonical.skeep

PARITY_CAMERA := $(BUILD_DIR)/sk_camera_parity
PARITY_CAMERA_OBJ := $(OBJDIR)/spritekit/sk_camera_parity.o
CAMERA_GOLDEN := tools/conformance/SpriteKit/oracle_camera.skeep

PARITY_CROP := $(BUILD_DIR)/sk_crop_parity
PARITY_CROP_OBJ := $(OBJDIR)/spritekit/sk_crop_parity.o
CROP_GOLDEN := tools/conformance/SpriteKit/oracle_crop.skeep

PARITY_EMITTER := $(BUILD_DIR)/sk_emitter_parity
PARITY_EMITTER_OBJ := $(OBJDIR)/spritekit/sk_emitter_parity.o
EMITTER_GOLDEN := tools/conformance/SpriteKit/oracle_emitter.skeep

PARITY_TRANSFORM := $(BUILD_DIR)/sk_transform_parity
PARITY_TRANSFORM_OBJ := $(OBJDIR)/spritekit/sk_transform_parity.o
TRANSFORM_GOLDEN := tools/conformance/SpriteKit/oracle_transform.skeep

PARITY_VIDEO := $(BUILD_DIR)/sk_video_parity
PARITY_VIDEO_OBJ := $(OBJDIR)/spritekit/sk_video_parity.o
VIDEO_GOLDEN := tools/conformance/SpriteKit/oracle_video.skeep

PARITY_AUDIO := $(BUILD_DIR)/sk_audio_parity
PARITY_AUDIO_OBJ := $(OBJDIR)/spritekit/sk_audio_parity.o
AUDIO_GOLDEN := tools/conformance/SpriteKit/oracle_audio.skeep

PARITY_REFERENCE := $(BUILD_DIR)/sk_reference_parity
PARITY_REFERENCE_OBJ := $(OBJDIR)/spritekit/sk_reference_parity.o
REFERENCE_GOLDEN := tools/conformance/SpriteKit/oracle_reference.skeep

PARITY_LIGHT := $(BUILD_DIR)/sk_light_parity
PARITY_LIGHT_OBJ := $(OBJDIR)/spritekit/sk_light_parity.o
LIGHT_GOLDEN := tools/conformance/SpriteKit/oracle_light.skeep

PARITY_FIELD := $(BUILD_DIR)/sk_field_parity
PARITY_FIELD_OBJ := $(OBJDIR)/spritekit/sk_field_parity.o
FIELD_GOLDEN := tools/conformance/SpriteKit/oracle_field.skeep

PARITY_WARP_GRID := $(BUILD_DIR)/sk_warp_grid_parity
PARITY_WARP_GRID_OBJ := $(OBJDIR)/spritekit/sk_warp_grid_parity.o
WARP_GRID_GOLDEN := tools/conformance/SpriteKit/oracle_warp_grid.skeep

PARITY_SPRITE_WARP := $(BUILD_DIR)/sk_sprite_warp_parity
PARITY_SPRITE_WARP_OBJ := $(OBJDIR)/spritekit/sk_sprite_warp_parity.o
SPRITE_WARP_GOLDEN := tools/conformance/SpriteKit/oracle_sprite_warp.skeep

PARITY_SHADER := $(BUILD_DIR)/sk_shader_parity
PARITY_SHADER_OBJ := $(OBJDIR)/spritekit/sk_shader_parity.o
SHADER_GOLDEN := tools/conformance/SpriteKit/oracle_shader.skeep

PARITY_EFFECT_SHADER := $(BUILD_DIR)/sk_effect_shader_parity
PARITY_EFFECT_SHADER_OBJ := $(OBJDIR)/spritekit/sk_effect_shader_parity.o
EFFECT_SHADER_GOLDEN := tools/conformance/SpriteKit/oracle_effect_shader.skeep

PARITY_ATTRIBUTE_VALUE := $(BUILD_DIR)/sk_attribute_value_parity
PARITY_ATTRIBUTE_VALUE_OBJ := $(OBJDIR)/spritekit/sk_attribute_value_parity.o
ATTRIBUTE_VALUE_GOLDEN := tools/conformance/SpriteKit/oracle_attribute_value_float.skeep tools/conformance/SpriteKit/oracle_attribute_value_vec4.skeep

PARITY_SPRITE_ATTR := $(BUILD_DIR)/sk_sprite_attr_parity
PARITY_SPRITE_ATTR_OBJ := $(OBJDIR)/spritekit/sk_sprite_attr_parity.o
SPRITE_ATTR_GOLDEN := tools/conformance/SpriteKit/oracle_sprite_attr.skeep

all: $(TOOL) $(PARITY_ACTIONS) $(PARITY_NODE) $(PARITY_SPRITE) $(PARITY_LABEL) $(PARITY_EFFECT) $(PARITY_SHAPE) $(PARITY_SCENE) $(PARITY_SCENE_CANONICAL) $(PARITY_CAMERA) $(PARITY_CROP) $(PARITY_EMITTER) $(PARITY_TRANSFORM) $(PARITY_VIDEO) $(PARITY_AUDIO) $(PARITY_REFERENCE) $(PARITY_LIGHT) $(PARITY_FIELD) $(PARITY_WARP_GRID) $(PARITY_SPRITE_WARP) $(PARITY_SHADER) $(PARITY_EFFECT_SHADER) $(PARITY_ATTRIBUTE_VALUE) $(PARITY_SPRITE_ATTR)

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

$(PARITY_SCENE_OBJ): tools/sk_scene_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_scene_parity.m

$(PARITY_SCENE): $(PARITY_SCENE_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_SCENE_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_SCENE_CANONICAL_OBJ): tools/sk_scene_canonical_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_scene_canonical_parity.m

$(PARITY_SCENE_CANONICAL): $(PARITY_SCENE_CANONICAL_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_SCENE_CANONICAL_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_CAMERA_OBJ): tools/sk_camera_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_camera_parity.m

$(PARITY_CAMERA): $(PARITY_CAMERA_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_CAMERA_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_CROP_OBJ): tools/sk_crop_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_crop_parity.m

$(PARITY_CROP): $(PARITY_CROP_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_CROP_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_EMITTER_OBJ): tools/sk_emitter_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_emitter_parity.m

$(PARITY_EMITTER): $(PARITY_EMITTER_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_EMITTER_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_TRANSFORM_OBJ): tools/sk_transform_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_transform_parity.m

$(PARITY_TRANSFORM): $(PARITY_TRANSFORM_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_TRANSFORM_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_VIDEO_OBJ): tools/sk_video_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_video_parity.m

$(PARITY_VIDEO): $(PARITY_VIDEO_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_VIDEO_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_AUDIO_OBJ): tools/sk_audio_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_audio_parity.m

$(PARITY_AUDIO): $(PARITY_AUDIO_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_AUDIO_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_REFERENCE_OBJ): tools/sk_reference_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_reference_parity.m

$(PARITY_REFERENCE): $(PARITY_REFERENCE_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_REFERENCE_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_LIGHT_OBJ): tools/sk_light_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_light_parity.m

$(PARITY_LIGHT): $(PARITY_LIGHT_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_LIGHT_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_FIELD_OBJ): tools/sk_field_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_field_parity.m

$(PARITY_FIELD): $(PARITY_FIELD_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_FIELD_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_WARP_GRID_OBJ): tools/sk_warp_grid_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_warp_grid_parity.m

$(PARITY_WARP_GRID): $(PARITY_WARP_GRID_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_WARP_GRID_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_SPRITE_WARP_OBJ): tools/sk_sprite_warp_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_sprite_warp_parity.m

$(PARITY_SPRITE_WARP): $(PARITY_SPRITE_WARP_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_SPRITE_WARP_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_SHADER_OBJ): tools/sk_shader_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_shader_parity.m

$(PARITY_SHADER): $(PARITY_SHADER_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_SHADER_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_EFFECT_SHADER_OBJ): tools/sk_effect_shader_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_effect_shader_parity.m

$(PARITY_EFFECT_SHADER): $(PARITY_EFFECT_SHADER_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_EFFECT_SHADER_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_ATTRIBUTE_VALUE_OBJ): tools/sk_attribute_value_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_attribute_value_parity.m

$(PARITY_ATTRIBUTE_VALUE): $(PARITY_ATTRIBUTE_VALUE_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_ATTRIBUTE_VALUE_OBJ) $(SK_OBJS) \
	    -framework Foundation -framework CoreGraphics -framework AppKit

$(PARITY_SPRITE_ATTR_OBJ): tools/sk_sprite_attr_parity.m src/spritekit/SKNode.h
	@mkdir -p $(OBJDIR)/spritekit
	$(CC) $(OBJCFLAGS) $(SK_FLAGS) -c -o $@ tools/sk_sprite_attr_parity.m

$(PARITY_SPRITE_ATTR): $(PARITY_SPRITE_ATTR_OBJ) $(SK_OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(MFLAGS) -o $@ $(PARITY_SPRITE_ATTR_OBJ) $(SK_OBJS) \
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
test-spritekit: $(PARITY_ACTIONS) $(PARITY_NODE) $(PARITY_SPRITE) $(PARITY_LABEL) $(PARITY_EFFECT) $(PARITY_SHAPE) $(PARITY_SCENE) $(PARITY_SCENE_CANONICAL) $(PARITY_CAMERA) $(PARITY_CROP) $(PARITY_EMITTER) $(PARITY_TRANSFORM) $(PARITY_VIDEO) $(PARITY_AUDIO) $(PARITY_REFERENCE) $(PARITY_LIGHT) $(PARITY_FIELD) $(PARITY_WARP_GRID) $(PARITY_SPRITE_WARP) $(PARITY_SHADER) $(PARITY_EFFECT_SHADER) $(PARITY_ATTRIBUTE_VALUE) $(PARITY_SPRITE_ATTR)
	$(PARITY_ACTIONS) $(ACTIONS_GOLDEN)
	$(PARITY_NODE) $(NODE_GOLDEN)
	$(PARITY_SPRITE) $(SPRITE_GOLDEN)
	$(PARITY_LABEL) $(LABEL_GOLDEN)
	$(PARITY_EFFECT) $(EFFECT_GOLDEN)
	$(PARITY_SHAPE) $(SHAPE_GOLDEN)
	$(PARITY_SCENE) $(SCENE_GOLDEN)
	$(PARITY_SCENE_CANONICAL) $(SCENE_CANONICAL_GOLDEN)
	$(PARITY_CAMERA) $(CAMERA_GOLDEN)
	$(PARITY_CROP) $(CROP_GOLDEN)
	$(PARITY_EMITTER) $(EMITTER_GOLDEN)
	$(PARITY_TRANSFORM) $(TRANSFORM_GOLDEN)
	$(PARITY_VIDEO) $(VIDEO_GOLDEN)
	$(PARITY_AUDIO) $(AUDIO_GOLDEN)
	$(PARITY_REFERENCE) $(REFERENCE_GOLDEN)
	$(PARITY_LIGHT) $(LIGHT_GOLDEN)
	$(PARITY_FIELD) $(FIELD_GOLDEN)
	$(PARITY_WARP_GRID) $(WARP_GRID_GOLDEN)
	$(PARITY_SPRITE_WARP) $(SPRITE_WARP_GOLDEN)
	$(PARITY_SHADER) $(SHADER_GOLDEN)
	$(PARITY_EFFECT_SHADER) $(EFFECT_SHADER_GOLDEN)
	$(PARITY_ATTRIBUTE_VALUE) $(ATTRIBUTE_VALUE_GOLDEN)
	$(PARITY_SPRITE_ATTR) $(SPRITE_ATTR_GOLDEN)

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