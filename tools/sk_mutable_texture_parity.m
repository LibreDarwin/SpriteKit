#import <Foundation/Foundation.h>
#import "SKNode.h"
int main(int argc,const char**argv){
  @autoreleasepool{
    if(argc<2){fprintf(stderr,"usage\n");return 2;}
    SKMutableTexture*t=[[SKMutableTexture alloc] initWithSize:CGSizeMake(2,2)];
    NSData*d=[NSKeyedArchiver archivedDataWithRootObject:t];
    NSData*g=[NSData dataWithContentsOfFile:[NSString stringWithUTF8String:argv[1]]];
    if([d isEqualToData:g]){printf("PASS SKMutableTexture(2x2) parity (%lu bytes)\n",(unsigned long)d.length);return 0;}
    fprintf(stderr,"FAIL SKMutableTexture: got %lu bytes\n",(unsigned long)d.length);return 1;
  }
}
