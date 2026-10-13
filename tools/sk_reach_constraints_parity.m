#import <Foundation/Foundation.h>
#import "SKNode.h"

int main(int argc, const char **argv) {
    @autoreleasepool {
        if (argc < 2) {
            fprintf(stderr, "usage: %s <golden.skeep>\n", argv[0]);
            return 2;
        }
        SKReachConstraints *rc = [[SKReachConstraints alloc] initWithLowerAngleLimit:-1.0 upperAngleLimit:1.0];
        NSData *d = [NSKeyedArchiver archivedDataWithRootObject:rc];
        NSData *g = [NSData dataWithContentsOfFile:[NSString stringWithUTF8String:argv[1]]];
        if ([d isEqualToData:g]) {
            printf("PASS SKReachConstraints parity (%lu bytes)\n", (unsigned long)d.length);
            return 0;
        }
        fprintf(stderr, "FAIL SKReachConstraints: got %lu bytes\n", (unsigned long)d.length);
        return 1;
    }
}
