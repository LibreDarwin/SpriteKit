// Copyright (C) 2026, LibreDarwin
// SPDX-License-Identifier: BSD-3-Clause

#import <Foundation/Foundation.h>
#import "SKNode.h"

static int check(id obj, const char *path, const char *label) {
    @autoreleasepool {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
        NSData *golden = [NSData dataWithContentsOfFile:[NSString stringWithUTF8String:path]];
        if (!golden) { fprintf(stderr, "cannot read golden: %s\n", path); return 2; }
        if ([data isEqualToData:golden]) { printf("PASS %s (%lu bytes)\n", label, (unsigned long)data.length); return 0; }
        fprintf(stderr, "FAIL %s\n", label); return 1;
    }
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc < 2) return 2;
        SKUniform *uf = [SKUniform uniformWithName:@"u" float:2.5f];
        SKShader *sh = [SKShader shaderWithString:@"void main(){}"];
        sh.uniforms = @[uf];
        return check(sh, argv[1], "shader_mix") == 0 ? 0 : 1;
    }
}
