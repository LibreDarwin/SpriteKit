// Copyright (C) 2026, LibreDarwin
// SPDX-License-Identifier: BSD-3-Clause
//
// Clean-room reimplementation of Apple's SpriteKit SKNode cluster.
//
// Field order and boxing are taken from the dyld-cache disassembly of the
// system SpriteKit.framework (see local/SpriteKit/samples/emit_order_nodes.txt
// and local/SpriteKit/oracle/disasm_all.txt).  Every SKNode field is written
// with -encodeObject:forKey:; there is no [super encodeWithCoder:] call.

#import "SKNode.h"

// Default node version stamp emitted by the current system SpriteKit.
static const uint32_t kSKNodeVersion = 52004001u;

// NSValue geometry helpers: the CG variants exist on iOS, the NS variants on
// macOS.  Both archive to the same NSValue ("NS.pointval"/"NS.rectval").
static NSValue *SKValuePoint(CGPoint p) {
#if TARGET_OS_OSX
    return [NSValue valueWithPoint:NSPointFromCGPoint(p)];
#else
    return [NSValue valueWithCGPoint:p];
#endif
}

static NSValue *SKValueRect(CGRect r) {
#if TARGET_OS_OSX
    return [NSValue valueWithRect:NSRectFromCGRect(r)];
#else
    return [NSValue valueWithCGRect:r];
#endif
}

#pragma mark - SKNode

@interface SKNode ()
@property (nonatomic) uint32_t version;
@property (nonatomic, nullable) id info;
@property (nonatomic, nullable) id constraints;
@property (nonatomic, nullable) id reachConstraints;
@property (nonatomic) BOOL skcPaused;
@property (nonatomic, nullable) id actions;
@property (nonatomic, nullable) id keyedActions;
@property (nonatomic, nullable) id keyedSubSprites;
@property (nonatomic, nullable) id PKPhysicsBody;
@property (nonatomic, nullable) id attributeValues;
@property (nonatomic, copy, nullable) NSString *originalClass;
@end

@implementation SKNode

+ (instancetype)node {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _version = kSKNodeVersion;
        _position = CGPointZero;
        _opacity = 1.0;
        _xRotation = 0.0;
        _yRotation = 0.0;
        _zRotation = 0.0;
        _xScale = 1.0;
        _yScale = 1.0;
        _hidden = NO;
        _paused = NO;
        _skcPaused = NO;
        _zPosition = 0.0;
        _children = [NSMutableArray array];
        _attributeValues = [NSDictionary dictionary];
        _originalClass = NSStringFromClass([self class]);
    }
    return self;
}

- (void)addChild:(SKNode *)node {
    [(NSMutableArray *)_children addObject:node];
}

- (void)removeFromParent {
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:@(_version) forKey:@"_version"];
    [coder encodeObject:SKValuePoint(_position) forKey:@"_position"];
    [coder encodeObject:@(_opacity) forKey:@"_opacity"];
    [coder encodeObject:@(_xRotation) forKey:@"_xRotation"];
    [coder encodeObject:@(_yRotation) forKey:@"_yRotation"];
    [coder encodeObject:@(_zRotation) forKey:@"_zRotation"];
    [coder encodeObject:@(_xScale) forKey:@"_xScale"];
    [coder encodeObject:@(_yScale) forKey:@"_yScale"];
    [coder encodeObject:_name forKey:@"_name"];
    [coder encodeObject:_userData forKey:@"_userData"];
    [coder encodeObject:_info forKey:@"_info"];
    [coder encodeObject:_constraints forKey:@"_constraints"];
    [coder encodeObject:_reachConstraints forKey:@"_reachConstraints"];
    [coder encodeObject:_children forKey:@"_children"];
    [coder encodeObject:@(_hidden) forKey:@"_hidden"];
    [coder encodeObject:@(_paused) forKey:@"_paused"];
    [coder encodeObject:@(_skcPaused) forKey:@"_skcPaused"];
    [coder encodeObject:@(_zPosition) forKey:@"_zPosition"];
    [coder encodeObject:_actions forKey:@"_actions"];
    [coder encodeObject:_keyedActions forKey:@"_keyedActions"];
    [coder encodeObject:_keyedSubSprites forKey:@"_keyedSubSprites"];
    [coder encodeObject:_PKPhysicsBody forKey:@"_PKPhysicsBody"];
    [coder encodeObject:_attributeValues forKey:@"_attributeValues"];
    [coder encodeObject:_originalClass forKey:@"_originalClass"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _version = (uint32_t)[coder decodeIntegerForKey:@"_version"];
        _position = [[coder decodeObjectOfClass:[NSValue class] forKey:@"_position"] CGPointValue];
        _opacity = [coder decodeDoubleForKey:@"_opacity"];
        _xRotation = [coder decodeDoubleForKey:@"_xRotation"];
        _yRotation = [coder decodeDoubleForKey:@"_yRotation"];
        _zRotation = [coder decodeDoubleForKey:@"_zRotation"];
        _xScale = [coder decodeDoubleForKey:@"_xScale"];
        _yScale = [coder decodeDoubleForKey:@"_yScale"];
        _name = [coder decodeObjectOfClass:[NSString class] forKey:@"_name"];
        _userData = [coder decodeObjectForKey:@"_userData"];
        _info = [coder decodeObjectForKey:@"_info"];
        _constraints = [coder decodeObjectForKey:@"_constraints"];
        _reachConstraints = [coder decodeObjectForKey:@"_reachConstraints"];
        _children = [coder decodeObjectForKey:@"_children"];
        _hidden = [coder decodeBoolForKey:@"_hidden"];
        _paused = [coder decodeBoolForKey:@"_paused"];
        _skcPaused = [coder decodeBoolForKey:@"_skcPaused"];
        _zPosition = [coder decodeDoubleForKey:@"_zPosition"];
        _actions = [coder decodeObjectForKey:@"_actions"];
        _keyedActions = [coder decodeObjectForKey:@"_keyedActions"];
        _keyedSubSprites = [coder decodeObjectForKey:@"_keyedSubSprites"];
        _PKPhysicsBody = [coder decodeObjectForKey:@"_PKPhysicsBody"];
        _attributeValues = [coder decodeObjectForKey:@"_attributeValues"];
        _originalClass = [coder decodeObjectForKey:@"_originalClass"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end

#pragma mark - SKEffectNode

@implementation SKEffectNode

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:_filter forKey:@"_filter"];
    [coder encodeObject:_shader forKey:@"_shader"];
    [coder encodeObject:@(_shouldRasterize) forKey:@"_shouldRasterize"];
    [coder encodeObject:@(_shouldEnableEffects) forKey:@"_shouldEnableEffects"];
    [coder encodeObject:@(_shouldCenterFilter) forKey:@"_shouldCenterFilter"];
    [coder encodeObject:@(_blendMode) forKey:@"_blendMode"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _filter = [coder decodeObjectForKey:@"_filter"];
        _shader = [coder decodeObjectForKey:@"_shader"];
        _shouldRasterize = [coder decodeBoolForKey:@"_shouldRasterize"];
        _shouldEnableEffects = [coder decodeBoolForKey:@"_shouldEnableEffects"];
        _shouldCenterFilter = [coder decodeBoolForKey:@"_shouldCenterFilter"];
        _blendMode = [coder decodeIntegerForKey:@"_blendMode"];
    }
    return self;
}

@end

#pragma mark - SKScene

@implementation SKScene

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:_scenePinBody forKey:@"_scenePinBody"];
    [coder encodeObject:@(_backgroundColorR) forKey:@"_backgroundColorR"];
    [coder encodeObject:@(_backgroundColorG) forKey:@"_backgroundColorG"];
    [coder encodeObject:@(_backgroundColorB) forKey:@"_backgroundColorB"];
    [coder encodeObject:@(_backgroundColorA) forKey:@"_backgroundColorA"];
    [coder encodeObject:SKValueRect(_sceneBounds) forKey:@"Scene_bounds"];
    [coder encodeObject:SKValueRect(_visibleRect) forKey:@"_visibleRect"];
    [coder encodeObject:_camera forKey:@"_camera"];
    [coder encodeObject:@(_scaleMode) forKey:@"_scaleMode"];
    [coder encodeObject:_physicsWorld forKey:@"_physicsWorld"];
    [coder encodeObject:SKValuePoint(_anchorPoint) forKey:@"_anchorPoint"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _scenePinBody = [coder decodeObjectForKey:@"_scenePinBody"];
        _backgroundColorR = [coder decodeDoubleForKey:@"_backgroundColorR"];
        _backgroundColorG = [coder decodeDoubleForKey:@"_backgroundColorG"];
        _backgroundColorB = [coder decodeDoubleForKey:@"_backgroundColorB"];
        _backgroundColorA = [coder decodeDoubleForKey:@"_backgroundColorA"];
        _sceneBounds = [(NSValue *)[coder decodeObjectForKey:@"Scene_bounds"] rectValue];
        _visibleRect = [(NSValue *)[coder decodeObjectForKey:@"_visibleRect"] rectValue];
        _camera = [coder decodeObjectForKey:@"_camera"];
        _scaleMode = [coder decodeIntegerForKey:@"_scaleMode"];
        _physicsWorld = [coder decodeObjectForKey:@"_physicsWorld"];
        _anchorPoint = [(NSValue *)[coder decodeObjectForKey:@"_anchorPoint"] pointValue];
    }
    return self;
}

@end

#pragma mark - SKSpriteNode

@implementation SKSpriteNode {
    CGSize _size;
    int32_t _lightingBitMask;
    int32_t _shadowCastBitMask;
    int32_t _shadowedBitMask;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _anchorPoint = CGPointMake(0.5, 0.5);
        _centerRect = CGRectMake(0, 0, 1, 1);
        _blendMode = 0;
        _colorMix = 0.0;
        _baseColorR = _baseColorG = _baseColorB = _baseColorA = 1.0;
        _subdivisionLevels = 2;
    }
    return self;
}

+ (instancetype)spriteNodeWithColor:(id)color size:(CGSize)size {
    SKSpriteNode *n = [[self alloc] init];
    n->_size = size;
    if (color) {
        NSColor *c = [(NSColor *)color colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
        if (c) {
            CGFloat r = 1, g = 1, b = 1, a = 1;
            [c getRed:&r green:&g blue:&b alpha:&a];
            n->_baseColorR = r;
            n->_baseColorG = g;
            n->_baseColorB = b;
            n->_baseColorA = a;
        }
    }
    return n;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    CGRect frame = CGRectMake(self.position.x - _anchorPoint.x * _size.width,
                              self.position.y - _anchorPoint.y * _size.height,
                              _size.width, _size.height);
    [coder encodeObject:SKValueRect(frame) forKey:@"_bounds"];
    [coder encodeObject:@(_blendMode) forKey:@"_blendMode"];
    [coder encodeObject:_shader forKey:@"_shader"];
    [coder encodeObject:_normalTexture forKey:@"_normalTexture"];
    [coder encodeInt32:_lightingBitMask forKey:@"_lightingBitMask"];
    [coder encodeInt32:_shadowCastBitMask forKey:@"_shadowCastBitMask"];
    [coder encodeInt32:_shadowedBitMask forKey:@"_shadowedBitMask"];
    [coder encodeObject:_texture forKey:@"_texture"];
    [coder encodeObject:@(_colorMix) forKey:@"_colorMix"];
    [coder encodeObject:SKValuePoint(_anchorPoint) forKey:@"_anchorPoint"];
    [coder encodeObject:@(_baseColorR) forKey:@"_baseColorR"];
    [coder encodeObject:@(_baseColorG) forKey:@"_baseColorG"];
    [coder encodeObject:@(_baseColorB) forKey:@"_baseColorB"];
    [coder encodeObject:@(_baseColorA) forKey:@"_baseColorA"];
    [coder encodeObject:SKValueRect(_centerRect) forKey:@"_centerRect"];
    [coder encodeObject:_warpGeometry forKey:@"_warpGeometry"];
    [coder encodeInteger:_subdivisionLevels forKey:@"_subdivisionLevels"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _size = [(NSValue *)[coder decodeObjectForKey:@"_bounds"] rectValue].size;
        _blendMode = [coder decodeIntegerForKey:@"_blendMode"];
        _shader = [coder decodeObjectForKey:@"_shader"];
        _normalTexture = [coder decodeObjectForKey:@"_normalTexture"];
        _lightingBitMask = [coder decodeInt32ForKey:@"_lightingBitMask"];
        _shadowCastBitMask = [coder decodeInt32ForKey:@"_shadowCastBitMask"];
        _shadowedBitMask = [coder decodeInt32ForKey:@"_shadowedBitMask"];
        _texture = [coder decodeObjectForKey:@"_texture"];
        _colorMix = [coder decodeDoubleForKey:@"_colorMix"];
        _anchorPoint = [(NSValue *)[coder decodeObjectForKey:@"_anchorPoint"] pointValue];
        _baseColorR = [coder decodeDoubleForKey:@"_baseColorR"];
        _baseColorG = [coder decodeDoubleForKey:@"_baseColorG"];
        _baseColorB = [coder decodeDoubleForKey:@"_baseColorB"];
        _baseColorA = [coder decodeDoubleForKey:@"_baseColorA"];
        _centerRect = [(NSValue *)[coder decodeObjectForKey:@"_centerRect"] rectValue];
        _warpGeometry = [coder decodeObjectForKey:@"_warpGeometry"];
        _subdivisionLevels = [coder decodeIntegerForKey:@"_subdivisionLevels"];
    }
    return self;
}

@end

#pragma mark - SKLabelNode

@implementation SKLabelNode

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:_fontName forKey:@"_fontName"];
    [coder encodeObject:_text forKey:@"_text"];
    [coder encodeObject:_attributedText forKey:@"_attributedText"];
    [coder encodeObject:_textSprites forKey:@"_textSprites"];
    [coder encodeObject:_textSprite forKey:@"_textSprite"];
    [coder encodeDouble:_fontColorR forKey:@"_fontColorR"];
    [coder encodeDouble:_fontColorG forKey:@"_fontColorG"];
    [coder encodeDouble:_fontColorB forKey:@"_fontColorB"];
    [coder encodeDouble:_fontColorA forKey:@"_fontColorA"];
    [coder encodeDouble:_colorR forKey:@"_colorR"];
    [coder encodeDouble:_colorG forKey:@"_colorG"];
    [coder encodeDouble:_colorB forKey:@"_colorB"];
    [coder encodeDouble:_colorA forKey:@"_colorA"];
    [coder encodeDouble:_fontSize forKey:@"_fontSize"];
    [coder encodeDouble:_labelColorBlend forKey:@"_labelColorBlend"];
    [coder encodeInteger:_labelBlendMode forKey:@"_labelBlendMode"];
    [coder encodeDouble:_horizontalAlignmentMode forKey:@"_horizontalAlignmentMode"];
    [coder encodeDouble:_verticalAlignmentMode forKey:@"_verticalAlignmentMode"];
    [coder encodeInteger:_numberOfLines forKey:@"_numberOfLines"];
    [coder encodeFloat:_preferredMaxLayoutWidth forKey:@"_preferredMaxLayoutWidth"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _fontName = [coder decodeObjectForKey:@"_fontName"];
        _text = [coder decodeObjectForKey:@"_text"];
        _attributedText = [coder decodeObjectForKey:@"_attributedText"];
        _textSprites = [coder decodeObjectForKey:@"_textSprites"];
        _textSprite = [coder decodeObjectForKey:@"_textSprite"];
        _fontColorR = [coder decodeDoubleForKey:@"_fontColorR"];
        _fontColorG = [coder decodeDoubleForKey:@"_fontColorG"];
        _fontColorB = [coder decodeDoubleForKey:@"_fontColorB"];
        _fontColorA = [coder decodeDoubleForKey:@"_fontColorA"];
        _colorR = [coder decodeDoubleForKey:@"_colorR"];
        _colorG = [coder decodeDoubleForKey:@"_colorG"];
        _colorB = [coder decodeDoubleForKey:@"_colorB"];
        _colorA = [coder decodeDoubleForKey:@"_colorA"];
        _fontSize = [coder decodeDoubleForKey:@"_fontSize"];
        _labelColorBlend = [coder decodeDoubleForKey:@"_labelColorBlend"];
        _labelBlendMode = [coder decodeIntegerForKey:@"_labelBlendMode"];
        _horizontalAlignmentMode = [coder decodeDoubleForKey:@"_horizontalAlignmentMode"];
        _verticalAlignmentMode = [coder decodeDoubleForKey:@"_verticalAlignmentMode"];
        _numberOfLines = [coder decodeIntegerForKey:@"_numberOfLines"];
        _preferredMaxLayoutWidth = [coder decodeFloatForKey:@"_preferredMaxLayoutWidth"];
    }
    return self;
}

@end