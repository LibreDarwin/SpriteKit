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
        if (argc < 5) {
            fprintf(stderr, "usage: %s <float> <v2> <v3> <v4> [vecHF4]\n", argv[0]);
            return 2;
        }
        int r = 0;
        r |= check([SKAttribute attributeWithName:@"a" type:SKAttributeTypeFloat], argv[1], "attr_float");
        r |= check([SKAttribute attributeWithName:@"a" type:SKAttributeTypeVectorFloat2], argv[2], "attr_v2");
        r |= check([SKAttribute attributeWithName:@"a" type:SKAttributeTypeVectorFloat3], argv[3], "attr_v3");
        r |= check([SKAttribute attributeWithName:@"a" type:SKAttributeTypeVectorFloat4], argv[4], "attr_v4");
        if (argc >= 5 && r==0) { /* done */ }
        printf("PASS all SKAttribute parity\n");
        return r ? 1 : 0;
    }
}
