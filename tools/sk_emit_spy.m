// Copyright (C) 2026, LibreDarwin
// SPDX-License-Identifier: BSD-3-Clause
//
// Emit-order spy: passes a fake NSCoder to Apple's real encodeWithCoder:
// implementations so the exact keyed-encode *call order* (and encoding flavour)
// is captured from the implementation itself rather than guessed from
// disassembly.  Development aid only; not built by the default target.
//
//     $CLANG tools/sk_emit_spy.m -framework SpriteKit -framework Foundation \
//            -o build/release/sk_emit_spy && ./build/release/sk_emit_spy

#import <SpriteKit/SpriteKit.h>
#import <objc/runtime.h>

@interface SpyCoder : NSCoder
@property (nonatomic, strong) NSMutableArray<NSString *> *log;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, strong) NSMutableArray<id> *captured;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *byKey;
@end

@implementation SpyCoder

- (instancetype)init {
    self = [super init];
    if (self) {
        _log = [NSMutableArray array];
        _captured = [NSMutableArray array];
        _byKey = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)allowsKeyedCoding { return YES; }

- (void)rec:(NSString *)op forKey:(NSString *)key {
    [self.log addObject:[NSString stringWithFormat:@"%@  %@", key ?: @"?", op]];
}

- (void)encodeObject:(id)obj forKey:(NSString *)key {
    [self rec:[NSString stringWithFormat:@"obj(%@)",
                     obj ? NSStringFromClass([obj class]) : @"nil"] forKey:key];
    if (obj) { [self.captured addObject:obj]; if (key) self.byKey[key] = obj; }
}
- (void)encodeConditionalObject:(id)obj forKey:(NSString *)key {
    [self rec:@"condobj" forKey:key];
}
- (void)encodeBool:(BOOL)v forKey:(NSString *)key {
    [self rec:[NSString stringWithFormat:@"bool(%d)", v ? 1 : 0] forKey:key];
}
- (void)encodeInt:(int)v forKey:(NSString *)key {
    [self rec:[NSString stringWithFormat:@"int(%d)", v] forKey:key];
}
- (void)encodeInt32:(int32_t)v forKey:(NSString *)key {
    [self rec:[NSString stringWithFormat:@"int32(%d)", v] forKey:key];
}
- (void)encodeInt64:(int64_t)v forKey:(NSString *)key {
    [self rec:[NSString stringWithFormat:@"int64(%lld)", v] forKey:key];
}
- (void)encodeInteger:(NSInteger)v forKey:(NSString *)key {
    [self rec:[NSString stringWithFormat:@"integer(%ld)", (long)v] forKey:key];
}
- (void)encodeFloat:(float)v forKey:(NSString *)key {
    [self rec:[NSString stringWithFormat:@"float(%g)", v] forKey:key];
}
- (void)encodeDouble:(double)v forKey:(NSString *)key {
    [self rec:[NSString stringWithFormat:@"double(%.17g)", v] forKey:key];
}
- (void)encodeBytes:(const uint8_t *)b length:(NSUInteger)len forKey:(NSString *)key {
    [self rec:[NSString stringWithFormat:@"bytes(%lu)", (unsigned long)len] forKey:key];
}

@end

static void dump(NSString *title, id obj) {
    SpyCoder *spy = [[SpyCoder alloc] init];
    spy.label = title;
    @try {
        [obj encodeWithCoder:spy];
    } @catch (NSException *e) {
        printf("  !! %s: %s\n", title.UTF8String, e.description.UTF8String);
        return;
    }
    printf("=== %s (%s) ===\n", title.UTF8String, obj ? class_getName([obj class]) : "nil");
    NSUInteger i = 0;
    for (NSString *line in spy.log) printf("  %2lu  %s\n", (unsigned long)i++, line.UTF8String);
}

int main(void) {
    @autoreleasepool {
        SKScene *scene = [SKScene sceneWithSize:CGSizeMake(320, 480)];
        scene.name = @"scene";

        dump(@"SKScene", scene);
        dump(@"PKPhysicsWorld(scene.physicsWorld)", scene.physicsWorld);

        SpyCoder *cap = [[SpyCoder alloc] init];
        [scene encodeWithCoder:cap];
        id pin = cap.byKey[@"_scenePinBody"];
        if (pin) dump(@"scenePinBody", pin);
        else printf("  (no PKPhysicsBody captured)\n");

        SKPhysicsBody *b = [SKPhysicsBody bodyWithCircleOfRadius:1];
        dump(@"SKPhysicsBody(circle r=1)", b);
        SKPhysicsWorld *w = [[SKPhysicsWorld alloc] init];
        dump(@"PKPhysicsWorld(new)", w);

        dump(@"SKCameraNode", [SKCameraNode node]);
        dump(@"SKCropNode", [SKCropNode node]);
        dump(@"SKEmitterNode", [SKEmitterNode node]);
        dump(@"SKFieldNode", [SKFieldNode node]);
        dump(@"SKLightNode", [SKLightNode node]);
        dump(@"SKAudioNode", [[SKAudioNode alloc] init]);
        dump(@"SKReferenceNode", [[SKReferenceNode alloc] init]);
        dump(@"SKVideoNode", [[SKVideoNode alloc] init]);
        dump(@"SKTransformNode", [SKTransformNode node]);
        dump(@"SKWarpGeometryGrid(2x2)", [SKWarpGeometryGrid gridWithColumns:2 rows:2]);
        SKSpriteNode *wps = [SKSpriteNode spriteNodeWithColor:[NSColor redColor] size:CGSizeMake(64, 64)];
        wps.warpGeometry = [SKWarpGeometryGrid gridWithColumns:2 rows:2];
        dump(@"SKSpriteNode(warp set)", wps);
        dump(@"SKShader(empty)", [SKShader shader]);
        SKEffectNode *efx = [SKEffectNode node];
        efx.shader = [SKShader shader];
        dump(@"SKEffectNode(shader set)", efx);
        dump(@"SKAttributeValue(float)", [SKAttributeValue valueWithFloat:3.5f]);
        dump(@"SKAttributeValue(vec2)", [SKAttributeValue valueWithVectorFloat2:(vector_float2){7,8}]);
        dump(@"SKAttributeValue(vec3)", [SKAttributeValue valueWithVectorFloat3:(vector_float3){9,10,11}]);
        dump(@"SKAttributeValue(vec4)", [SKAttributeValue valueWithVectorFloat4:(vector_float4){1,2,3,4}]);
        SKSpriteNode *attrs = [SKSpriteNode spriteNodeWithColor:[NSColor redColor] size:CGSizeMake(64, 64)];
        attrs.name = @"attrs";
        [attrs setValue:[SKAttributeValue valueWithFloat:3.5f] forAttributeNamed:@"glow"];
        dump(@"SKSpriteNode(attr float)", attrs);
        NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                          pixelsWide:1 pixelsHigh:1 bitsPerSample:8 samplesPerPixel:4
                          hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace
                          bytesPerRow:4 bitsPerPixel:32];
        uint8_t *pp = (uint8_t *)rep.bitmapData;
        pp[0] = 0x80; pp[1] = 0x80; pp[2] = 0x80; pp[3] = 0xFF;
        NSImage *timg = [[NSImage alloc] initWithSize:NSMakeSize(1, 1)];
        [timg addRepresentation:rep];
        dump(@"SKTexture(1x1 gray)", [SKTexture textureWithImage:timg]);
    }
    return 0;
}