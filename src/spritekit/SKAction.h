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

NS_ASSUME_NONNULL_END