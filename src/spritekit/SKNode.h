// Copyright (C) 2026, LibreDarwin
// SPDX-License-Identifier: BSD-3-Clause
//
// Clean-room reimplementation of Apple's SpriteKit node hierarchy.
//
// SKNode is the root of the node cluster (SKNode, SKEffectNode, SKScene,
// SKSpriteNode, SKLabelNode, SKShapeNode, SKEmitterNode, ...).  On macOS its
// runtime superclass is NSResponder (so the archived class hierarchy is
// ["SKNode","NSResponder","NSObject"]); on iOS it is NSObject.
//
// The encode order is recovered from the dyld-cache disassembly, not from the
// archive's hash-bucket layout -- see local/SpriteKit/samples/emit_order_nodes.txt.

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#define SK_NODE_SUPERCLASS NSResponder
#else
#define SK_NODE_SUPERCLASS NSObject
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SKNode : SK_NODE_SUPERCLASS <NSCoding, NSCopying>

+ (instancetype)node;

@property (nonatomic) CGPoint position;
@property (nonatomic) double opacity;
@property (nonatomic) double xRotation;
@property (nonatomic) double yRotation;
@property (nonatomic) double zRotation;
@property (nonatomic) double xScale;
@property (nonatomic) double yScale;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, nullable) id userData;   // actually NSMutableDictionary
@property (nonatomic) BOOL hidden;
@property (nonatomic) BOOL paused;
@property (nonatomic) double zPosition;

@property (nonatomic, readonly) NSMutableArray<SKNode *> *children;

- (void)addChild:(SKNode *)node;
- (void)removeFromParent;

@end

#pragma mark - SKEffectNode

@interface SKEffectNode : SKNode
@property (nonatomic, nullable) id filter;     // CIFilter
@property (nonatomic, nullable) id shader;     // SKShader
@property (nonatomic) BOOL shouldRasterize;
@property (nonatomic) BOOL shouldEnableEffects;
@property (nonatomic) BOOL shouldCenterFilter;
@property (nonatomic) long blendMode;
@end

#pragma mark - SKScene

@interface SKScene : SKEffectNode
@property (nonatomic, nullable) id scenePinBody;
@property (nonatomic) double backgroundColorR;
@property (nonatomic) double backgroundColorG;
@property (nonatomic) double backgroundColorB;
@property (nonatomic) double backgroundColorA;
@property (nonatomic) CGRect sceneBounds;
@property (nonatomic) CGRect visibleRect;
@property (nonatomic, nullable) id camera;     // SKCameraNode
@property (nonatomic) NSInteger scaleMode;
@property (nonatomic, nullable) id physicsWorld; // SKPhysicsWorld
@property (nonatomic) CGPoint anchorPoint;
@end

#pragma mark - SKSpriteNode

@interface SKSpriteNode : SKNode
@property (nonatomic) CGSize size;
@property (nonatomic) long blendMode;
@property (nonatomic, nullable) id shader;
@property (nonatomic, nullable) id normalTexture;
@property (nonatomic, nullable) id texture;
@property (nonatomic) double colorMix;
@property (nonatomic) CGPoint anchorPoint;
@property (nonatomic) double baseColorR;
@property (nonatomic) double baseColorG;
@property (nonatomic) double baseColorB;
@property (nonatomic) double baseColorA;
@property (nonatomic) CGRect centerRect;
@property (nonatomic, nullable) id warpGeometry;
@property (nonatomic) NSInteger subdivisionLevels;

+ (instancetype)spriteNodeWithColor:(nullable id)color size:(CGSize)size;
@end

#pragma mark - SKLabelNode

@interface SKLabelNode : SKNode
@property (nonatomic, copy, nullable) NSString *fontName;
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, nullable) id attributedText;
@property (nonatomic, nullable) id textSprites;
@property (nonatomic, nullable) id textSprite;
@property (nonatomic) double fontColorR;
@property (nonatomic) double fontColorG;
@property (nonatomic) double fontColorB;
@property (nonatomic) double fontColorA;
@property (nonatomic) double colorR;
@property (nonatomic) double colorG;
@property (nonatomic) double colorB;
@property (nonatomic) double colorA;
@property (nonatomic) double fontSize;
@property (nonatomic) double labelColorBlend;
@property (nonatomic) NSInteger labelBlendMode;
@property (nonatomic) double horizontalAlignmentMode;
@property (nonatomic) double verticalAlignmentMode;
@property (nonatomic) NSInteger numberOfLines;
@property (nonatomic) float preferredMaxLayoutWidth;

+ (instancetype)labelNodeWithText:(nullable NSString *)text;
@end

NS_ASSUME_NONNULL_END