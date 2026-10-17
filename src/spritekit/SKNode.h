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
#import <simd/simd.h>

#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#define SK_NODE_SUPERCLASS NSResponder
#else
#define SK_NODE_SUPERCLASS NSObject
#endif

NS_ASSUME_NONNULL_BEGIN

@class SKAttributeValue;
@class SKTexture;
@class SCNScene;
@class SCNNode;

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
- (void)setValue:(nullable SKAttributeValue *)value forAttributeNamed:(nonnull NSString *)name;
- (nullable SKAttributeValue *)valueForAttributeNamed:(nonnull NSString *)name;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, SKAttributeValue *> *attributeValues;
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

#pragma mark - SK3DNode

// Own fields (emit order): viewportSize (encodeSize:, default "{1, 1}"),
// _scene (obj, holds the SCNScene, nil by default).  Note the SCNScene is
// archived under the key "_scene" (the base SKNode does not encode "_scene").
// sceneTime/loops/playing/autoenablesDefaultLighting/pointOfView are NOT
// archived.
@interface SK3DNode : SKNode
@property (nonatomic) CGSize viewportSize;
@property (nonatomic, strong, nullable) SCNScene *scnScene;
@property (nonatomic) NSTimeInterval sceneTime;
@property (nonatomic) BOOL loops;
@property (nonatomic, getter=isPlaying) BOOL playing;
@property (nonatomic) BOOL autoenablesDefaultLighting;
@property (nonatomic, strong, nullable) SCNNode *pointOfView;
- (instancetype)initWithViewportSize:(CGSize)viewportSize;
+ (instancetype)nodeWithViewportSize:(CGSize)viewportSize;
@end

#pragma mark - SKLightNode

// Own fields (spy order): enabled (bool, default YES), lightDecay (double, 1),
// lightColor RGBA (1,1,1,1), ambientColor RGBA (0,0,0,1), shadowColor RGBA
// (0,0,0,0.5), lightCategoryBitMask (int32, 1).  The color components are keyed
// "<name>.redComponent"/".greenComponent"/".blueComponent"/".alphaComponent".
@interface SKLightNode : SKNode
@property (nonatomic) BOOL enabled;
@property (nonatomic) double lightDecay;
@property (nonatomic) double lightColorR;
@property (nonatomic) double lightColorG;
@property (nonatomic) double lightColorB;
@property (nonatomic) double lightColorA;
@property (nonatomic) double ambientColorR;
@property (nonatomic) double ambientColorG;
@property (nonatomic) double ambientColorB;
@property (nonatomic) double ambientColorA;
@property (nonatomic) double shadowColorR;
@property (nonatomic) double shadowColorG;
@property (nonatomic) double shadowColorB;
@property (nonatomic) double shadowColorA;
@property (nonatomic) int32_t lightCategoryBitMask;
@end

#pragma mark - SKFieldNode

// Own fields (spy order): _strength (float, 0), _falloff (float, 0),
// _minimumRadius (float, 2^-15 = 3.0517578125e-05), _active (bool, NO),
// _exclusive (bool, NO), _categoryBitMask (int32, 0), _direction (obj, a
// 12-byte NSMutableData holding three zero floats), _smoothness (float, 0),
// _animationSpeed (float, 0).
@interface SKFieldNode : SKNode
@property (nonatomic) float strength;
@property (nonatomic) float falloff;
@property (nonatomic) float minimumRadius;
@property (nonatomic) BOOL active;
@property (nonatomic) BOOL exclusive;
@property (nonatomic) int32_t categoryBitMask;
@property (nonatomic) float smoothness;
@property (nonatomic) float animationSpeed;
- (void)setDirectionX:(float)x y:(float)y z:(float)z;

+ (SKFieldNode *)dragField;
+ (SKFieldNode *)vortexField;
+ (SKFieldNode *)radialGravityField;
+ (SKFieldNode *)linearGravityFieldWithVector:(vector_float3)direction;
+ (SKFieldNode *)velocityFieldWithVector:(vector_float3)direction;
+ (SKFieldNode *)velocityFieldWithTexture:(SKTexture *)velocityTexture;
+ (SKFieldNode *)noiseFieldWithSmoothness:(CGFloat)smoothness animationSpeed:(CGFloat)speed;
+ (SKFieldNode *)turbulenceFieldWithSmoothness:(CGFloat)smoothness animationSpeed:(CGFloat)speed;
+ (SKFieldNode *)springField;
+ (SKFieldNode *)electricField;
+ (SKFieldNode *)magneticField;
typedef vector_float3 (^SKFieldForceEvaluator)(vector_float3 position, vector_float3 velocity,
                                               float mass, float charge, NSTimeInterval deltaTime);
+ (SKFieldNode *)customFieldWithEvaluationBlock:(SKFieldForceEvaluator)block;
@end

// Concrete field nodes.  Each subclass adds NO fields of its own to the
// archive; the only difference from the base is the archived class name (and
// the class chain, e.g. SKTurbulenceFieldNode <- SKNoiseFieldNode).  Each
// subclass -init installs the same non-default field values Apple uses
// (strength 1, active YES, categoryBitMask 0xFFFFFFFF, minimumRadius
// 0.00457763671875) plus a per-type falloff / direction / smoothness:
//   drag/vortex/noise/turbulence/custom falloff 0; radial 2; spring -1;
//   electric/magnetic 1.  linearGravity default direction (0,1,0); velocity
//   default direction (FLT_MAX,FLT_MAX,FLT_MAX); noise default smoothness 0.5.
@interface SKDragFieldNode : SKFieldNode @end
@interface SKVortexFieldNode : SKFieldNode @end
@interface SKRadialGravityFieldNode : SKFieldNode @end
@interface SKLinearGravityFieldNode : SKFieldNode @end
@interface SKVelocityFieldNode : SKFieldNode
@property (nonatomic, strong, nullable) SKTexture *velocityTexture;
@end
@interface SKNoiseFieldNode : SKFieldNode @end
@interface SKTurbulenceFieldNode : SKNoiseFieldNode @end
@interface SKSpringFieldNode : SKFieldNode @end
@interface SKElectricFieldNode : SKFieldNode @end
@interface SKMagneticFieldNode : SKFieldNode @end
@interface SKCustomFieldNode : SKFieldNode
@property (nonatomic, copy, nullable) SKFieldForceEvaluator evaluationBlock;
@end

#pragma mark - SKWarpGeometry / SKWarpGeometryGrid

// Abstract base of the warp-geometry cluster.  Root NSObject subclass (class
// chain SKWarpGeometry <- NSObject); encode contributes no fields of its own.
// SKWarpGeometryGrid adds (spy order, all encodeInteger for the scalars):
// _SKWarpGeometryGridVersion (1), _numberOfColumns, _numberOfRows, then
// _sourcePositions, _destPositions (encodeObject).  Positions are arrays of
// two float64 NSValues -- the archive stores each as [x, y] NSArray of float32
// NSNumber elements (a GridConfiguration boxed as an array).
@interface SKWarpGeometry : NSObject
@property (nonatomic, readonly) NSInteger gridColumns;
@property (nonatomic, readonly) NSInteger gridRows;
- (nullable NSArray<NSArray<NSNumber *> *> *)sourcePositions;
- (nullable NSArray<NSArray<NSNumber *> *> *)destPositions;
@end

@interface SKWarpGeometryGrid : SKWarpGeometry
+ (instancetype)gridWithColumns:(NSInteger)cols rows:(NSInteger)rows;
@end

#pragma mark - SKShader

// Root NSObject subclass.  Own fields (spy order): _isCapture (bool, NO),
// _uniforms (obj, default empty NSArray), _source (obj, default @""),
// _fileName (obj, nil), _attributes (obj, nil).
@interface SKShader : NSObject
+ (instancetype)shader;
+ (instancetype)shaderWithString:(NSString *)source;
@property (nonatomic, copy, nullable) NSString *source;
@property (nonatomic, copy, nullable) NSString *fileName;
@property (nonatomic, copy, nullable) NSArray<id> *uniforms;
@end

#pragma mark - SKAttributeValue

// Root NSObject subclass.  Own fields (spy order): _type (obj, NSNumber,
// always 0 for the float/vector constructors), _floatValues0..3 (floats).
@interface SKAttributeValue : NSObject
+ (instancetype)valueWithFloat:(float)value;
+ (instancetype)valueWithVectorFloat4:(vector_float4)value;
@property (nonatomic) float floatValue;
@property (nonatomic) vector_float4 vectorFloat4Value;
@end

#pragma mark - SKUniform

typedef NS_ENUM(NSInteger, SKUniformType) {
    SKUniformTypeNone         = 0,
    SKUniformTypeFloat        = 1,
    SKUniformTypeFloatVector2 = 2,
    SKUniformTypeFloatVector3 = 3,
    SKUniformTypeFloatVector4 = 4,
    SKUniformTypeFloatMatrix2 = 5,
    SKUniformTypeFloatMatrix3 = 6,
    SKUniformTypeFloatMatrix4 = 7,
    SKUniformTypeTexture      = 8,
};

// Root NSObject subclass.  Encode order (from Apple golden): _name (obj),
// _type (inline int32), then exactly one value key selected by type:
//   Float        _floatValue          (inline float, 4-byte real)
//   FloatVectorN _floatVectorNValue   (immutable NSArray of float NSNumbers)
//   FloatMatrixN _floatMatrixNValue   (MUTABLE NSMutableArray of float NSNumber,
//                                      column-major) -- Apple quirk: vectors are
//                                      NSArray, matrices are NSMutableArray.
//   Texture      _textureValue        (SKTexture)
@interface SKUniform : NSObject <NSCoding, NSCopying>
+ (instancetype)uniformWithName:(NSString *)name;
+ (instancetype)uniformWithName:(NSString *)name float:(float)value;
+ (instancetype)uniformWithName:(NSString *)name vectorFloat2:(vector_float2)value;
+ (instancetype)uniformWithName:(NSString *)name vectorFloat3:(vector_float3)value;
+ (instancetype)uniformWithName:(NSString *)name vectorFloat4:(vector_float4)value;
+ (instancetype)uniformWithName:(NSString *)name matrixFloat2x2:(matrix_float2x2)value;
+ (instancetype)uniformWithName:(NSString *)name matrixFloat3x3:(matrix_float3x3)value;
+ (instancetype)uniformWithName:(NSString *)name matrixFloat4x4:(matrix_float4x4)value;
+ (instancetype)uniformWithName:(NSString *)name texture:(nullable SKTexture *)value;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly) SKUniformType uniformType;
@property (nonatomic) float floatValue;
@property (nonatomic) vector_float2 vectorFloat2Value;
@property (nonatomic) vector_float3 vectorFloat3Value;
@property (nonatomic) vector_float4 vectorFloat4Value;
@property (nonatomic) matrix_float2x2 matrixFloat2x2Value;
@property (nonatomic) matrix_float3x3 matrixFloat3x3Value;
@property (nonatomic) matrix_float4x4 matrixFloat4x4Value;
@property (nonatomic, retain, nullable) SKTexture *textureValue;
@end

#pragma mark - SKAttribute

typedef NS_ENUM(NSInteger, SKAttributeType) {
    SKAttributeTypeNone             = 0,
    SKAttributeTypeFloat            = 1,
    SKAttributeTypeVectorFloat2     = 2,
    SKAttributeTypeVectorFloat3     = 3,
    SKAttributeTypeVectorFloat4     = 4,
    SKAttributeTypeHalfFloat        = 5,
    SKAttributeTypeVectorHalfFloat2 = 6,
    SKAttributeTypeVectorHalfFloat3 = 7,
    SKAttributeTypeVectorHalfFloat4 = 8,
};

// Root NSObject subclass.  Encode order (from Apple golden): _name (obj),
// _type (obj, NSNumber -- note: unlike SKUniform, the type is an object).
@interface SKAttribute : NSObject <NSCoding, NSCopying>
+ (instancetype)attributeWithName:(NSString *)name type:(SKAttributeType)type;
- (instancetype)initWithName:(NSString *)name type:(SKAttributeType)type;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly) SKAttributeType type;
@end

#pragma mark - SKTexture

// Root NSObject subclass.  Spy order: _originalAtlasName (nil),
// _subTextureName (nil), _isPath (bool, NO), _isCapture (bool, NO),
// _isData (bool, YES), _imageData (obj, TIFF NSData), _imgName (nil),
// _disableAlpha (bool, NO), _size (NSValue size), _pixelSize (NSValue size),
// _textRect (NSValue rect), _cropOffset (NSValue point), _cropScale (NSValue
// point), _isRotated (bool, NO), _isFlipped (bool, NO), _filteringMode
// (encodeInteger, 1).
@interface SKTexture : NSObject
+ (instancetype)textureWithImage:(NSImage *)image;
@property (nonatomic, readonly) CGSize size;
@end

// SKMutableTexture encodes the same 16 fields as SKTexture; the only difference
// is that _imageData is a TIFF synthesized from the (initially zeroed) RGBA
// bitmap of the requested size.
@interface SKMutableTexture : SKTexture
- (instancetype)SK_textureWithSize:(CGSize)size;
- (instancetype)initWithSize:(CGSize)size;
@end

// Root NSObject subclass.  Spy order (empty atlas): _atlasName (obj, nil),
// _textureDict (obj, nil).  _isCUIImageAtlas is not encoded.
@interface SKTextureAtlas : NSObject
+ (instancetype)atlasNamed:(NSString *)name;
- (SKTexture *)textureNamed:(NSString *)name;
@property (nonatomic, readonly) NSArray<NSString *> *textureNames;
@end

#pragma mark - SKRange

// Root NSObject subclass.  Spy order: _lowerLimit (double), _upperLimit
// (double).
@interface SKRange : NSObject
+ (instancetype)rangeWithConstantValue:(double)value;
+ (instancetype)rangeWithLowerLimit:(double)lower upperLimit:(double)upper;
+ (instancetype)rangeWithValue:(double)value variance:(double)variance;
@property (nonatomic) double lowerLimit;
@property (nonatomic) double upperLimit;
@end

#pragma mark - SKKeyframeSequence

// Root NSObject subclass.  Spy order: _interpolationMode (encodeInteger),
// _repeatMode (encodeInteger), _values (obj, NSMutableArray), _times (obj,
// NSMutableArray).
@interface SKKeyframeSequence : NSObject
- (instancetype)initWithKeyframeValues:(NSArray *)values times:(NSArray *)times;
- (void)addKeyframeValue:(id)value time:(double)time;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic) NSInteger interpolationMode;
@property (nonatomic) NSInteger repeatMode;
@end

#pragma mark - SKConstraint

// Root NSObject subclass.  Spy order: _enabled (bool, YES), _referenceNode
// (obj, nil).  Concrete constraints (e.g. SKPositionConstraint) append their
// own fields; the archived class chain is the full runtime hierarchy.
@interface SKConstraint : NSObject
+ (instancetype)positionX:(SKRange *)xRange;
+ (instancetype)positionX:(SKRange *)xRange Y:(SKRange *)yRange;
+ (instancetype)distance:(SKRange *)range toNode:(SKNode *)node;
+ (instancetype)distance:(SKRange *)range toPoint:(CGPoint)point;
+ (instancetype)distance:(SKRange *)range toPoint:(CGPoint)point inNode:(SKNode *)node;
+ (instancetype)zRotation:(SKRange *)zRange;
+ (instancetype)orientToNode:(SKNode *)node offset:(SKRange *)radians;
+ (instancetype)orientToPoint:(CGPoint)point offset:(SKRange *)radians;
+ (instancetype)orientToPoint:(CGPoint)point inNode:(SKNode *)node offset:(SKRange *)radians;
@property (nonatomic) BOOL enabled;
@end

@interface SKPositionConstraint : SKConstraint
@property (nonatomic, copy, nullable) SKRange *xRange;
@property (nonatomic, copy, nullable) SKRange *yRange;
@end

// SKConstraint subclass.  Ivar order: base (_enabled bool, _referenceNode obj)
// then _distanceRange (SKRange), _point (CGPoint), _node (SKNode).  Encode
// order is base, then _node (nil -> $null), then _distanceRange, then _point
// (encodePoint: -> geometry string).
@interface SKDistanceConstraint : SKConstraint
@property (nonatomic, copy, nullable) SKRange *distanceRange;
@property (nonatomic) CGPoint point;
@property (nonatomic, strong, nullable) SKNode *node;
@end

// SKConstraint subclass.  Spy order: base then _zRotationRange (SKRange).
@interface SKRotationConstraint : SKConstraint
@property (nonatomic, copy, nullable) SKRange *zRotationRange;
@end

// SKConstraint subclass.  Ivar order: base then _offset (SKRange), _point
// (CGPoint), _node (SKNode).  Encode order is base, then _node, then _offset,
// then _point (encodePoint:).
@interface SKOrientationConstraint : SKConstraint
@property (nonatomic, copy, nullable) SKRange *offset;
@property (nonatomic) CGPoint point;
@property (nonatomic, strong, nullable) SKNode *node;
@end

// SKConstraint subclass.  Spy order: base then _xRange, _yRange (SKRange).
@interface SKScaleConstraint : SKConstraint
@property (nonatomic, copy, nullable) SKRange *xRange;
@property (nonatomic, copy, nullable) SKRange *yRange;
@end

// SKConstraint subclass.  Spy order: base then _widthRange, _heightRange
// (SKRange).
@interface SKSizeConstraint : SKConstraint
@property (nonatomic, copy, nullable) SKRange *widthRange;
@property (nonatomic, copy, nullable) SKRange *heightRange;
@end

#pragma mark - Physics joints and reach constraints

@interface SKReachConstraints : NSObject <NSCoding>
@property (nonatomic) double lowerAngleLimit;
@property (nonatomic) double upperAngleLimit;
- (instancetype)initWithLowerAngleLimit:(double)lower upperAngleLimit:(double)upper;
@end

@interface PKPhysicsJoint : NSObject <NSCoding>
@property (nonatomic, strong) PKPhysicsBody *bodyA;
@property (nonatomic, strong) PKPhysicsBody *bodyB;
@property (nonatomic, strong) NSNumber *implicit;
@end

@interface PKPhysicsJointRevolute : PKPhysicsJoint
@property (nonatomic, copy) NSString *anchor;
@property (nonatomic) BOOL enableLimits;
@property (nonatomic) double lowerAngleLimit;
@property (nonatomic) double upperAngleLimit;
@property (nonatomic) double frictionTorque;
@end

@interface PKPhysicsJointWeld : PKPhysicsJoint
@property (nonatomic, copy) NSString *anchor;
@end

@interface PKPhysicsJointDistance : PKPhysicsJoint
@property (nonatomic, copy) NSString *anchorA;
@property (nonatomic, copy) NSString *anchorB;
@property (nonatomic) double damping;
@property (nonatomic) double frequency;
@end

@interface PKPhysicsJointPrismatic : PKPhysicsJoint
@property (nonatomic, copy) NSString *anchor;
@property (nonatomic, copy) NSString *axis;
@property (nonatomic) BOOL enableLimits;
@property (nonatomic) double lowerDistanceLimit;
@property (nonatomic) double upperDistanceLimit;
@end

@interface PKPhysicsJointRope : PKPhysicsJoint
@property (nonatomic, copy) NSString *anchorA;
@property (nonatomic, copy) NSString *anchorB;
@property (nonatomic) double maxLength;
@end

@interface SKPhysicsJointPin : PKPhysicsJointRevolute
+ (instancetype)jointWithBodyA:(PKPhysicsBody *)bodyA bodyB:(PKPhysicsBody *)bodyB anchor:(CGPoint)anchor;
@end
@interface SKPhysicsJointFixed : PKPhysicsJointWeld
+ (instancetype)jointWithBodyA:(PKPhysicsBody *)bodyA bodyB:(PKPhysicsBody *)bodyB anchor:(CGPoint)anchor;
@end
@interface SKPhysicsJointSpring : PKPhysicsJointDistance
+ (instancetype)jointWithBodyA:(PKPhysicsBody *)bodyA bodyB:(PKPhysicsBody *)bodyB anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB;
@end
@interface SKPhysicsJointSliding : PKPhysicsJointPrismatic
+ (instancetype)jointWithBodyA:(PKPhysicsBody *)bodyA bodyB:(PKPhysicsBody *)bodyB anchor:(CGPoint)anchor axis:(CGVector)axis;
@end
@interface SKPhysicsJointLimit : PKPhysicsJointRope
+ (instancetype)jointWithBodyA:(PKPhysicsBody *)bodyA bodyB:(PKPhysicsBody *)bodyB anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB;
@end

NS_ASSUME_NONNULL_END