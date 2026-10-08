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

#pragma mark - PKPhysicsBody / PKPhysicsWorld

// An SKScene archives its physics state under PhysicsKit's class names, with
// PKPhysicsBody and PKPhysicsWorld both rooted at NSObject
// (["$classname":"PKPhysicsBody", "$classes":["PKPhysicsBody","NSObject"]]).
// The clean-room runtime therefore defines its own classes with those exact
// names so the archived hierarchy matches byte-for-byte.

@interface PKPhysicsBody : NSObject <NSCoding>
@property (nonatomic) NSInteger shapeType;
@property (nonatomic) double radius;
@property (nonatomic, copy) NSString *p0;
@property (nonatomic) double edgeRadius;
@property (nonatomic) BOOL dynamic;
@property (nonatomic) BOOL needsContinuousCollsionDetection;
@property (nonatomic) BOOL allowRotation;
@property (nonatomic) BOOL pinned;
@property (nonatomic) double friction;
@property (nonatomic) double charge;
@property (nonatomic) double restitution;
@property (nonatomic) double density;
@property (nonatomic) BOOL affectedByGravity;
@property (nonatomic) int32_t categoryBitMask;
@property (nonatomic) int32_t collisionBitMask;
@property (nonatomic) int32_t intersectionTestBitMask;
@property (nonatomic) int32_t fieldBitMask;
@property (nonatomic, copy) NSString *linearVelocity;
@property (nonatomic) double angularVelocity;
@property (nonatomic) double linearDamping;
@property (nonatomic) double angularDamping;

// Static body SKScene attaches to its world (dynamic == NO, category 0).
+ (instancetype)pinBody;
+ (instancetype)bodyWithCircleOfRadius:(double)radius;
@end

@interface PKPhysicsWorld : NSObject <NSCoding>
@property (nonatomic, readonly) NSMutableArray *joints;
@property (nonatomic, readonly) NSMutableArray *bodies;
@property (nonatomic, copy) NSString *gravity;
@property (nonatomic) double speedMultiplier;
+ (instancetype)world;
@end

#pragma mark - SKScene

@interface SKScene : SKEffectNode
@property (nonatomic, strong, nullable) PKPhysicsBody *scenePinBody;
@property (nonatomic) double backgroundColorR;
@property (nonatomic) double backgroundColorG;
@property (nonatomic) double backgroundColorB;
@property (nonatomic) double backgroundColorA;
@property (nonatomic) CGRect sceneBounds;
@property (nonatomic) CGRect visibleRect;
@property (nonatomic, nullable) id camera;     // SKCameraNode
@property (nonatomic) NSInteger scaleMode;
@property (nonatomic, strong, nullable) PKPhysicsWorld *physicsWorld;
@property (nonatomic) CGPoint anchorPoint;
@property (nonatomic) CGSize size;

+ (instancetype)sceneWithSize:(CGSize)size;
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

#pragma mark - SKShapeNode

@interface SKShapeNode : SKNode
@property (nonatomic, nullable) id cgPath;         // private SKCGSPath form
@property (nonatomic) double lineWidth;
@property (nonatomic) double smoothWidth;
@property (nonatomic) BOOL smoothStroke;
@property (nonatomic) double strokeColorR;
@property (nonatomic) double strokeColorG;
@property (nonatomic) double strokeColorB;
@property (nonatomic) double strokeColorA;
@property (nonatomic) double fillColorR;
@property (nonatomic) double fillColorG;
@property (nonatomic) double fillColorB;
@property (nonatomic) double fillColorA;
@property (nonatomic) NSInteger lineJoin;
@property (nonatomic) NSInteger lineCap;
@property (nonatomic) double miterLimit;
@property (nonatomic, nullable) id strokeTexture;
@property (nonatomic, nullable) id fillTexture;

+ (instancetype)shapeNodeWithCircleOfRadius:(CGFloat)radius;
@end

NS_ASSUME_NONNULL_END