/*
 * Copyright (C) 2026, LibreDarwin
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Clean-room reimplementation of the SpriteKit SKAction class cluster.
 *
 * SKAction is an abstract class cluster: only its concrete subclasses are ever
 * archived, and each subclass reimplements -encodeWithCoder:/-initWithCoder:
 * in the exact field order Apple's implementation uses (see the disassembly
 * cross-check in local/SpriteKit/SpriteKit.md and samples/emit_order.txt).
 */

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SKActionTimingMode) {
    SKActionTimingLinear = 0,
    SKActionTimingEaseIn = 1,
    SKActionTimingEaseOut = 2,
    SKActionTimingEaseInEaseOut = 3,
};

@interface SKAction : NSObject <NSCopying, NSSecureCoding>

@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) SKActionTimingMode timingMode;

+ (instancetype)action;
+ (instancetype)moveTo:(CGPoint)position duration:(NSTimeInterval)sec;
+ (instancetype)scaleTo:(CGFloat)scale duration:(NSTimeInterval)sec;
+ (instancetype)sequence:(NSArray<SKAction *> *)actions;
+ (instancetype)group:(NSArray<SKAction *> *)actions;

+ (instancetype)waitForDuration:(NSTimeInterval)sec;
+ (instancetype)hide;
+ (instancetype)unhide;
+ (instancetype)playSoundFileNamed:(NSString *)soundFile waitForCompletion:(BOOL)wait;
+ (instancetype)performSelector:(SEL)selector onTarget:(id)target;
+ (instancetype)runAction:(SKAction *)action onChildWithName:(NSString *)name;
+ (instancetype)speedTo:(CGFloat)speed duration:(NSTimeInterval)sec;
+ (instancetype)speedBy:(CGFloat)speed duration:(NSTimeInterval)sec;
+ (instancetype)falloffTo:(float)falloff duration:(NSTimeInterval)sec;
+ (instancetype)falloffBy:(float)falloff duration:(NSTimeInterval)sec;
+ (instancetype)strengthTo:(float)strength duration:(NSTimeInterval)sec;
+ (instancetype)strengthBy:(float)strength duration:(NSTimeInterval)sec;
+ (instancetype)followPath:(CGPathRef)path duration:(NSTimeInterval)sec;
+ (instancetype)followPath:(CGPathRef)path
                  asOffset:(BOOL)offset
              orientToPath:(BOOL)orient
                  duration:(NSTimeInterval)sec;
+ (instancetype)followPath:(CGPathRef)path speed:(CGFloat)speed;
+ (instancetype)followPath:(CGPathRef)path
                  asOffset:(BOOL)offset
              orientToPath:(BOOL)orient
                     speed:(CGFloat)speed;
+ (nullable instancetype)actionNamed:(NSString *)name;
+ (nullable instancetype)animateWithWarps:(NSArray *)warps
                                    times:(NSArray<NSNumber *> *)times;
+ (nullable instancetype)animateWithWarps:(NSArray *)warps
                                    times:(NSArray<NSNumber *> *)times
                                  restore:(BOOL)restore;

@end

#pragma mark - Concrete subclasses (one per archived class name)

@interface SKMove : SKAction
@end
@interface SKScale : SKAction
@end
@interface SKRotate : SKAction
@end
@interface SKResize : SKAction
@end
@interface SKFade : SKAction
@end
@interface SKColorize : SKAction
@end
@interface SKWait : SKAction
@end
@interface SKRemove : SKAction
@end
@interface SKGroup : SKAction
@end
@interface SKSequence : SKAction
@end
@interface SKRepeat : SKAction
@end
@interface SKCustomAction : SKAction
@end
@interface SKRunBlock : SKAction
@end
@interface SKAnimate : SKAction
@end
@interface SKFalloff : SKAction
@end
@interface SKSpeed : SKAction
@end
@interface SKStrength : SKAction
@end
@interface SKFollowPath : SKAction
@end
@interface SKHide : SKAction
@end
@interface SKPerformSelector : SKAction
@end
@interface SKPlaySound : SKAction
@end
@interface SKReferencedAction : SKAction
@end
@interface SKRunAction : SKAction
@end
@interface SKAnimateWarp : SKAction
@end

NS_ASSUME_NONNULL_END