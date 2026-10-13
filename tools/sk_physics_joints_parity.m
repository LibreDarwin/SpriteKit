#import <Foundation/Foundation.h>
#import "SKNode.h"

int main(int argc, const char **argv) {
    @autoreleasepool {
        if (argc < 2) {
            fprintf(stderr, "usage: %s <base_dir>\n", argv[0]);
            return 2;
        }
        NSString *base = [NSString stringWithUTF8String:argv[1]];
        int all_pass = 1;
        // Pin
        {
            PKPhysicsBody *a = [PKPhysicsBody bodyWithCircleOfRadius:2.0];
            PKPhysicsBody *b = [PKPhysicsBody bodyWithCircleOfRadius:3.0];
            SKPhysicsJointPin *j = [SKPhysicsJointPin jointWithBodyA:a bodyB:b anchor:CGPointMake(1.0, 2.0)];
            NSData *d = [NSKeyedArchiver archivedDataWithRootObject:j];
            NSData *g = [NSData dataWithContentsOfFile:[base stringByAppendingPathComponent:@"oracle_joint_pin.skeep"]];
            if (![d isEqualToData:g]) { fprintf(stderr, "FAIL joint_pin\n"); all_pass = 0; }
        }
        // Fixed
        {
            PKPhysicsBody *a = [PKPhysicsBody bodyWithCircleOfRadius:2.0];
            PKPhysicsBody *b = [PKPhysicsBody bodyWithCircleOfRadius:3.0];
            SKPhysicsJointFixed *j = [SKPhysicsJointFixed jointWithBodyA:a bodyB:b anchor:CGPointMake(1.0, 2.0)];
            NSData *d = [NSKeyedArchiver archivedDataWithRootObject:j];
            NSData *g = [NSData dataWithContentsOfFile:[base stringByAppendingPathComponent:@"oracle_joint_fixed.skeep"]];
            if (![d isEqualToData:g]) { fprintf(stderr, "FAIL joint_fixed\n"); all_pass = 0; }
        }
        // Spring
        {
            PKPhysicsBody *a = [PKPhysicsBody bodyWithCircleOfRadius:2.0];
            PKPhysicsBody *b = [PKPhysicsBody bodyWithCircleOfRadius:3.0];
            SKPhysicsJointSpring *j = [SKPhysicsJointSpring jointWithBodyA:a bodyB:b anchorA:CGPointMake(1.0, 2.0) anchorB:CGPointMake(3.0, 4.0)];
            j.damping = 0.5; j.frequency = 2.0;
            NSData *d = [NSKeyedArchiver archivedDataWithRootObject:j];
            NSData *g = [NSData dataWithContentsOfFile:[base stringByAppendingPathComponent:@"oracle_joint_spring.skeep"]];
            if (![d isEqualToData:g]) { fprintf(stderr, "FAIL joint_spring\n"); all_pass = 0; }
        }
        // Sliding
        {
            PKPhysicsBody *a = [PKPhysicsBody bodyWithCircleOfRadius:2.0];
            PKPhysicsBody *b = [PKPhysicsBody bodyWithCircleOfRadius:3.0];
            SKPhysicsJointSliding *j = [SKPhysicsJointSliding jointWithBodyA:a bodyB:b anchor:CGPointMake(1.0, 2.0) axis:CGVectorMake(1.0, 0.0)];
            j.lowerDistanceLimit = -1.0; j.upperDistanceLimit = 1.0;
            NSData *d = [NSKeyedArchiver archivedDataWithRootObject:j];
            NSData *g = [NSData dataWithContentsOfFile:[base stringByAppendingPathComponent:@"oracle_joint_sliding.skeep"]];
            if (![d isEqualToData:g]) { fprintf(stderr, "FAIL joint_sliding\n"); all_pass = 0; }
        }
        // Rope/Limit
        {
            PKPhysicsBody *a = [PKPhysicsBody bodyWithCircleOfRadius:2.0];
            PKPhysicsBody *b = [PKPhysicsBody bodyWithCircleOfRadius:3.0];
            SKPhysicsJointLimit *j = [SKPhysicsJointLimit jointWithBodyA:a bodyB:b anchorA:CGPointMake(1.0, 2.0) anchorB:CGPointMake(3.0, 4.0)];
            NSData *d = [NSKeyedArchiver archivedDataWithRootObject:j];
            NSData *g = [NSData dataWithContentsOfFile:[base stringByAppendingPathComponent:@"oracle_joint_rope.skeep"]];
            if (![d isEqualToData:g]) { fprintf(stderr, "FAIL joint_rope\n"); all_pass = 0; }
        }
        if (all_pass) { printf("PASS physics joints parity\n"); return 0; }
        return 1;
    }
}
