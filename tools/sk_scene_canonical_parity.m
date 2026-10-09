// Copyright (C) 2026, LibreDarwin
// SPDX-License-Identifier: BSD-3-Clause
//
// Byte-parity harness for the clean-room canonical .sks scene: an SKScene with
// a color sprite and a text label.  This is the init+encode form the runtime
// writer emits (the decode->re-encode fixpoint differs by 9 B, so this is the
// canonical target).  Mirrors tools/conformance/SpriteKit/oracle_scene_canonical.skeep.

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "SKNode.h"

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc < 2) { fprintf(stderr, "usage: %s <golden.skeep>\n", argv[0]); return 2; }

        SKScene *scene = [SKScene sceneWithSize:CGSizeMake(320, 240)];
        scene.backgroundColor = [NSColor blueColor];

        SKSpriteNode *sq = [SKSpriteNode spriteNodeWithColor:[NSColor redColor]
                                                        size:CGSizeMake(64, 48)];
        sq.position = CGPointMake(100, 90);
        sq.zRotation = 0.25;

        SKLabelNode *caption = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        caption.text = @"ok";
        caption.fontSize = 24;
        caption.position = CGPointMake(160, 120);

        [scene addChild:sq];
        [scene addChild:caption];

        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:scene];
        NSData *golden = [NSData dataWithContentsOfFile:[NSString stringWithUTF8String:argv[1]]];
        if (!golden) { fprintf(stderr, "cannot read golden: %s\n", argv[1]); return 2; }

        if ([data isEqualToData:golden]) {
            printf("PASS SKScene canonical parity (%lu bytes)\n", (unsigned long)data.length);
            return 0;
        }

        fprintf(stderr, "FAIL SKScene canonical parity: wrote %lu bytes, golden %lu bytes\n",
                (unsigned long)data.length, (unsigned long)golden.length);
        NSUInteger n = MIN(data.length, golden.length);
        const uint8_t *a = data.bytes, *b = golden.bytes;
        for (NSUInteger i = 0; i < n; i++) {
            if (a[i] != b[i]) {
                fprintf(stderr, "first difference at byte %lu: 0x%02x != 0x%02x\n",
                        (unsigned long)i, a[i], b[i]);
                break;
            }
        }
        [data writeToFile:@"/tmp/our_scene_canonical.skeep" atomically:YES];
        return 1;
    }
}
