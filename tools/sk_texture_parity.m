// Copyright (C) 2026, LibreDarwin
// SPDX-License-Identifier: BSD-3-Clause
//
// Byte-parity harness for a clean-room SKTexture seeded from a 1x1 grey image.

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "SKNode.h"

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            fprintf(stderr, "usage: %s <texture.skeep>\n", argv[0]);
            return 2;
        }
        NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                          pixelsWide:1 pixelsHigh:1 bitsPerSample:8 samplesPerPixel:4
                          hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace
                          bytesPerRow:4 bitsPerPixel:32];
        uint8_t *pp = (uint8_t *)rep.bitmapData;
        pp[0] = 0x80; pp[1] = 0x80; pp[2] = 0x80; pp[3] = 0xFF;
        NSImage *img = [[NSImage alloc] initWithSize:NSMakeSize(1, 1)];
        [img addRepresentation:rep];

        SKTexture *tex = [SKTexture textureWithImage:img];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tex];
        NSData *golden = [NSData dataWithContentsOfFile:[NSString stringWithUTF8String:argv[1]]];
        if (!golden) {
            fprintf(stderr, "cannot read golden: %s\n", argv[1]);
            return 2;
        }
        if ([data isEqualToData:golden]) {
            printf("PASS SKTexture parity (%lu bytes)\n", (unsigned long)data.length);
            return 0;
        }
        fprintf(stderr, "FAIL SKTexture parity: wrote %lu bytes, golden %lu bytes\n",
                (unsigned long)data.length, (unsigned long)golden.length);
        return 1;
    }
}
