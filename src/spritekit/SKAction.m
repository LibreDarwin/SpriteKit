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
@interface SKWait (Internal)
+ (instancetype)actionWaitingFor:(NSTimeInterval)sec;
@end
@interface SKHide (Internal)
+ (instancetype)actionHidden:(BOOL)hidden;
@end
@interface SKPlaySound (Internal)
+ (instancetype)actionPlayingFile:(nullable NSString *)file wait:(BOOL)wait;
@end
@interface SKPerformSelector (Internal)
+ (instancetype)actionPerforming:(SEL)selector;
@end
@interface SKRunAction (Internal)
+ (instancetype)actionRunning:(SKAction *)action onChild:(nullable NSString *)name;
@end
@interface SKSpeed (Internal)
+ (instancetype)actionSpeed:(double)speed
                   reversed:(double)reversed
                   relative:(BOOL)relative
                   duration:(NSTimeInterval)sec;
@end
@interface SKStrength (Internal)
+ (instancetype)actionStrength:(double)strength
                      reversed:(double)reversed
                      relative:(BOOL)relative
                      duration:(NSTimeInterval)sec;
@end
@interface SKFalloff (Internal)
+ (instancetype)actionFalloff:(double)falloff
                     reversed:(double)reversed
                     relative:(BOOL)relative
                     duration:(NSTimeInterval)sec;
@end
@interface SKFollowPath (Internal)
+ (instancetype)actionFollowingPath:(nullable CGPathRef)path
                             offset:(BOOL)offset
                             orient:(BOOL)orient
                           duration:(NSTimeInterval)sec;
@end
@interface SKReferencedAction (Internal)
+ (instancetype)actionReferencing:(nullable NSString *)name;
@end
@interface SKAnimateWarp (Internal)
+ (instancetype)actionWithWarps:(NSArray *)warps
                          times:(NSArray<NSNumber *> *)times
                        restore:(BOOL)restore;
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

+ (instancetype)waitForDuration:(NSTimeInterval)sec {
    return [SKWait actionWaitingFor:sec];
}

+ (instancetype)hide {
    return [SKHide actionHidden:YES];
}

+ (instancetype)unhide {
    return [SKHide actionHidden:NO];
}

+ (instancetype)playSoundFileNamed:(NSString *)soundFile waitForCompletion:(BOOL)wait {
    return [SKPlaySound actionPlayingFile:soundFile wait:wait];
}

+ (instancetype)performSelector:(SEL)selector onTarget:(id)target {
    return [SKPerformSelector actionPerforming:selector];
}

+ (instancetype)runAction:(SKAction *)action onChildWithName:(NSString *)name {
    return [SKRunAction actionRunning:action onChild:name];
}

+ (instancetype)speedTo:(CGFloat)speed duration:(NSTimeInterval)sec {
    return [SKSpeed actionSpeed:speed reversed:speed relative:NO duration:sec];
}

+ (instancetype)speedBy:(CGFloat)speed duration:(NSTimeInterval)sec {
    return [SKSpeed actionSpeed:speed reversed:(speed == 0 ? 0 : 1.0 / speed)
                       relative:YES duration:sec];
}

+ (instancetype)falloffTo:(float)falloff duration:(NSTimeInterval)sec {
    return [SKFalloff actionFalloff:falloff reversed:falloff relative:NO duration:sec];
}

+ (instancetype)falloffBy:(float)falloff duration:(NSTimeInterval)sec {
    return [SKFalloff actionFalloff:falloff reversed:(falloff == 0 ? 0 : 1.0 / falloff)
                           relative:YES duration:sec];
}

+ (instancetype)strengthTo:(float)strength duration:(NSTimeInterval)sec {
    return [SKStrength actionStrength:strength reversed:strength relative:NO duration:sec];
}

+ (instancetype)strengthBy:(float)strength duration:(NSTimeInterval)sec {
    return [SKStrength actionStrength:strength reversed:(strength == 0 ? 0 : 1.0 / strength)
                             relative:YES duration:sec];
}

+ (instancetype)followPath:(CGPathRef)path duration:(NSTimeInterval)sec {
    return [SKFollowPath actionFollowingPath:path offset:YES orient:YES duration:sec];
}

+ (instancetype)followPath:(CGPathRef)path
                  asOffset:(BOOL)offset
              orientToPath:(BOOL)orient
                  duration:(NSTimeInterval)sec {
    return [SKFollowPath actionFollowingPath:path offset:offset orient:orient duration:sec];
}

+ (instancetype)followPath:(CGPathRef)path speed:(CGFloat)speed {
    return [SKFollowPath actionFollowingPath:path offset:YES orient:YES duration:0];
}

+ (instancetype)followPath:(CGPathRef)path
                  asOffset:(BOOL)offset
              orientToPath:(BOOL)orient
                     speed:(CGFloat)speed {
    return [SKFollowPath actionFollowingPath:path offset:offset orient:orient duration:0];
}

+ (instancetype)actionNamed:(NSString *)name {
    return [SKReferencedAction actionReferencing:name];
}

+ (instancetype)animateWithWarps:(NSArray *)warps times:(NSArray<NSNumber *> *)times {
    return [SKAnimateWarp actionWithWarps:warps times:times restore:NO];
}

+ (instancetype)animateWithWarps:(NSArray *)warps
                           times:(NSArray<NSNumber *> *)times
                         restore:(BOOL)restore {
    return [SKAnimateWarp actionWithWarps:warps times:times restore:restore];
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
+ (instancetype)actionWaitingFor:(NSTimeInterval)sec {
    SKWait *a = [[SKWait alloc] init];
    a.duration = sec;
    return a;
}
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

#pragma mark - SKFalloff

@implementation SKFalloff {
    double _isRelative;
    double _isReversed;
    double _lastRatio;
    double _target;
    double _targetReversed;
    double _deltafalloff;
}

- (instancetype)init {
    if ((self = [super init])) {
        _isRelative = 1.0;
        _target = 1.0;
    }
    return self;
}

+ (instancetype)actionFalloff:(double)falloff
                     reversed:(double)reversed
                     relative:(BOOL)relative
                     duration:(NSTimeInterval)sec {
    SKFalloff *a = [[SKFalloff alloc] init];
    a.duration = sec;
    a->_target = falloff;
    a->_targetReversed = reversed;
    a->_isRelative = relative ? 1.0 : 0.0;
    return a;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:@(_target) forKey:@"_target"];
    [coder encodeObject:@(_targetReversed) forKey:@"_targetReversed"];
    [coder encodeObject:@(_deltafalloff) forKey:@"_deltafalloff"];
    [coder encodeObject:@(_lastRatio) forKey:@"_lastRatio"];
    [coder encodeObject:@(_isReversed) forKey:@"_isReversed"];
    [coder encodeObject:@(_isRelative) forKey:@"_isRelative"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _isRelative = [coder decodeDoubleForKey:@"_isRelative"];
        _isReversed = [coder decodeDoubleForKey:@"_isReversed"];
        _lastRatio = [coder decodeDoubleForKey:@"_lastRatio"];
        _target = [coder decodeDoubleForKey:@"_target"];
        _targetReversed = [coder decodeDoubleForKey:@"_targetReversed"];
        _deltafalloff = [coder decodeDoubleForKey:@"_deltafalloff"];
    }
    return self;
}

@end

#pragma mark - SKSpeed

@implementation SKSpeed {
    double _isRelative;
    double _isReversed;
    double _lastRatio;
    double _speedTarget;
    double _speedTargetReversed;
    double _deltaSpeed;
}

- (instancetype)init {
    if ((self = [super init])) {
        _isRelative = 1.0;
        _speedTarget = 1.0;
    }
    return self;
}

+ (instancetype)actionSpeed:(double)speed
                   reversed:(double)reversed
                   relative:(BOOL)relative
                   duration:(NSTimeInterval)sec {
    SKSpeed *a = [[SKSpeed alloc] init];
    a.duration = sec;
    a->_speedTarget = speed;
    a->_speedTargetReversed = reversed;
    a->_isRelative = relative ? 1.0 : 0.0;
    return a;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:@(_speedTarget) forKey:@"_speedTarget"];
    [coder encodeObject:@(_speedTargetReversed) forKey:@"_speedTargetReversed"];
    [coder encodeObject:@(_deltaSpeed) forKey:@"_deltaSpeed"];
    [coder encodeObject:@(_lastRatio) forKey:@"_lastRatio"];
    [coder encodeObject:@(_isReversed) forKey:@"_isReversed"];
    [coder encodeObject:@(_isRelative) forKey:@"_isRelative"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _isRelative = [coder decodeDoubleForKey:@"_isRelative"];
        _isReversed = [coder decodeDoubleForKey:@"_isReversed"];
        _lastRatio = [coder decodeDoubleForKey:@"_lastRatio"];
        _speedTarget = [coder decodeDoubleForKey:@"_speedTarget"];
        _speedTargetReversed = [coder decodeDoubleForKey:@"_speedTargetReversed"];
        _deltaSpeed = [coder decodeDoubleForKey:@"_deltaSpeed"];
    }
    return self;
}

@end

#pragma mark - SKStrength

@implementation SKStrength {
    double _isRelative;
    double _isReversed;
    double _lastRatio;
    double _strengthTarget;
    double _strengthTargetReversed;
    double _deltastrength;
}

- (instancetype)init {
    if ((self = [super init])) {
        _isRelative = 1.0;
        _strengthTarget = 1.0;
    }
    return self;
}

+ (instancetype)actionStrength:(double)strength
                      reversed:(double)reversed
                      relative:(BOOL)relative
                      duration:(NSTimeInterval)sec {
    SKStrength *a = [[SKStrength alloc] init];
    a.duration = sec;
    a->_strengthTarget = strength;
    a->_strengthTargetReversed = reversed;
    a->_isRelative = relative ? 1.0 : 0.0;
    return a;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:@(_strengthTarget) forKey:@"_strengthTarget"];
    [coder encodeObject:@(_strengthTargetReversed) forKey:@"_strengthTargetReversed"];
    [coder encodeObject:@(_deltastrength) forKey:@"_deltastrength"];
    [coder encodeObject:@(_lastRatio) forKey:@"_lastRatio"];
    [coder encodeObject:@(_isReversed) forKey:@"_isReversed"];
    [coder encodeObject:@(_isRelative) forKey:@"_isRelative"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _isRelative = [coder decodeDoubleForKey:@"_isRelative"];
        _isReversed = [coder decodeDoubleForKey:@"_isReversed"];
        _lastRatio = [coder decodeDoubleForKey:@"_lastRatio"];
        _strengthTarget = [coder decodeDoubleForKey:@"_strengthTarget"];
        _strengthTargetReversed = [coder decodeDoubleForKey:@"_strengthTargetReversed"];
        _deltastrength = [coder decodeDoubleForKey:@"_deltastrength"];
    }
    return self;
}

@end

#pragma mark - SKFollowPath

@implementation SKFollowPath {
    CGPathRef _cgPath;
    BOOL _isOffset;
    BOOL _orient;
}

+ (instancetype)actionFollowingPath:(nullable CGPathRef)path
                             offset:(BOOL)offset
                             orient:(BOOL)orient
                           duration:(NSTimeInterval)sec {
    SKFollowPath *a = [[SKFollowPath alloc] init];
    a.duration = sec;
    a->_cgPath = path;
    a->_isOffset = offset;
    a->_orient = orient;
    return a;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:(__bridge id)_cgPath forKey:@"_cgPath"];
    [coder encodeObject:@(_isOffset) forKey:@"_isOffset"];
    [coder encodeObject:@(_orient) forKey:@"_orient"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _cgPath = (__bridge CGPathRef)[coder decodeObjectForKey:@"_cgPath"];
        _isOffset = [coder decodeBoolForKey:@"_isOffset"];
        _orient = [coder decodeBoolForKey:@"_orient"];
    }
    return self;
}

@end

#pragma mark - SKHide

@implementation SKHide {
    BOOL _hiddenValue;
}

- (instancetype)init {
    if ((self = [super init])) {
        _hiddenValue = YES;
    }
    return self;
}

+ (instancetype)actionHidden:(BOOL)hidden {
    SKHide *a = [[SKHide alloc] init];
    a->_hiddenValue = hidden;
    return a;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeBool:_hiddenValue forKey:@"_hiddenValue"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self)
        _hiddenValue = [coder decodeBoolForKey:@"_hiddenValue"];
    return self;
}

@end

#pragma mark - SKPerformSelector

@implementation SKPerformSelector {
    SEL _selector;
}

+ (instancetype)actionPerforming:(SEL)selector {
    SKPerformSelector *a = [[SKPerformSelector alloc] init];
    a->_selector = selector;
    return a;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:(_selector ? NSStringFromSelector(_selector) : nil)
                 forKey:@"_selector"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        NSString *name = [coder decodeObjectOfClass:[NSString class] forKey:@"_selector"];
        _selector = name ? NSSelectorFromString(name) : NULL;
    }
    return self;
}

@end

#pragma mark - SKPlaySound

@implementation SKPlaySound {
    BOOL _wait;
    NSString *_fileName;
    CGPoint _position;
}

+ (instancetype)actionPlayingFile:(nullable NSString *)file wait:(BOOL)wait {
    SKPlaySound *a = [[SKPlaySound alloc] init];
    a->_fileName = file;
    a->_wait = wait;
    a->_position = CGPointZero;
    return a;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeBool:_wait forKey:@"_wait"];
    [coder encodeObject:_fileName forKey:@"_fileName"];
    [coder encodePoint:_position forKey:@"_position"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _wait = [coder decodeBoolForKey:@"_wait"];
        _fileName = [coder decodeObjectOfClass:[NSString class] forKey:@"_fileName"];
        _position = [coder decodePointForKey:@"_position"];
    }
    return self;
}

@end

#pragma mark - SKReferencedAction

@implementation SKReferencedAction {
    NSString *_referencedActionName;
}

+ (instancetype)actionReferencing:(nullable NSString *)name {
    SKReferencedAction *a = [[SKReferencedAction alloc] init];
    a->_referencedActionName = name;
    return a;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:_referencedActionName forKey:@"_referencedActionName"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self)
        _referencedActionName = [coder decodeObjectOfClass:[NSString class]
                                                    forKey:@"_referencedActionName"];
    return self;
}

@end

#pragma mark - SKRunAction

@implementation SKRunAction {
    SKAction *_action;
    NSString *_actionKey;
    NSString *_subSpriteKey;
    BOOL _waitForKeyedAction;
    BOOL _runOnSubSprite;
}

+ (instancetype)actionRunning:(SKAction *)action onChild:(nullable NSString *)name {
    SKRunAction *a = [[SKRunAction alloc] init];
    a->_action = action;
    a->_subSpriteKey = name;
    a->_runOnSubSprite = YES;
    return a;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:_action forKey:@"_action"];
    [coder encodeObject:_actionKey forKey:@"_actionKey"];
    [coder encodeObject:_subSpriteKey forKey:@"_subSpriteKey"];
    [coder encodeObject:@(_waitForKeyedAction) forKey:@"_waitForKeyedAction"];
    [coder encodeObject:@(_runOnSubSprite) forKey:@"_runOnSubSprite"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _action = [coder decodeObjectOfClass:[SKAction class] forKey:@"_action"];
        _actionKey = [coder decodeObjectOfClass:[NSString class] forKey:@"_actionKey"];
        _subSpriteKey = [coder decodeObjectOfClass:[NSString class] forKey:@"_subSpriteKey"];
        _waitForKeyedAction = [coder decodeBoolForKey:@"_waitForKeyedAction"];
        _runOnSubSprite = [coder decodeBoolForKey:@"_runOnSubSprite"];
    }
    return self;
}

@end

#pragma mark - SKAnimateWarp

@implementation SKAnimateWarp {
    BOOL _restore;
    NSArray *_grids;
    NSArray<NSNumber *> *_times;
}

- (instancetype)init {
    if ((self = [super init])) {
        _restore = YES;
    }
    return self;
}

+ (instancetype)actionWithWarps:(NSArray *)warps
                          times:(NSArray<NSNumber *> *)times
                        restore:(BOOL)restore {
    if (warps.count == 0 || warps.count != times.count) {
        [NSException raise:NSInvalidArgumentException
                    format:@"SKAction: 'warps' and 'times' arrays must have non-zero and equal counts"];
    }
    SKAnimateWarp *a = [[SKAnimateWarp alloc] init];
    a->_grids = [warps mutableCopy];
    a->_times = [times copy];
    a->_restore = restore;
    return a;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeBool:_restore forKey:@"_restore"];
    [coder encodeObject:_grids forKey:@"_grids"];
    [coder encodeObject:_times forKey:@"_times"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _restore = [coder decodeBoolForKey:@"_restore"];
        _grids = [coder decodeObjectOfClass:[NSArray class] forKey:@"_grids"];
        _times = [coder decodeObjectOfClass:[NSArray class] forKey:@"_times"];
    }
    return self;
}

@end