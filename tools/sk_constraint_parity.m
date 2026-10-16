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
        if (argc < 8) {
            fprintf(stderr, "usage: %s <rotation> <distance_point> <distance_node> "
                            "<orient_point> <orient_node> <scale> <size>\n", argv[0]);
            return 2;
        }
        int r = 0;
        SKRange *five = [SKRange rangeWithConstantValue:5];
        r |= check([SKConstraint zRotation:five], argv[1], "constraint_rotation");
        r |= check([SKConstraint distance:five toPoint:CGPointMake(3, 4)], argv[2],
                   "constraint_distance_point");
        r |= check([SKConstraint distance:five toNode:[SKNode node]], argv[3],
                   "constraint_distance_node");
        r |= check([SKConstraint orientToPoint:CGPointMake(3, 4) offset:five], argv[4],
                   "constraint_orient_point");
        r |= check([SKConstraint orientToNode:[SKNode node] offset:five], argv[5],
                   "constraint_orient_node");
        SKScaleConstraint *sc = [[SKScaleConstraint alloc] init];
        sc.xRange = [SKRange rangeWithConstantValue:1];
        sc.yRange = [SKRange rangeWithConstantValue:2];
        r |= check(sc, argv[6], "constraint_scale");
        SKSizeConstraint *sz = [[SKSizeConstraint alloc] init];
        sz.widthRange = [SKRange rangeWithConstantValue:1];
        sz.heightRange = [SKRange rangeWithConstantValue:2];
        r |= check(sz, argv[7], "constraint_size");
        if (r) return 1;
        printf("PASS all SKConstraint subclass parity\n");
        return 0;
    }
}
