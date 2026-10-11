#import <Foundation/Foundation.h>
#import "SKNode.h"
int main(int argc,const char**argv){
  @autoreleasepool{
    if(argc<2){fprintf(stderr,"usage\n");return 2;}
    SKConstraint*c=[SKConstraint positionX:[SKRange rangeWithConstantValue:1]];
    NSData*d=[NSKeyedArchiver archivedDataWithRootObject:c];
    NSData*g=[NSData dataWithContentsOfFile:[NSString stringWithUTF8String:argv[1]]];
    if([d isEqualToData:g]){printf("PASS SKConstraint(positionX) parity (%lu bytes)\n",(unsigned long)d.length);return 0;}
    fprintf(stderr,"FAIL\n");return 1;
  }
}
