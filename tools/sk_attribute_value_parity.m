// Copyright (C) 2026, LibreDarwin
// SPDX-License-Identifier: BSD-3-Clause
//
// Byte-parity harness for clean-room SKAttributeValue float and vec4 seeds.

#import <Foundation/Foundation.h>
#import "SKNode.h"

static int check(SKAttributeValue *v, const char *path, const char *label) {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:v];
    NSData *golden = [NSData dataWithContentsOfFile:[NSString stringWithUTF8String:path]];
    if (!golden) {
        fprintf(stderr, "cannot read golden: %s\n", path);
        return 2;
    }
    if ([data isEqualToData:golden]) {
        printf("PASS SKAttributeValue(%s) parity (%lu bytes)\n", label, (unsigned long)data.length);
        return 0;
    }
    fprintf(stderr, "FAIL SKAttributeValue(%s) parity: wrote %lu bytes, golden %lu bytes\n",
            label, (unsigned long)data.length, (unsigned long)golden.length);
    return 1;
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc < 3) {
            fprintf(stderr, "usage: %s <float.skeep> <vec4.skeep>\n", argv[0]);
            return 2;
        }
        int r1 = check([SKAttributeValue valueWithFloat:3.5f], argv[1], "float");
        int r2 = check([SKAttributeValue valueWithVectorFloat4:(vector_float4){1, 2, 3, 4}], argv[2], "vec4");
        return (r1 || r2) ? 1 : 0;
    }
}