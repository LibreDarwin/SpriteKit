/*
 * Copyright (C) 2026, LibreDarwin
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Clean-room reimplementation of the SpriteKit SKAction class cluster.
 *
 * Each concrete subclass reimplements NSCoding in the exact field order and
 * NSNumber boxing Apple's implementation uses.  The orders below are recovered
 * from the dyld-cache disassembly (see local/SpriteKit/tools/dump_emit_order.py
 * and samples/emit_order.txt) -- NOT from the archive's hash-bucket layout.
 * Byte parity with Apple's archives depends on all three: the emit order, the
 * value boxing, and the [super encodeWithCoder:] call coming first.
 */

#import "SKAction.h"

#pragma mark - Internal construction hooks (private to this file)

@interface SKMove (Internal)
+ (instancetype)actionMovingTo:(CGPoint)position duration:(NSTimeInterval)sec;
@end
@interface SKScale (Internal)
+ (instancetype)actionScalingTo:(CGFloat)scale duration:(NSTimeInterval)sec;
@end
@interface SKSequence (Internal)
+ (instancetype)actionWithActions:(NSArray<SKAction *> *)actions;
@end
@interface SKGroup (Internal)
+ (instancetype)actionWithActions:(NSArray<SKAction *> *)actions;
@end

@implementation SKAction

+ (instancetype)action {
    return [[self alloc] init];
}

#pragma mark - Factories (the subset needed to rebuild the golden archives)

+ (instancetype)moveTo:(CGPoint)position duration:(NSTimeInterval)sec {
    return [SKMove actionMovingTo:position duration:sec];
}

+ (instancetype)scaleTo:(CGFloat)scale duration:(NSTimeInterval)sec {
    return [SKScale actionScalingTo:scale duration:sec];
}

+ (instancetype)sequence:(NSArray<SKAction *> *)actions {
    return [SKSequence actionWithActions:actions];
}

+ (instancetype)group:(NSArray<SKAction *> *)actions {
    return [SKGroup actionWithActions:actions];
}

#pragma mark - NSCoding

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:@(_duration) forKey:@"_duration"];
    [coder encodeObject:@(_timingMode) forKey:@"_timingMode"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _duration = [coder decodeDoubleForKey:@"_duration"];
        _timingMode = [coder decodeIntegerForKey:@"_timingMode"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end

#pragma mark - SKMove

@implementation SKMove {
    CGFloat _lastRatio;
    CGPoint _posTarget;
    CGPoint _posTargetReversed;
    CGPoint _posStart;
    BOOL _isReversed;
    BOOL _isRelative;
    BOOL _useX;
    BOOL _useY;
}

- (instancetype)init {
    if ((self = [super init])) {
        _useX = YES;
        _useY = YES;
    }
    return self;
}

+ (instancetype)actionMovingTo:(CGPoint)position duration:(NSTimeInterval)sec {
    SKMove *a = [[SKMove alloc] init];
    a.duration = sec;
    a->_posStart = CGPointZero;
    a->_posTarget = position;
    a->_posTargetReversed = position;
    return a;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:@(_lastRatio) forKey:@"_lastRatio"];
    [coder encodeObject:@(_posTarget.x) forKey:@"_posTarget.x"];
    [coder encodeObject:@(_posTarget.y) forKey:@"_posTarget.y"];
    [coder encodeObject:@(_posTargetReversed.x) forKey:@"_posTargetReversed.x"];
    [coder encodeObject:@(_posTargetReversed.y) forKey:@"_posTargetReversed.y"];
    [coder encodeObject:@(_posStart.x) forKey:@"_posStart.x"];
    [coder encodeObject:@(_posStart.y) forKey:@"_posStart.y"];
    [coder encodeObject:@(_isReversed) forKey:@"_isReversed"];
    [coder encodeObject:@(_isRelative) forKey:@"_isRelative"];
    [coder encodeObject:@(_useX) forKey:@"_useX"];
    [coder encodeObject:@(_useY) forKey:@"_useY"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _lastRatio = [coder decodeDoubleForKey:@"_lastRatio"];
        _posTarget.x = [coder decodeDoubleForKey:@"_posTarget.x"];
        _posTarget.y = [coder decodeDoubleForKey:@"_posTarget.y"];
        _posTargetReversed.x = [coder decodeDoubleForKey:@"_posTargetReversed.x"];
        _posTargetReversed.y = [coder decodeDoubleForKey:@"_posTargetReversed.y"];
        _posStart.x = [coder decodeDoubleForKey:@"_posStart.x"];
        _posStart.y = [coder decodeDoubleForKey:@"_posStart.y"];
        _isReversed = [coder decodeBoolForKey:@"_isReversed"];
        _isRelative = [coder decodeBoolForKey:@"_isRelative"];
        _useX = [coder decodeBoolForKey:@"_useX"];
        _useY = [coder decodeBoolForKey:@"_useY"];
    }
    return self;
}

@end

@implementation SKScale {
    double _lastRatio;
    double _scaleTargetX, _scaleTargetY;
    double _scaleTargetReversedX, _scaleTargetReversedY;
    double _deltaScaleX, _deltaScaleY;
    BOOL _isReversed, _isRelative, _useX, _useY, _isTargetSizeBased;
    CGSize _targetSize;
}

- (instancetype)init {
    if ((self = [super init])) {
        _useX = YES;
        _useY = YES;
    }
    return self;
}

+ (instancetype)actionScalingTo:(CGFloat)scale duration:(NSTimeInterval)sec {
    SKScale *a = [[SKScale alloc] init];
    a.duration = sec;
    a->_scaleTargetX = scale;
    a->_scaleTargetY = scale;
    a->_scaleTargetReversedX = scale;
    a->_scaleTargetReversedY = scale;
    a->_targetSize = CGSizeMake(100, 100);
    return a;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:@(_lastRatio) forKey:@"_lastRatio"];
    [coder encodeObject:@(_scaleTargetX) forKey:@"_scaleTargetX"];
    [coder encodeObject:@(_scaleTargetY) forKey:@"_scaleTargetY"];
    [coder encodeObject:@(_scaleTargetReversedX) forKey:@"_scaleTargetReversedX"];
    [coder encodeObject:@(_scaleTargetReversedY) forKey:@"_scaleTargetReversedY"];
    [coder encodeObject:@(_deltaScaleX) forKey:@"_deltaScaleX"];
    [coder encodeObject:@(_deltaScaleY) forKey:@"_deltaScaleY"];
    [coder encodeObject:@(_isReversed) forKey:@"_isReversed"];
    [coder encodeObject:@(_isRelative) forKey:@"_isRelative"];
    [coder encodeObject:@(_useX) forKey:@"_useX"];
    [coder encodeObject:@(_useY) forKey:@"_useY"];
    [coder encodeObject:@(_isTargetSizeBased) forKey:@"_isTargetSizeBased"];
    [coder encodeSize:_targetSize forKey:@"_targetSize"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _lastRatio = [coder decodeDoubleForKey:@"_lastRatio"];
        _scaleTargetX = [coder decodeDoubleForKey:@"_scaleTargetX"];
        _scaleTargetY = [coder decodeDoubleForKey:@"_scaleTargetY"];
        _scaleTargetReversedX = [coder decodeDoubleForKey:@"_scaleTargetReversedX"];
        _scaleTargetReversedY = [coder decodeDoubleForKey:@"_scaleTargetReversedY"];
        _deltaScaleX = [coder decodeDoubleForKey:@"_deltaScaleX"];
        _deltaScaleY = [coder decodeDoubleForKey:@"_deltaScaleY"];
        _isReversed = [coder decodeBoolForKey:@"_isReversed"];
        _isRelative = [coder decodeBoolForKey:@"_isRelative"];
        _useX = [coder decodeBoolForKey:@"_useX"];
        _useY = [coder decodeBoolForKey:@"_useY"];
        _isTargetSizeBased = [coder decodeBoolForKey:@"_isTargetSizeBased"];
        _targetSize = [coder decodeSizeForKey:@"_targetSize"];
    }
    return self;
}

@end

@implementation SKRotate {
    double _rotX, _rotY, _rotZ;
    double _lastRotX, _lastRotY, _lastRotZ;
    double _lastRatio;
    BOOL _isReversed, _isRelative, _isUnitArc;
    BOOL _useX, _useY, _useZ;
}

- (instancetype)init {
    if ((self = [super init])) {
        _useX = YES;
        _useY = YES;
        _useZ = YES;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:@(_rotX) forKey:@"_rotX"];
    [coder encodeObject:@(_rotY) forKey:@"_rotY"];
    [coder encodeObject:@(_rotZ) forKey:@"_rotZ"];
    [coder encodeObject:@(_lastRotX) forKey:@"_lastRotX"];
    [coder encodeObject:@(_lastRotY) forKey:@"_lastRotY"];
    [coder encodeObject:@(_lastRotZ) forKey:@"_lastRotZ"];
    [coder encodeObject:@(_lastRatio) forKey:@"_lastRatio"];
    [coder encodeObject:@(_isReversed) forKey:@"_isReversed"];
    [coder encodeObject:@(_isRelative) forKey:@"_isRelative"];
    [coder encodeObject:@(_isUnitArc) forKey:@"_isUnitArc"];
    [coder encodeObject:@(_useX) forKey:@"_useX"];
    [coder encodeObject:@(_useY) forKey:@"_useY"];
    [coder encodeObject:@(_useZ) forKey:@"_useZ"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _rotX = [coder decodeDoubleForKey:@"_rotX"];
        _rotY = [coder decodeDoubleForKey:@"_rotY"];
        _rotZ = [coder decodeDoubleForKey:@"_rotZ"];
        _lastRotX = [coder decodeDoubleForKey:@"_lastRotX"];
        _lastRotY = [coder decodeDoubleForKey:@"_lastRotY"];
        _lastRotZ = [coder decodeDoubleForKey:@"_lastRotZ"];
        _lastRatio = [coder decodeDoubleForKey:@"_lastRatio"];
        _isReversed = [coder decodeBoolForKey:@"_isReversed"];
        _isRelative = [coder decodeBoolForKey:@"_isRelative"];
        _isUnitArc = [coder decodeBoolForKey:@"_isUnitArc"];
        _useX = [coder decodeBoolForKey:@"_useX"];
        _useY = [coder decodeBoolForKey:@"_useY"];
        _useZ = [coder decodeBoolForKey:@"_useZ"];
    }
    return self;
}

@end

@implementation SKResize {
    double _lastRatio;
    CGSize _sizeTarget, _sizeTargetReversed, _sizeResidual;
    BOOL _isReversed, _isRelative, _useW, _useH;
}

- (instancetype)init {
    if ((self = [super init])) {
        _useW = YES;
        _useH = YES;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:@(_lastRatio) forKey:@"_lastRatio"];
    [coder encodeObject:@(_sizeTarget.width) forKey:@"_sizeTarget.width"];
    [coder encodeObject:@(_sizeTarget.height) forKey:@"_sizeTarget.height"];
    [coder encodeObject:@(_sizeTargetReversed.width) forKey:@"_sizeTargetReversed.width"];
    [coder encodeObject:@(_sizeTargetReversed.height) forKey:@"_sizeTargetReversed.height"];
    [coder encodeObject:@(_sizeResidual.width) forKey:@"_sizeResidual.width"];
    [coder encodeObject:@(_sizeResidual.height) forKey:@"_sizeResidual.height"];
    [coder encodeObject:@(_isReversed) forKey:@"_isReversed"];
    [coder encodeObject:@(_isRelative) forKey:@"_isRelative"];
    [coder encodeObject:@(_useW) forKey:@"_useW"];
    [coder encodeObject:@(_useH) forKey:@"_useH"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _lastRatio = [coder decodeDoubleForKey:@"_lastRatio"];
        _sizeTarget.width = [coder decodeDoubleForKey:@"_sizeTarget.width"];
        _sizeTarget.height = [coder decodeDoubleForKey:@"_sizeTarget.height"];
        _sizeTargetReversed.width = [coder decodeDoubleForKey:@"_sizeTargetReversed.width"];
        _sizeTargetReversed.height = [coder decodeDoubleForKey:@"_sizeTargetReversed.height"];
        _sizeResidual.width = [coder decodeDoubleForKey:@"_sizeResidual.width"];
        _sizeResidual.height = [coder decodeDoubleForKey:@"_sizeResidual.height"];
        _isReversed = [coder decodeBoolForKey:@"_isReversed"];
        _isRelative = [coder decodeBoolForKey:@"_isRelative"];
        _useW = [coder decodeBoolForKey:@"_useW"];
        _useH = [coder decodeBoolForKey:@"_useH"];
    }
    return self;
}

@end

@implementation SKFade {
    double _alphaTarget, _alphaTargetReversed, _lastAlpha, _isRelative;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:@(_alphaTarget) forKey:@"_alphaTarget"];
    [coder encodeObject:@(_alphaTargetReversed) forKey:@"_alphaTargetReversed"];
    [coder encodeObject:@(_lastAlpha) forKey:@"_lastAlpha"];
    [coder encodeObject:@(_isRelative) forKey:@"_isRelative"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _alphaTarget = [coder decodeDoubleForKey:@"_alphaTarget"];
        _alphaTargetReversed = [coder decodeDoubleForKey:@"_alphaTargetReversed"];
        _lastAlpha = [coder decodeDoubleForKey:@"_lastAlpha"];
        _isRelative = [coder decodeDoubleForKey:@"_isRelative"];
    }
    return self;
}

@end

@implementation SKColorize {
    double _colorMix, _colorBlendR, _colorBlendG, _colorBlendB, _colorBlendA;
    BOOL _isMixOnly;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:@(_colorMix) forKey:@"_colorMix"];
    [coder encodeObject:@(_colorBlendR) forKey:@"_colorBlendR"];
    [coder encodeObject:@(_colorBlendG) forKey:@"_colorBlendG"];
    [coder encodeObject:@(_colorBlendB) forKey:@"_colorBlendB"];
    [coder encodeObject:@(_colorBlendA) forKey:@"_colorBlendA"];
    [coder encodeObject:@(_isMixOnly) forKey:@"_isMixOnly"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _colorMix = [coder decodeDoubleForKey:@"_colorMix"];
        _colorBlendR = [coder decodeDoubleForKey:@"_colorBlendR"];
        _colorBlendG = [coder decodeDoubleForKey:@"_colorBlendG"];
        _colorBlendB = [coder decodeDoubleForKey:@"_colorBlendB"];
        _colorBlendA = [coder decodeDoubleForKey:@"_colorBlendA"];
        _isMixOnly = [coder decodeBoolForKey:@"_isMixOnly"];
    }
    return self;
}

@end

@implementation SKWait
@end

@implementation SKRemove {
    BOOL _hasFired;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:@(_hasFired) forKey:@"_hasFired"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self)
        _hasFired = [coder decodeBoolForKey:@"_hasFired"];
    return self;
}

@end

@implementation SKGroup {
    NSArray<SKAction *> *_actions;
}

+ (instancetype)actionWithActions:(NSArray<SKAction *> *)actions {
    SKGroup *a = [[SKGroup alloc] init];
    NSTimeInterval longest = 0;
    for (SKAction *x in actions)
        if (x.duration > longest)
            longest = x.duration;
    a.duration = longest;
    a->_actions = [actions copy];
    return a;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:_actions forKey:@"_actions"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self)
        _actions = [coder decodeObjectOfClasses:
            [NSSet setWithObjects:[NSArray class], [SKAction class], nil]
            forKey:@"_actions"];
    return self;
}

@end

@implementation SKSequence {
    unsigned long _animIndex;
    NSArray<SKAction *> *_actions;
}

+ (instancetype)actionWithActions:(NSArray<SKAction *> *)actions {
    SKSequence *a = [[SKSequence alloc] init];
    NSTimeInterval total = 0;
    for (SKAction *x in actions)
        total += x.duration;
    a.duration = total;
    a->_actions = [actions copy];
    return a;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:@(_animIndex) forKey:@"_mycaction->_animIndex"];
    [coder encodeObject:_actions forKey:@"_actions"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _animIndex = (unsigned long)[coder decodeIntegerForKey:@"_mycaction->_animIndex"];
        _actions = [coder decodeObjectOfClasses:
            [NSSet setWithObjects:[NSArray class], [SKAction class], nil]
            forKey:@"_actions"];
    }
    return self;
}

@end

@implementation SKRepeat {
    NSUInteger _timesToRepeat;
    NSUInteger _timesRepeated;
    SKAction *_repeatedAction;
    BOOL _forever;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:@(_timesToRepeat) forKey:@"_timesToRepeat"];
    [coder encodeObject:@(_timesRepeated) forKey:@"_timesRepeated"];
    [coder encodeObject:_repeatedAction forKey:@"_repeatedAction"];
    [coder encodeObject:@(_forever) forKey:@"_forever"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _timesToRepeat = [coder decodeIntegerForKey:@"_timesToRepeat"];
        _timesRepeated = [coder decodeIntegerForKey:@"_timesRepeated"];
        _repeatedAction = [coder decodeObjectOfClasses:
            [NSSet setWithObjects:[SKAction class], nil]
            forKey:@"_repeatedAction"];
        _forever = [coder decodeBoolForKey:@"_forever"];
    }
    return self;
}

@end

@implementation SKCustomAction
@end

@implementation SKRunBlock
@end

@implementation SKAnimate
@end