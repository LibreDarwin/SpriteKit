// Copyright (C) 2026, LibreDarwin
// SPDX-License-Identifier: BSD-3-Clause
//
// Byte-parity harness for the clean-room SKFieldNode concrete subclasses.
// Builds each field node through the public +[SKFieldNode ...] factories and
// asserts the archived bytes match Apple's goldens.

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
        return 1;
    }
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc < 13) {
            fprintf(stderr, "usage: %s <drag> <vortex> <radial> <linear> <velocity_v> "
                            "<velocity_t> <noise> <turbulence> <spring> <electric> "
                            "<magnetic> <custom>\n", argv[0]);
            return 2;
        }
        int r = 0;
        r |= check([SKFieldNode dragField], argv[1], "field_drag");
        r |= check([SKFieldNode vortexField], argv[2], "field_vortex");
        r |= check([SKFieldNode radialGravityField], argv[3], "field_radial");
        r |= check([SKFieldNode linearGravityFieldWithVector:simd_make_float3(1, 2, 3)],
                   argv[4], "field_linear");
        r |= check([SKFieldNode velocityFieldWithVector:simd_make_float3(1, 2, 3)],
                   argv[5], "field_velocity_v");
        r |= check([SKFieldNode velocityFieldWithTexture:[[SKTexture alloc] init]],
                   argv[6], "field_velocity_t");
        r |= check([SKFieldNode noiseFieldWithSmoothness:0.5 animationSpeed:0.25],
                   argv[7], "field_noise");
        r |= check([SKFieldNode turbulenceFieldWithSmoothness:0.5 animationSpeed:0.25],
                   argv[8], "field_turbulence");
        r |= check([SKFieldNode springField], argv[9], "field_spring");
        r |= check([SKFieldNode electricField], argv[10], "field_electric");
        r |= check([SKFieldNode magneticField], argv[11], "field_magnetic");
        r |= check([SKFieldNode customFieldWithEvaluationBlock:^vector_float3(
                        vector_float3 pos, vector_float3 vel, float mass, float charge,
                        NSTimeInterval dt) {
                        (void)pos; (void)vel; (void)mass; (void)charge; (void)dt;
                        return simd_make_float3(0, 0, 0);
                    }],
                   argv[12], "field_custom");
        if (r) return 1;
        printf("PASS all SKFieldNode subclass parity\n");
        return 0;
    }
}
