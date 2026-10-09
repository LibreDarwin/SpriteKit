// Copyright (C) 2026, LibreDarwin
// SPDX-License-Identifier: BSD-3-Clause
//
// Oracle recorder: links the REAL Apple SpriteKit and archives a handful of
// minimal node objects, so the clean-room writer (src/spritekit) can be diffed
// byte-for-byte against Apple's output.  This produces the committed goldens in
// tools/conformance/SpriteKit/ (oracle_node.skeep, ...).
//
// It is a development aid only -- it is NOT part of the clean-room library and
// is not built by the default target.  Regenerate goldens with:
//
//     make oracle-spritekit
//
// Output lands in tools/conformance/SpriteKit/.

#import <SpriteKit/SpriteKit.h>

static void save(id obj, NSString *path) {
    NSData *d = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [d writeToFile:path atomically:NO];
    printf("%s: %lu bytes\n", path.UTF8String, (unsigned long)d.length);
}

int main(void) {
    @autoreleasepool {
        NSString *dir = @"tools/conformance/SpriteKit";

        SKNode *node = [SKNode node];
        node.name = @"root";
        node.position = CGPointMake(10, 20);
        node.zPosition = 5;
        save(node, [dir stringByAppendingPathComponent:@"oracle_node.skeep"]);

        SKSpriteNode *sp = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor]
                                                        size:CGSizeMake(32, 48)];
        sp.name = @"hero";
        sp.position = CGPointMake(1.5, 2.5);
        save(sp, [dir stringByAppendingPathComponent:@"oracle_sprite.skeep"]);

        SKLabelNode *lb = [SKLabelNode labelNodeWithText:@"Hi"];
        lb.name = @"lbl";
        save(lb, [dir stringByAppendingPathComponent:@"oracle_label.skeep"]);

        SKEffectNode *fx = (SKEffectNode *)[SKEffectNode node];
        fx.name = @"fx";
        save(fx, [dir stringByAppendingPathComponent:@"oracle_effect.skeep"]);

        SKShapeNode *shape = [SKShapeNode shapeNodeWithCircleOfRadius:10];
        shape.name = @"dot";
        save(shape, [dir stringByAppendingPathComponent:@"oracle_shape.skeep"]);

        SKScene *scene = [SKScene sceneWithSize:CGSizeMake(320, 480)];
        scene.name = @"scene";
        save(scene, [dir stringByAppendingPathComponent:@"oracle_scene.skeep"]);

        SKCameraNode *camera = [SKCameraNode node];
        camera.name = @"cam";
        save(camera, [dir stringByAppendingPathComponent:@"oracle_camera.skeep"]);

        SKCropNode *crop = [SKCropNode node];
        crop.name = @"crop";
        save(crop, [dir stringByAppendingPathComponent:@"oracle_crop.skeep"]);

        // Canonical .sks form: the init+encode graph the runtime writer emits
        // for a scene with content (the decode->re-encode fixpoint loses a
        // deduped object, so this is the target, not a round-trip).
        SKScene *full = [SKScene sceneWithSize:CGSizeMake(320, 240)];
        full.backgroundColor = [SKColor blueColor];
        SKSpriteNode *sq = [SKSpriteNode spriteNodeWithColor:[SKColor redColor]
                                                       size:CGSizeMake(64, 48)];
        sq.position = CGPointMake(100, 90);
        sq.zRotation = 0.25;
        SKLabelNode *caption = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        caption.text = @"ok";
        caption.fontSize = 24;
        caption.position = CGPointMake(160, 120);
        [full addChild:sq];
        [full addChild:caption];
        save(full, [dir stringByAppendingPathComponent:@"oracle_scene_canonical.skeep"]);
    }
    return 0;
}