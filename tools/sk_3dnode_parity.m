// Copyright (C) 2026, LibreDarwin
// SPDX-License-Identifier: BSD-3-Clause
//
// Byte-parity harness for the clean-room SK3DNode.
// Builds the node via -init and +nodeWithViewportSize: and asserts the
// archived bytes match Apple's goldens.

#import <Foundation/Foundation.h>
#import "SKNode.h"

static int check(id obj, const char *path, const char *label) {
    @autoreleasepool {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
        NSData *golden = [NSData dataWithContentsOfFile:[NSString stringWithUTF8String:path]];
        if (!golden) {
            fprintf(stderr, "cannot read golden: %s\n", path);
            return 2;
        }
        if ([data isEqualToData:golden]) {
            printf("PASS %s (%lu bytes)\n", label, (unsigned long)data.length);
            return 0;
        }
        fprintf(stderr, "FAIL %s: wrote %lu bytes, golden %lu bytes\n",
                label, (unsigned long)data.length, (unsigned long)golden.length);
        NSUInteger n = MIN(data.length, golden.length);
        const uint8_t *a = data.bytes, *b = golden.bytes;
        for (NSUInteger i = 0; i < n; i++)
            if (a[i] != b[i]) { fprintf(stderr, "first difference at byte %lu: 0x%02x != 0x%02x\n", (unsigned long)i, a[i], b[i]); break; }
        return 1;
    }
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc < 3) { fprintf(stderr, "usage: %s <init-golden> <vp-golden>\n", argv[0]); return 2; }

        SK3DNode *a = [[SK3DNode alloc] init];
        a.name = @"d3";

        SK3DNode *b = [SK3DNode nodeWithViewportSize:CGSizeMake(100, 200)];
        b.name = @"d3vp";

        int r = 0;
        r |= check(a, argv[1], "SK3DNode init");
        r |= check(b, argv[2], "SK3DNode viewportSize");
        return r;
    }
}
