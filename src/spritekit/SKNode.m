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

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldEnableEffects = YES;
        _shouldCenterFilter = YES;
    }
    return self;
}

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

#pragma mark - SKCameraNode

@implementation SKCameraNode
@end

#pragma mark - SKCropNode

// Own-field emit order after the 24 SKNode fields (from tools/sk_emit_spy.m):
// _mask (obj), _prefersAlphaMask (bool), _invertMask (bool).

@implementation SKCropNode

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:_mask forKey:@"_mask"];
    [coder encodeBool:_prefersAlphaMask forKey:@"_prefersAlphaMask"];
    [coder encodeBool:_invertMask forKey:@"_invertMask"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _mask = [coder decodeObjectForKey:@"_mask"];
        _prefersAlphaMask = [coder decodeBoolForKey:@"_prefersAlphaMask"];
        _invertMask = [coder decodeBoolForKey:@"_invertMask"];
    }
    return self;
}

@end

#pragma mark - PKPhysicsBody

// PhysicsKit's body, as archived by SKScene.  Field order and encoding flavour
// are taken from the runtime probe in tools/sk_emit_spy.m (encodeInt: /
// encodeInt32: / encodeDouble: / encodeBool: / encodeObject:), not from the
// archive's hash-bucket layout.

@implementation PKPhysicsBody

+ (instancetype)pinBody {
    PKPhysicsBody *body = [[self alloc] init];
    body.dynamic = NO;
    body.categoryBitMask = 0;
    return body;
}

+ (instancetype)bodyWithCircleOfRadius:(double)radius {
    PKPhysicsBody *body = [[self alloc] init];
    body.shapeType = 1;
    body.radius = radius;
    return body;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _shapeType = 1;
        _radius = 1.0;
        _p0 = NSStringFromPoint(NSZeroPoint);
        _edgeRadius = (double)(float)0.009;
        _dynamic = YES;
        _needsContinuousCollsionDetection = NO;
        _allowRotation = YES;
        _pinned = NO;
        _friction = (double)(float)0.2;
        _charge = 0.0;
        _restitution = (double)(float)0.2;
        _density = 1.0;
        _affectedByGravity = YES;
        _categoryBitMask = -1;
        _collisionBitMask = -1;
        _intersectionTestBitMask = 0;
        _fieldBitMask = -1;
        _linearVelocity = NSStringFromPoint(NSZeroPoint);
        _angularVelocity = 0.0;
        _linearDamping = (double)(float)0.1;
        _angularDamping = (double)(float)0.1;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:(int)_shapeType forKey:@"_shapeType"];
    [coder encodeDouble:_radius forKey:@"_radius"];
    [coder encodeObject:_p0 forKey:@"_p0"];
    [coder encodeDouble:_edgeRadius forKey:@"_edgeRadius"];
    [coder encodeBool:_dynamic forKey:@"dynamic"];
    [coder encodeBool:_needsContinuousCollsionDetection forKey:@"needsContinuousCollsionDetection"];
    [coder encodeBool:_allowRotation forKey:@"allowRotation"];
    [coder encodeBool:_pinned forKey:@"pinned"];
    [coder encodeDouble:_friction forKey:@"friction"];
    [coder encodeDouble:_charge forKey:@"charge"];
    [coder encodeDouble:_restitution forKey:@"restitution"];
    [coder encodeDouble:_density forKey:@"density"];
    [coder encodeBool:_affectedByGravity forKey:@"affectedByGravity"];
    [coder encodeInt32:_categoryBitMask forKey:@"categoryBitMask"];
    [coder encodeInt32:_collisionBitMask forKey:@"collisionBitMask"];
    [coder encodeInt32:_intersectionTestBitMask forKey:@"intersectionTestBitMask"];
    [coder encodeInt32:_fieldBitMask forKey:@"fieldBitMask"];
    [coder encodeObject:_linearVelocity forKey:@"linearVelocity"];
    [coder encodeDouble:_angularVelocity forKey:@"angularVelocity"];
    [coder encodeDouble:_linearDamping forKey:@"linearDamping"];
    [coder encodeDouble:_angularDamping forKey:@"angularDamping"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _shapeType = [coder decodeIntegerForKey:@"_shapeType"];
        _radius = [coder decodeDoubleForKey:@"_radius"];
        _p0 = [coder decodeObjectOfClass:[NSString class] forKey:@"_p0"];
        _edgeRadius = [coder decodeDoubleForKey:@"_edgeRadius"];
        _dynamic = [coder decodeBoolForKey:@"dynamic"];
        _needsContinuousCollsionDetection = [coder decodeBoolForKey:@"needsContinuousCollsionDetection"];
        _allowRotation = [coder decodeBoolForKey:@"allowRotation"];
        _pinned = [coder decodeBoolForKey:@"pinned"];
        _friction = [coder decodeDoubleForKey:@"friction"];
        _charge = [coder decodeDoubleForKey:@"charge"];
        _restitution = [coder decodeDoubleForKey:@"restitution"];
        _density = [coder decodeDoubleForKey:@"density"];
        _affectedByGravity = [coder decodeBoolForKey:@"affectedByGravity"];
        _categoryBitMask = (int32_t)[coder decodeInt32ForKey:@"categoryBitMask"];
        _collisionBitMask = (int32_t)[coder decodeInt32ForKey:@"collisionBitMask"];
        _intersectionTestBitMask = (int32_t)[coder decodeInt32ForKey:@"intersectionTestBitMask"];
        _fieldBitMask = (int32_t)[coder decodeInt32ForKey:@"fieldBitMask"];
        _linearVelocity = [coder decodeObjectOfClass:[NSString class] forKey:@"linearVelocity"];
        _angularVelocity = [coder decodeDoubleForKey:@"angularVelocity"];
        _linearDamping = [coder decodeDoubleForKey:@"linearDamping"];
        _angularDamping = [coder decodeDoubleForKey:@"angularDamping"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end

#pragma mark - PKPhysicsWorld

@implementation PKPhysicsWorld

+ (instancetype)world {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _joints = [NSMutableArray array];
        _bodies = [NSMutableArray array];
        _gravity = [NSString stringWithFormat:@"{%g, %g}", 0.0, -9.8];
        _speedMultiplier = 1.0;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_joints forKey:@"_joints"];
    [coder encodeObject:_bodies forKey:@"_bodies"];
    [coder encodeObject:_gravity forKey:@"gravity"];
    [coder encodeDouble:_speedMultiplier forKey:@"speedMultiplier"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _joints = [coder decodeObjectForKey:@"_joints"];
        _bodies = [coder decodeObjectForKey:@"_bodies"];
        _gravity = [coder decodeObjectOfClass:[NSString class] forKey:@"gravity"];
        _speedMultiplier = [coder decodeDoubleForKey:@"speedMultiplier"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end

#pragma mark - SKScene

@implementation SKScene

+ (instancetype)sceneWithSize:(CGSize)size {
    return [[self alloc] initWithSize:size];
}

- (instancetype)init {
    return [self initWithSize:CGSizeZero];
}

- (instancetype)initWithSize:(CGSize)size {
    // SKEffectNode's initializer defaults _shouldEnableEffects to YES; scenes
    // never rasterize unless asked to, so it is turned back off here.
    self = [super init];
    if (self) {
        self.shouldEnableEffects = NO;
        _backgroundColorR = (double)(float)0.15;
        _backgroundColorG = (double)(float)0.15;
        _backgroundColorB = (double)(float)0.15;
        _backgroundColorA = 1.0;
        _anchorPoint = CGPointZero;
        _sceneBounds = (CGRect){CGPointZero, size};
        _visibleRect = CGRectMake(-_anchorPoint.x * size.width,
                                  -_anchorPoint.y * size.height,
                                  size.width, size.height);
        _scaleMode = 0;
        _scenePinBody = [PKPhysicsBody pinBody];
        _physicsWorld = [PKPhysicsWorld world];
        [_physicsWorld.bodies addObject:_scenePinBody];
    }
    return self;
}

- (CGSize)size {
    return _sceneBounds.size;
}

- (void)setSize:(CGSize)size {
    _sceneBounds = (CGRect){CGPointZero, size};
    _visibleRect = CGRectMake(-_anchorPoint.x * size.width,
                              -_anchorPoint.y * size.height,
                              size.width, size.height);
}

// The public SKScene.backgroundColor is a color; the archive only carries its
// decomposed components, so the setter flattens to sRGB doubles.
- (id)backgroundColor {
    return [NSColor colorWithRed:_backgroundColorR
                            green:_backgroundColorG
                             blue:_backgroundColorB
                            alpha:_backgroundColorA];
}

- (void)setBackgroundColor:(id)color {
    if (!color) {
        return;
    }
    NSColor *c = [(NSColor *)color colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    if (!c) {
        return;
    }
    CGFloat r = 0, g = 0, b = 0, a = 1;
    [c getRed:&r green:&g blue:&b alpha:&a];
    _backgroundColorR = r;
    _backgroundColorG = g;
    _backgroundColorB = b;
    _backgroundColorA = a;
}

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

- (instancetype)init {
    self = [super init];
    if (self) {
        _fontName = @"HelveticaNeue-UltraLight";
        _fontSize = 32.0;
        _fontColorR = _fontColorG = _fontColorB = _fontColorA = 1.0;
        _colorR = _colorG = _colorB = _colorA = 1.0;
        _numberOfLines = 1;
        _preferredMaxLayoutWidth = 0.0;
        _textSprites = [NSArray array];
    }
    return self;
}

+ (instancetype)labelNodeWithText:(NSString *)text {
    SKLabelNode *n = [[self alloc] init];
    n.text = text;
    return n;
}

+ (instancetype)labelNodeWithFontNamed:(NSString *)fontName {
    SKLabelNode *n = [[self alloc] init];
    n.fontName = fontName;
    return n;
}

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
    [coder encodeObject:@(_horizontalAlignmentMode) forKey:@"_horizontalAlignmentMode"];
    [coder encodeObject:@(_verticalAlignmentMode) forKey:@"_verticalAlignmentMode"];
    [coder encodeObject:@(_numberOfLines) forKey:@"_numberOfLines"];
    [coder encodeObject:@(_preferredMaxLayoutWidth) forKey:@"_preferredMaxLayoutWidth"];
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
        _horizontalAlignmentMode = [[coder decodeObjectForKey:@"_horizontalAlignmentMode"] doubleValue];
        _verticalAlignmentMode = [[coder decodeObjectForKey:@"_verticalAlignmentMode"] doubleValue];
        _numberOfLines = [[coder decodeObjectForKey:@"_numberOfLines"] integerValue];
        _preferredMaxLayoutWidth = [[coder decodeObjectForKey:@"_preferredMaxLayoutWidth"] floatValue];
    }
    return self;
}

@end

#pragma mark - SKShapeNode

// Apple does not archive a raw CGPath for a shape's geometry.  It serializes
// the private "SKCGSPath" form: an NSMutableArray of segments, each an
// NSMutableDictionary {"type": <CGPathElementType>, "points": [NSValue...]}.
// type 0 = moveToPoint (1 point), 1 = addLineToPoint (1), 2 =
// addQuadCurveToPoint (2), 3 = addCurveToPoint/cubic (3: c1, c2, end), 4 =
// closeSubpath (0).  Byte parity requires reproducing this exact object graph
// (including shared points) -- see local/SpriteKit/SpriteKit.md.
static NSMutableDictionary *SKPathSegment(int type, NSArray *points) {
    NSMutableDictionary *seg = [NSMutableDictionary dictionary];
    seg[@"type"] = @(type);
    seg[@"points"] = [NSMutableArray arrayWithArray:points];
    return seg;
}

static NSMutableArray *SKCirclePath(CGFloat radius) {
    // Apple's circle->Bezier control constant is the truncated literal
    // 0.5522847498 (not the full-precision (4/3)(sqrt2-1)); that is what makes
    // the archived control points print as "5.522847498" for radius 10.
    double r = radius;
    double k = 0.5522847498 * r;
    NSMutableArray *path = [NSMutableArray array];
    [path addObject:SKPathSegment(0, @[ SKValuePoint(CGPointMake(r, 0)) ])];
    [path addObject:SKPathSegment(3, @[ SKValuePoint(CGPointMake(r, k)),
                                       SKValuePoint(CGPointMake(k, r)),
                                       SKValuePoint(CGPointMake(0, r)) ])];
    [path addObject:SKPathSegment(3, @[ SKValuePoint(CGPointMake(-k, r)),
                                       SKValuePoint(CGPointMake(-r, k)),
                                       SKValuePoint(CGPointMake(-r, 0)) ])];
    [path addObject:SKPathSegment(3, @[ SKValuePoint(CGPointMake(-r, -k)),
                                       SKValuePoint(CGPointMake(-k, -r)),
                                       SKValuePoint(CGPointMake(0, -r)) ])];
    [path addObject:SKPathSegment(3, @[ SKValuePoint(CGPointMake(k, -r)),
                                       SKValuePoint(CGPointMake(r, -k)),
                                       SKValuePoint(CGPointMake(r, 0)) ])];
    [path addObject:SKPathSegment(4, @[])];
    return path;
}

@implementation SKShapeNode

- (instancetype)init {
    self = [super init];
    if (self) {
        _lineWidth = 1.0;
        _smoothWidth = 0.0;
        _smoothStroke = YES;
        _strokeColorR = _strokeColorG = _strokeColorB = _strokeColorA = 1.0;
        _fillColorR = _fillColorG = _fillColorB = _fillColorA = 0.0;
        _lineJoin = 2;
        _lineCap = 0;
        _miterLimit = 0.5;
    }
    return self;
}

+ (instancetype)shapeNodeWithCircleOfRadius:(CGFloat)radius {
    SKShapeNode *n = [[self alloc] init];
    n->_cgPath = SKCirclePath(radius);
    return n;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:_cgPath forKey:@"_cgPath"];
    [coder encodeObject:@(_lineWidth) forKey:@"_lineWidth"];
    [coder encodeObject:@(_smoothWidth) forKey:@"_smoothWidth"];
    [coder encodeObject:@(_smoothStroke) forKey:@"_smoothStroke"];
    [coder encodeObject:@(_fillColorR) forKey:@"_fillColorR"];
    [coder encodeObject:@(_fillColorG) forKey:@"_fillColorG"];
    [coder encodeObject:@(_fillColorB) forKey:@"_fillColorB"];
    [coder encodeObject:@(_fillColorA) forKey:@"_fillColorA"];
    [coder encodeObject:@(_strokeColorR) forKey:@"_strokeColorR"];
    [coder encodeObject:@(_strokeColorG) forKey:@"_strokeColorG"];
    [coder encodeObject:@(_strokeColorB) forKey:@"_strokeColorB"];
    [coder encodeObject:@(_strokeColorA) forKey:@"_strokeColorA"];
    [coder encodeInteger:_lineJoin forKey:@"_lineJoin"];
    [coder encodeInteger:_lineCap forKey:@"_lineCap"];
    [coder encodeDouble:_miterLimit forKey:@"_miterLimit"];
    [coder encodeObject:_strokeTexture forKey:@"_strokeTexture"];
    [coder encodeObject:_fillTexture forKey:@"_fillTexture"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _cgPath = [coder decodeObjectForKey:@"_cgPath"];
        _lineWidth = [coder decodeDoubleForKey:@"_lineWidth"];
        _smoothWidth = [coder decodeDoubleForKey:@"_smoothWidth"];
        _smoothStroke = [coder decodeBoolForKey:@"_smoothStroke"];
        _strokeColorR = [coder decodeDoubleForKey:@"_strokeColorR"];
        _strokeColorG = [coder decodeDoubleForKey:@"_strokeColorG"];
        _strokeColorB = [coder decodeDoubleForKey:@"_strokeColorB"];
        _strokeColorA = [coder decodeDoubleForKey:@"_strokeColorA"];
        _fillColorR = [coder decodeDoubleForKey:@"_fillColorR"];
        _fillColorG = [coder decodeDoubleForKey:@"_fillColorG"];
        _fillColorB = [coder decodeDoubleForKey:@"_fillColorB"];
        _fillColorA = [coder decodeDoubleForKey:@"_fillColorA"];
        _lineJoin = [coder decodeIntegerForKey:@"_lineJoin"];
        _lineCap = [coder decodeIntegerForKey:@"_lineCap"];
        _miterLimit = [coder decodeDoubleForKey:@"_miterLimit"];
        _strokeTexture = [coder decodeObjectForKey:@"_strokeTexture"];
        _fillTexture = [coder decodeObjectForKey:@"_fillTexture"];
    }
    return self;
}

@end

#pragma mark - SKEmitterNode

// Own-field emit order after the 24 SKNode fields (from tools/sk_emit_spy.m).
// Doubles dominate; the geometry fields are tagged-pointer strings, and only
// _particleBlendMode (encodeInteger) and _fieldBitMask (encodeInt32) are
// primitives.  Defaults are read from oracle_emitter.skeep.

@implementation SKEmitterNode

- (instancetype)init {
    self = [super init];
    if (self) {
        _startColorR = 1.0;
        _startColorG = 1.0;
        _startColorB = 1.0;
        _startColorA = 0.0;
        _startOpacity = 1.0;
        _startScale = 1.0;
        _emissionAngle = (double)(float)M_PI_2;
        NSString *zero2 = [NSString stringWithFormat:@"{%g, %g}", 0.0, 0.0];
        _startPosition = zero2;
        _startPositionVariance = zero2;
        _startSize = zero2;
        _acceleration = zero2;
        _numParticlesToEmit = [NSNumber numberWithUnsignedInteger:0];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:_particleAction forKey:@"_particleAction"];
    [coder encodeDouble:_startColorMix forKey:@"_startColorMix"];
    [coder encodeDouble:_startColorBlendVariance forKey:@"_startColorBlendVariance"];
    [coder encodeDouble:_startColorR forKey:@"_startColorR"];
    [coder encodeDouble:_startColorG forKey:@"_startColorG"];
    [coder encodeDouble:_startColorB forKey:@"_startColorB"];
    [coder encodeDouble:_startColorA forKey:@"_startColorA"];
    [coder encodeDouble:_startColorVarianceR forKey:@"_startColorVarianceR"];
    [coder encodeDouble:_startColorVarianceG forKey:@"_startColorVarianceG"];
    [coder encodeDouble:_startColorVarianceB forKey:@"_startColorVarianceB"];
    [coder encodeDouble:_startColorVarianceA forKey:@"_startColorVarianceA"];
    [coder encodeDouble:_birthrate forKey:@"_birthrate"];
    [coder encodeObject:_particleTexture forKey:@"_particleTexture"];
    [coder encodeObject:_startPosition forKey:@"_startPosition"];
    [coder encodeObject:_startPositionVariance forKey:@"_startPositionVariance"];
    [coder encodeDouble:_startZPosition forKey:@"_startZPosition"];
    [coder encodeDouble:_startZPositionVariance forKey:@"_startZPositionVariance"];
    [coder encodeDouble:_lifetime forKey:@"_lifetime"];
    [coder encodeDouble:_lifetimeVariance forKey:@"_lifetimeVariance"];
    [coder encodeDouble:_startOpacity forKey:@"_startOpacity"];
    [coder encodeDouble:_startOpacityVariance forKey:@"_startOpacityVariance"];
    [coder encodeInteger:_particleBlendMode forKey:@"_particleBlendMode"];
    [coder encodeDouble:_startRotation forKey:@"_startRotation"];
    [coder encodeDouble:_startRotationVariance forKey:@"_startRotationVariance"];
    [coder encodeObject:_startSize forKey:@"_startSize"];
    [coder encodeDouble:_startScale forKey:@"_startScale"];
    [coder encodeDouble:_startScaleVariance forKey:@"_startScaleVariance"];
    [coder encodeObject:_acceleration forKey:@"_acceleration"];
    [coder encodeDouble:_colorSpeedR forKey:@"_colorSpeedR"];
    [coder encodeDouble:_colorSpeedG forKey:@"_colorSpeedG"];
    [coder encodeDouble:_colorSpeedB forKey:@"_colorSpeedB"];
    [coder encodeDouble:_colorSpeedA forKey:@"_colorSpeedA"];
    [coder encodeDouble:_colorBlendSpeed forKey:@"_colorBlendSpeed"];
    [coder encodeDouble:_rotationSpeed forKey:@"_rotationSpeed"];
    [coder encodeDouble:_scaleSpeed forKey:@"_scaleSpeed"];
    [coder encodeDouble:_opacitySpeed forKey:@"_opacitySpeed"];
    [coder encodeDouble:_startSpeed forKey:@"_startSpeed"];
    [coder encodeDouble:_startSpeedVariance forKey:@"_startSpeedVariance"];
    [coder encodeDouble:_emissionAngle forKey:@"_emissionAngle"];
    [coder encodeDouble:_emissionAngleVariance forKey:@"_emissionAngleVariance"];
    [coder encodeObject:_target forKey:@"_target"];
    [coder encodeObject:_numParticlesToEmit forKey:@"_numParticlesToEmit"];
    [coder encodeDouble:_zPositionSpeed forKey:@"_zPositionSpeed"];
    [coder encodeDouble:_emissionDistance forKey:@"_emissionDistance"];
    [coder encodeDouble:_emissionDistanceRange forKey:@"_emissionDistanceRange"];
    [coder encodeInt32:_fieldBitMask forKey:@"_fieldBitMask"];
    [coder encodeObject:_particleAlphaSequence forKey:@"_particleAlphaSequence"];
    [coder encodeObject:_particleColorSequence forKey:@"_particleColorSequence"];
    [coder encodeObject:_particleColorBlendFactorSequence forKey:@"_particleColorBlendFactorSequence"];
    [coder encodeObject:_particleScaleSequence forKey:@"_particleScaleSequence"];
    [coder encodeObject:_particleRotationSequence forKey:@"_particleRotationSequence"];
    [coder encodeObject:_fieldInfluenceSequence forKey:@"_fieldInfluenceSequence"];
    [coder encodeObject:_particleSpeedSequence forKey:@"_particleSpeedSequence"];
    [coder encodeObject:_shader forKey:@"_shader"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _particleAction = [coder decodeObjectForKey:@"_particleAction"];
        _startColorMix = [coder decodeDoubleForKey:@"_startColorMix"];
        _startColorBlendVariance = [coder decodeDoubleForKey:@"_startColorBlendVariance"];
        _startColorR = [coder decodeDoubleForKey:@"_startColorR"];
        _startColorG = [coder decodeDoubleForKey:@"_startColorG"];
        _startColorB = [coder decodeDoubleForKey:@"_startColorB"];
        _startColorA = [coder decodeDoubleForKey:@"_startColorA"];
        _startColorVarianceR = [coder decodeDoubleForKey:@"_startColorVarianceR"];
        _startColorVarianceG = [coder decodeDoubleForKey:@"_startColorVarianceG"];
        _startColorVarianceB = [coder decodeDoubleForKey:@"_startColorVarianceB"];
        _startColorVarianceA = [coder decodeDoubleForKey:@"_startColorVarianceA"];
        _birthrate = [coder decodeDoubleForKey:@"_birthrate"];
        _particleTexture = [coder decodeObjectForKey:@"_particleTexture"];
        _startPosition = [coder decodeObjectForKey:@"_startPosition"];
        _startPositionVariance = [coder decodeObjectForKey:@"_startPositionVariance"];
        _startZPosition = [coder decodeDoubleForKey:@"_startZPosition"];
        _startZPositionVariance = [coder decodeDoubleForKey:@"_startZPositionVariance"];
        _lifetime = [coder decodeDoubleForKey:@"_lifetime"];
        _lifetimeVariance = [coder decodeDoubleForKey:@"_lifetimeVariance"];
        _startOpacity = [coder decodeDoubleForKey:@"_startOpacity"];
        _startOpacityVariance = [coder decodeDoubleForKey:@"_startOpacityVariance"];
        _particleBlendMode = [coder decodeIntegerForKey:@"_particleBlendMode"];
        _startRotation = [coder decodeDoubleForKey:@"_startRotation"];
        _startRotationVariance = [coder decodeDoubleForKey:@"_startRotationVariance"];
        _startSize = [coder decodeObjectForKey:@"_startSize"];
        _startScale = [coder decodeDoubleForKey:@"_startScale"];
        _startScaleVariance = [coder decodeDoubleForKey:@"_startScaleVariance"];
        _acceleration = [coder decodeObjectForKey:@"_acceleration"];
        _colorSpeedR = [coder decodeDoubleForKey:@"_colorSpeedR"];
        _colorSpeedG = [coder decodeDoubleForKey:@"_colorSpeedG"];
        _colorSpeedB = [coder decodeDoubleForKey:@"_colorSpeedB"];
        _colorSpeedA = [coder decodeDoubleForKey:@"_colorSpeedA"];
        _colorBlendSpeed = [coder decodeDoubleForKey:@"_colorBlendSpeed"];
        _rotationSpeed = [coder decodeDoubleForKey:@"_rotationSpeed"];
        _scaleSpeed = [coder decodeDoubleForKey:@"_scaleSpeed"];
        _opacitySpeed = [coder decodeDoubleForKey:@"_opacitySpeed"];
        _startSpeed = [coder decodeDoubleForKey:@"_startSpeed"];
        _startSpeedVariance = [coder decodeDoubleForKey:@"_startSpeedVariance"];
        _emissionAngle = [coder decodeDoubleForKey:@"_emissionAngle"];
        _emissionAngleVariance = [coder decodeDoubleForKey:@"_emissionAngleVariance"];
        _target = [coder decodeObjectForKey:@"_target"];
        _numParticlesToEmit = [coder decodeObjectForKey:@"_numParticlesToEmit"];
        _zPositionSpeed = [coder decodeDoubleForKey:@"_zPositionSpeed"];
        _emissionDistance = [coder decodeDoubleForKey:@"_emissionDistance"];
        _emissionDistanceRange = [coder decodeDoubleForKey:@"_emissionDistanceRange"];
        _fieldBitMask = [coder decodeInt32ForKey:@"_fieldBitMask"];
        _particleAlphaSequence = [coder decodeObjectForKey:@"_particleAlphaSequence"];
        _particleColorSequence = [coder decodeObjectForKey:@"_particleColorSequence"];
        _particleColorBlendFactorSequence = [coder decodeObjectForKey:@"_particleColorBlendFactorSequence"];
        _particleScaleSequence = [coder decodeObjectForKey:@"_particleScaleSequence"];
        _particleRotationSequence = [coder decodeObjectForKey:@"_particleRotationSequence"];
        _fieldInfluenceSequence = [coder decodeObjectForKey:@"_fieldInfluenceSequence"];
        _particleSpeedSequence = [coder decodeObjectForKey:@"_particleSpeedSequence"];
        _shader = [coder decodeObjectForKey:@"_shader"];
    }
    return self;
}

@end

#pragma mark - SKTransformNode

@implementation SKTransformNode
@end

#pragma mark - SKVideoNode

@implementation SKVideoNode

+ (instancetype)videoNodeWithFileNamed:(NSString *)name {
    SKVideoNode *n = [[self alloc] init];
    n->_videoFileName = [name copy];
    return n;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:_videoFileName forKey:@"_videoFileName"];
    [coder encodeObject:_videoFileURL forKey:@"_videoFileURL"];
    [coder encodeObject:SKValueRect(_bounds) forKey:@"_bounds"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _videoFileName = [coder decodeObjectForKey:@"_videoFileName"];
        _videoFileURL = [coder decodeObjectForKey:@"_videoFileURL"];
        _bounds = [((NSValue *)[coder decodeObjectForKey:@"_bounds"]) rectValue];
    }
    return self;
}

@end

#pragma mark - SKAudioNode

@implementation SKAudioNode

- (instancetype)init {
    self = [super init];
    if (self) {
        _autoplayLooped = YES;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeBool:_autoplayLooped forKey:@"_autoplayLooped"];
    [coder encodeObject:_audioName forKey:@"_audioName"];
    [coder encodeObject:_audioURL forKey:@"_audioURL"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _autoplayLooped = [coder decodeBoolForKey:@"_autoplayLooped"];
        _audioName = [coder decodeObjectForKey:@"_audioName"];
        _audioURL = [coder decodeObjectForKey:@"_audioURL"];
    }
    return self;
}

@end

#pragma mark - SKReferenceNode

@implementation SKReferenceNode

- (instancetype)init {
    self = [super init];
    if (self) {
        _referenceFileName = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:_referenceURL forKey:@"_referenceURL"];
    [coder encodeObject:_referenceFileName forKey:@"_referenceFileName"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _referenceURL = [coder decodeObjectForKey:@"_referenceURL"];
        _referenceFileName = [coder decodeObjectForKey:@"_referenceFileName"];
    }
    return self;
}

@end

#pragma mark - SKLightNode

// Own-field emit order after the 24 SKNode fields (from tools/sk_emit_spy.m):
// enabled (bool), lightDecay (double), lightColor RGBA, ambientColor RGBA,
// shadowColor RGBA (all doubles), lightCategoryBitMask (encodeInt32).  Keys for
// the color components are "<name>.<component>Component".

@implementation SKLightNode

- (instancetype)init {
    self = [super init];
    if (self) {
        _enabled = YES;
        _lightDecay = 1.0;
        _lightColorR = _lightColorG = _lightColorB = _lightColorA = 1.0;
        _ambientColorR = _ambientColorG = _ambientColorB = 0.0;
        _ambientColorA = 1.0;
        _shadowColorR = _shadowColorG = _shadowColorB = 0.0;
        _shadowColorA = 0.5;
        _lightCategoryBitMask = 1;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeBool:_enabled forKey:@"enabled"];
    [coder encodeDouble:_lightDecay forKey:@"lightDecay"];
    [coder encodeDouble:_lightColorR forKey:@"lightColor.redComponent"];
    [coder encodeDouble:_lightColorG forKey:@"lightColor.greenComponent"];
    [coder encodeDouble:_lightColorB forKey:@"lightColor.blueComponent"];
    [coder encodeDouble:_lightColorA forKey:@"lightColor.alphaComponent"];
    [coder encodeDouble:_ambientColorR forKey:@"ambientColor.redComponent"];
    [coder encodeDouble:_ambientColorG forKey:@"ambientColor.greenComponent"];
    [coder encodeDouble:_ambientColorB forKey:@"ambientColor.blueComponent"];
    [coder encodeDouble:_ambientColorA forKey:@"ambientColor.alphaComponent"];
    [coder encodeDouble:_shadowColorR forKey:@"shadowColor.redComponent"];
    [coder encodeDouble:_shadowColorG forKey:@"shadowColor.greenComponent"];
    [coder encodeDouble:_shadowColorB forKey:@"shadowColor.blueComponent"];
    [coder encodeDouble:_shadowColorA forKey:@"shadowColor.alphaComponent"];
    [coder encodeInt32:_lightCategoryBitMask forKey:@"lightCategoryBitMask"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _enabled = [coder decodeBoolForKey:@"enabled"];
        _lightDecay = [coder decodeDoubleForKey:@"lightDecay"];
        _lightColorR = [coder decodeDoubleForKey:@"lightColor.redComponent"];
        _lightColorG = [coder decodeDoubleForKey:@"lightColor.greenComponent"];
        _lightColorB = [coder decodeDoubleForKey:@"lightColor.blueComponent"];
        _lightColorA = [coder decodeDoubleForKey:@"lightColor.alphaComponent"];
        _ambientColorR = [coder decodeDoubleForKey:@"ambientColor.redComponent"];
        _ambientColorG = [coder decodeDoubleForKey:@"ambientColor.greenComponent"];
        _ambientColorB = [coder decodeDoubleForKey:@"ambientColor.blueComponent"];
        _ambientColorA = [coder decodeDoubleForKey:@"ambientColor.alphaComponent"];
        _shadowColorR = [coder decodeDoubleForKey:@"shadowColor.redComponent"];
        _shadowColorG = [coder decodeDoubleForKey:@"shadowColor.greenComponent"];
        _shadowColorB = [coder decodeDoubleForKey:@"shadowColor.blueComponent"];
        _shadowColorA = [coder decodeDoubleForKey:@"shadowColor.alphaComponent"];
        _lightCategoryBitMask = [coder decodeInt32ForKey:@"lightCategoryBitMask"];
    }
    return self;
}

@end

#pragma mark - SKFieldNode

// Own-field emit order after the 24 SKNode fields (from tools/sk_emit_spy.m):
// _strength, _falloff, _minimumRadius (floats), _active, _exclusive (bools),
// _categoryBitMask (encodeInt32), _direction (a 12-byte NSMutableData of three
// zero floats), _smoothness, _animationSpeed (floats).

@implementation SKFieldNode {
    NSMutableData *_direction;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _strength = 0.0f;
        _falloff = 0.0f;
        _minimumRadius = 3.0517578125e-05f;  // 2^-15, Apple's default
        _active = NO;
        _exclusive = NO;
        _categoryBitMask = 0;
        _direction = [NSMutableData dataWithLength:12];
        _smoothness = 0.0f;
        _animationSpeed = 0.0f;
    }
    return self;
}

- (void)setDirectionX:(float)x y:(float)y z:(float)z {
    float v[3] = { x, y, z };
    [_direction replaceBytesInRange:NSMakeRange(0, 12) withBytes:v];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeFloat:_strength forKey:@"_strength"];
    [coder encodeFloat:_falloff forKey:@"_falloff"];
    [coder encodeFloat:_minimumRadius forKey:@"_minimumRadius"];
    [coder encodeBool:_active forKey:@"_active"];
    [coder encodeBool:_exclusive forKey:@"_exclusive"];
    [coder encodeInt32:_categoryBitMask forKey:@"_categoryBitMask"];
    [coder encodeObject:_direction forKey:@"_direction"];
    [coder encodeFloat:_smoothness forKey:@"_smoothness"];
    [coder encodeFloat:_animationSpeed forKey:@"_animationSpeed"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _strength = [coder decodeFloatForKey:@"_strength"];
        _falloff = [coder decodeFloatForKey:@"_falloff"];
        _minimumRadius = [coder decodeFloatForKey:@"_minimumRadius"];
        _active = [coder decodeBoolForKey:@"_active"];
        _exclusive = [coder decodeBoolForKey:@"_exclusive"];
        _categoryBitMask = [coder decodeInt32ForKey:@"_categoryBitMask"];
        _direction = [coder decodeObjectForKey:@"_direction"];
        _smoothness = [coder decodeFloatForKey:@"_smoothness"];
        _animationSpeed = [coder decodeFloatForKey:@"_animationSpeed"];
    }
    return self;
}

@end