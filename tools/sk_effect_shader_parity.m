// Copyright (C) 2026, LibreDarwin
// SPDX-License-Identifier: BSD-3-Clause
//
// Byte-parity harness for a clean-room SKEffectNode carrying a shader,
// exercising the nested SKShader archive.

#import <Foundation/Foundation.h>
#import "SKNode.h"

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            fprintf(stderr, "usage: %s <golden.skeep>\n", argv[0]);
            return 2;
        }
        SKEffectNode *efx = [SKEffectNode node];
        efx.shader = [SKShader shader];
        efx.name = @"efx";

        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:efx];
        NSData *golden = [NSData dataWithContentsOfFile:[NSString stringWithUTF8String:argv[1]]];
        if (!golden) {
            fprintf(stderr, "cannot read golden: %s\n", argv[1]);
            return 2;
        }
        if ([data isEqualToData:golden]) {
            printf("PASS SKEffectNode(shader) parity (%lu bytes)\n", (unsigned long)data.length);
            return 0;
        }
        fprintf(stderr, "FAIL SKEffectNode(shader) parity: wrote %lu bytes, golden %lu bytes\n",
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
        return 1;
    }
}