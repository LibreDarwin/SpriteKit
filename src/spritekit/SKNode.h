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

#pragma mark - SKCameraNode

// A camera carries no extra state beyond SKNode; the archive is the 24 SKNode
// fields alone (its _originalClass is "SKCameraNode").
@interface SKCameraNode : SKNode
@end

#pragma mark - SKCropNode

@interface SKCropNode : SKNode
@property (nonatomic, nullable) id mask;      // SKNode
@property (nonatomic) BOOL prefersAlphaMask;
@property (nonatomic) BOOL invertMask;
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
@property (nonatomic, copy, nullable) id backgroundColor;   // SKColor -> RGBA
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
+ (instancetype)labelNodeWithFontNamed:(nullable NSString *)fontName;
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

#pragma mark - SKEmitterNode

// A particle emitter.  Its 54 own fields follow the 24 SKNode fields; the emit
// order and encoding flavour come from tools/sk_emit_spy.m.  Geometry
// (_startPosition/_startPositionVariance/_startSize/_acceleration) is carried as
// tagged-pointer strings ("{0, 0}") matching Apple's NSStringFrom{CGPoint,..}
// defaults, and _emissionAngle defaults to (double)(float)M_PI_2.
@interface SKEmitterNode : SKNode

@property (nonatomic, nullable) id particleAction;              // SKAction
@property (nonatomic) double startColorMix;
@property (nonatomic) double startColorBlendVariance;
@property (nonatomic) double startColorR;
@property (nonatomic) double startColorG;
@property (nonatomic) double startColorB;
@property (nonatomic) double startColorA;
@property (nonatomic) double startColorVarianceR;
@property (nonatomic) double startColorVarianceG;
@property (nonatomic) double startColorVarianceB;
@property (nonatomic) double startColorVarianceA;
@property (nonatomic) double birthrate;
@property (nonatomic, nullable) id particleTexture;
@property (nonatomic, copy, nullable) NSString *startPosition;
@property (nonatomic, copy, nullable) NSString *startPositionVariance;
@property (nonatomic) double startZPosition;
@property (nonatomic) double startZPositionVariance;
@property (nonatomic) double lifetime;
@property (nonatomic) double lifetimeVariance;
@property (nonatomic) double startOpacity;
@property (nonatomic) double startOpacityVariance;
@property (nonatomic) NSInteger particleBlendMode;
@property (nonatomic) double startRotation;
@property (nonatomic) double startRotationVariance;
@property (nonatomic, copy, nullable) NSString *startSize;
@property (nonatomic) double startScale;
@property (nonatomic) double startScaleVariance;
@property (nonatomic, copy, nullable) NSString *acceleration;
@property (nonatomic) double colorSpeedR;
@property (nonatomic) double colorSpeedG;
@property (nonatomic) double colorSpeedB;
@property (nonatomic) double colorSpeedA;
@property (nonatomic) double colorBlendSpeed;
@property (nonatomic) double rotationSpeed;
@property (nonatomic) double scaleSpeed;
@property (nonatomic) double opacitySpeed;
@property (nonatomic) double startSpeed;
@property (nonatomic) double startSpeedVariance;
@property (nonatomic) double emissionAngle;
@property (nonatomic) double emissionAngleVariance;
@property (nonatomic, nullable) id target;
@property (nonatomic, nullable) NSNumber *numParticlesToEmit;
@property (nonatomic) double zPositionSpeed;
@property (nonatomic) double emissionDistance;
@property (nonatomic) double emissionDistanceRange;
@property (nonatomic) int32_t fieldBitMask;
@property (nonatomic, nullable) id particleAlphaSequence;
@property (nonatomic, nullable) id particleColorSequence;
@property (nonatomic, nullable) id particleColorBlendFactorSequence;
@property (nonatomic, nullable) id particleScaleSequence;
@property (nonatomic, nullable) id particleRotationSequence;
@property (nonatomic, nullable) id fieldInfluenceSequence;
@property (nonatomic, nullable) id particleSpeedSequence;
@property (nonatomic, nullable) id shader;

@end

#pragma mark - SKTransformNode

// Like SKCameraNode, carries no own archived state; only _originalClass differs.
@interface SKTransformNode : SKNode
@end

#pragma mark - SKVideoNode

// Own fields (spy order): _videoFileName (obj), _videoFileURL (obj),
// _bounds (NSValue rectval, defaults to CGRectZero).
@interface SKVideoNode : SKNode
@property (nonatomic, copy, nullable) NSString *videoFileName;
@property (nonatomic, copy, nullable) NSURL *videoFileURL;
@property (nonatomic) CGRect bounds;
+ (instancetype)videoNodeWithFileNamed:(NSString *)name;
@end

#pragma mark - SKAudioNode

// Own fields (spy order): _autoplayLooped (bool, default YES), _audioName (obj),
// _audioURL (obj).
@interface SKAudioNode : SKNode
@property (nonatomic) BOOL autoplayLooped;
@property (nonatomic, copy, nullable) NSString *audioName;
@property (nonatomic, copy, nullable) NSURL *audioURL;
@end

#pragma mark - SKReferenceNode

// Own fields (spy order): _referenceURL (obj, nil), _referenceFileName
// (obj, defaults to the empty constant string).
@interface SKReferenceNode : SKNode
@property (nonatomic, copy, nullable) NSURL *referenceURL;
@property (nonatomic, copy, nullable) NSString *referenceFileName;
@end

NS_ASSUME_NONNULL_END