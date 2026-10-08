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
    }
    return 0;
}