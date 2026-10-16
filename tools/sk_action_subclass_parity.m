// Copyright (C) 2026, LibreDarwin
// SPDX-License-Identifier: BSD-3-Clause
//
// Byte-parity harness for the clean-room SKAction concrete subclasses
// (SKFalloff, SKSpeed, SKStrength, SKFollowPath, SKHide, SKPerformSelector,
// SKPlaySound, SKReferencedAction, SKRunAction, SKAnimateWarp).  Each object is
// built through its public +[SKAction ...] factory (or, where Apple keeps the
// subclass private, its alloc/init default state) and the archived bytes are
// compared against Apple's goldens under <base_dir>.

#import <Foundation/Foundation.h>
#import "SKAction.h"
#import "SKNode.h"

static int all_pass = 1;

static void check(NSString *base, NSString *name, id obj) {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    NSString *path = [base stringByAppendingPathComponent:name];
    NSData *golden = [NSData dataWithContentsOfFile:path];
    if (!golden) {
        fprintf(stderr, "FAIL %s: cannot read golden\n", name.UTF8String);
        all_pass = 0;
        return;
    }
    if ([data isEqualToData:golden]) {
        printf("PASS %s (%lu bytes)\n", name.UTF8String, (unsigned long)data.length);
        return;
    }
    fprintf(stderr, "FAIL %s: wrote %lu bytes, golden %lu bytes\n",
            name.UTF8String, (unsigned long)data.length, (unsigned long)golden.length);
    all_pass = 0;
}

int main(int argc, const char **argv) {
    @autoreleasepool {
        if (argc < 2) {
            fprintf(stderr, "usage: %s <base_dir>\n", argv[0]);
            return 2;
        }
        NSString *base = [NSString stringWithUTF8String:argv[1]];

        check(base, @"oracle_actionsub_init_skfalloff.skeep",
              [[SKFalloff alloc] init]);
        check(base, @"oracle_actionsub_init_skspeed.skeep",
              [[SKSpeed alloc] init]);
        check(base, @"oracle_actionsub_init_skstrength.skeep",
              [[SKStrength alloc] init]);
        check(base, @"oracle_actionsub_init_skfollowpath.skeep",
              [[SKFollowPath alloc] init]);
        check(base, @"oracle_actionsub_init_skhide.skeep",
              [[SKHide alloc] init]);
        check(base, @"oracle_actionsub_init_skperformselector.skeep",
              [[SKPerformSelector alloc] init]);
        check(base, @"oracle_actionsub_init_skplaysound.skeep",
              [[SKPlaySound alloc] init]);
        check(base, @"oracle_actionsub_init_skreferencedaction.skeep",
              [[SKReferencedAction alloc] init]);
        check(base, @"oracle_actionsub_init_skrunaction.skeep",
              [[SKRunAction alloc] init]);
        check(base, @"oracle_actionsub_init_skanimatewarp.skeep",
              [[SKAnimateWarp alloc] init]);

        check(base, @"oracle_actionsub_hide.skeep",      [SKAction hide]);
        check(base, @"oracle_actionsub_unhide.skeep",    [SKAction unhide]);
        check(base, @"oracle_actionsub_speedto.skeep",
              [SKAction speedTo:2.0 duration:1.0]);
        check(base, @"oracle_actionsub_speedby.skeep",
              [SKAction speedBy:2.0 duration:1.0]);
        check(base, @"oracle_actionsub_falloffto.skeep",
              [SKAction falloffTo:0.5 duration:1.0]);
        check(base, @"oracle_actionsub_falloffby.skeep",
              [SKAction falloffBy:0.5 duration:1.0]);
        check(base, @"oracle_actionsub_strengthto.skeep",
              [SKAction strengthTo:2.0 duration:1.0]);
        check(base, @"oracle_actionsub_strengthby.skeep",
              [SKAction strengthBy:2.0 duration:1.0]);
        check(base, @"oracle_actionsub_followpath.skeep",
              [SKAction followPath:NULL duration:1.0]);
        check(base, @"oracle_actionsub_followpath2.skeep",
              [SKAction followPath:NULL asOffset:YES orientToPath:YES speed:1.0]);
        check(base, @"oracle_actionsub_perform.skeep",
              [SKAction performSelector:@selector(description)
                               onTarget:[[NSObject alloc] init]]);
        check(base, @"oracle_actionsub_playsound.skeep",
              [SKAction playSoundFileNamed:@"a" waitForCompletion:YES]);
        check(base, @"oracle_actionsub_runaction.skeep",
              [SKAction runAction:[SKAction waitForDuration:1.0]
                       onChildWithName:@"n"]);

        SKWarpGeometryGrid *g = [SKWarpGeometryGrid gridWithColumns:1 rows:1];
        check(base, @"oracle_actionsub_animatewarp.skeep",
              [SKAction animateWithWarps:@[g] times:@[@0.0]]);
        check(base, @"oracle_actionsub_animatewarpr.skeep",
              [SKAction animateWithWarps:@[g] times:@[@0.0] restore:YES]);

        if (!all_pass) return 1;
        printf("PASS all SKAction subclass parity\n");
        return 0;
    }
}
