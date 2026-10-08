/*
 * Copyright (C) 2026, LibreDarwin
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Conformance harness for the clean-room SKAction class cluster.  Rebuilds the
 * object graph stored in an Apple-recorded golden archive using only the public
 * SKAction factories, archives it with a stock NSKeyedArchiver, and asserts the
 * result is byte-identical to the golden.
 *
 * usage: sk_action_parity <golden.skeep>
 * exit:  0 byte-identical, 1 mismatch, 2 usage/IO error
 */

#import <Foundation/Foundation.h>
#import "SKAction.h"

static NSData *buildActionsArchive(void) {
    SKAction *mv = [SKAction moveTo:CGPointMake(50, 60) duration:0.5];
    SKAction *sc = [SKAction scaleTo:2.0 duration:0.25];
    SKAction *seq = [SKAction sequence:@[ mv, sc ]];

    NSMutableDictionary *acts = [NSMutableDictionary dictionary];
    acts[@"moveAndScale"] = seq;
    NSMutableDictionary *root = [NSMutableDictionary dictionary];
    root[@"actions"] = acts;
    root[@"_info"] = [NSMutableDictionary dictionary];
    return [NSKeyedArchiver archivedDataWithRootObject:root];
}

int main(int argc, char **argv) {
    @autoreleasepool {
        if (argc < 2) {
            fprintf(stderr, "usage: %s <golden.skeep>\n", argv[0]);
            return 2;
        }
        NSData *golden = [NSData dataWithContentsOfFile:
            [NSString stringWithUTF8String:argv[1]]];
        if (!golden) {
            fprintf(stderr, "cannot read golden: %s\n", argv[1]);
            return 2;
        }
        NSData *got = buildActionsArchive();
        if ([got isEqualToData:golden]) {
            printf("PASS  SKAction parity: %s (%lu bytes)\n",
                   argv[1], (unsigned long)got.length);
            return 0;
        }
        fprintf(stderr, "FAIL  SKAction parity: %s\n  got %lu bytes, expected %lu\n",
                argv[1], (unsigned long)got.length, (unsigned long)golden.length);
        NSUInteger n = MIN(got.length, golden.length);
        const uint8_t *g = got.bytes, *e = golden.bytes;
        for (NSUInteger i = 0; i < n; i++) {
            if (g[i] != e[i]) {
                fprintf(stderr, "  first difference at byte %lu: got 0x%02x, expected 0x%02x\n",
                        (unsigned long)i, g[i], e[i]);
                break;
            }
        }
        return 1;
    }
}