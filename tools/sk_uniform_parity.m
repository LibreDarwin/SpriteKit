// Copyright (C) 2026, LibreDarwin
// SPDX-License-Identifier: BSD-3-Clause

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
        fprintf(stderr, "FAIL %s parity: wrote %lu bytes, golden %lu bytes\n",
                label, (unsigned long)data.length, (unsigned long)golden.length);
        return 1;
    }
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc < 10) {
            fprintf(stderr, "usage: %s <none> <float> <v2> <v3> <v4> <m2> <m3> <m4> <tex>\n", argv[0]);
            return 2;
        }
        int r = 0;
        r |= check([SKUniform uniformWithName:@"u"], argv[1], "uni_none");
        r |= check([SKUniform uniformWithName:@"u" float:1.5f], argv[2], "uni_float");
        r |= check([SKUniform uniformWithName:@"u" vectorFloat2:(vector_float2){1,2}], argv[3], "uni_v2");
        r |= check([SKUniform uniformWithName:@"u" vectorFloat3:(vector_float3){1,2,3}], argv[4], "uni_v3");
        r |= check([SKUniform uniformWithName:@"u" vectorFloat4:(vector_float4){1,2,3,4}], argv[5], "uni_v4");
        r |= check([SKUniform uniformWithName:@"u" matrixFloat2x2:(matrix_float2x2){.columns={{1,2},{3,4}}}], argv[6], "uni_m2");
        r |= check([SKUniform uniformWithName:@"u" matrixFloat3x3:(matrix_float3x3){.columns={{1,2,3},{4,5,6},{7,8,9}}}], argv[7], "uni_m3");
        r |= check([SKUniform uniformWithName:@"u" matrixFloat4x4:(matrix_float4x4){.columns={{1,2,3,4},{5,6,7,8},{9,10,11,12},{13,14,15,16}}}], argv[8], "uni_m4");
        SKTexture *t = [[SKTexture alloc] init]; // may fail but archives
        r |= check([SKUniform uniformWithName:@"u" texture:t], argv[9], "uni_tex");
        if (r) return 1;
        printf("PASS all SKUniform parity\n");
        return 0;
    }
}
