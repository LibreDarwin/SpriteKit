// Copyright (C) 2026, LibreDarwin
// SPDX-License-Identifier: BSD-3-Clause
//
// Byte-parity harness for the clean-room SKShapeNode.

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "SKNode.h"

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc < 2) { fprintf(stderr, "usage: %s <golden.skeep>\n", argv[0]); return 2; }
        SKShapeNode *dot = [SKShapeNode shapeNodeWithCircleOfRadius:10];
        dot.name = @"dot";
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dot];
        NSData *golden = [NSData dataWithContentsOfFile:[NSString stringWithUTF8String:argv[1]]];
        if (!golden) { fprintf(stderr, "cannot read golden: %s\n", argv[1]); return 2; }
        if ([data isEqualToData:golden]) {
            printf("PASS SKShapeNode parity (%lu bytes)\n", (unsigned long)data.length);
            return 0;
        }
        fprintf(stderr, "FAIL SKShapeNode parity: wrote %lu bytes, golden %lu bytes\n",
                (unsigned long)data.length, (unsigned long)golden.length);
        NSUInteger n = MIN(data.length, golden.length);
        const uint8_t *a = data.bytes, *b = golden.bytes;
        for (NSUInteger i = 0; i < n; i++)
            if (a[i] != b[i]) { fprintf(stderr, "first difference at byte %lu: 0x%02x != 0x%02x\n", (unsigned long)i, a[i], b[i]); break; }
        [data writeToFile:@"/tmp/our_shape.skeep" atomically:YES];
        return 1;
    }
}
