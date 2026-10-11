#import <Foundation/Foundation.h>
#import "SKNode.h"
int main(int argc,const char**argv){
  @autoreleasepool{
    if(argc<2){fprintf(stderr,"usage: %s <range.skeep>\n",argv[0]);return 2;}
    SKRange*r=[SKRange rangeWithConstantValue:1];
    NSData*d=[NSKeyedArchiver archivedDataWithRootObject:r];
    NSData*g=[NSData dataWithContentsOfFile:[NSString stringWithUTF8String:argv[1]]];
    if([d isEqualToData:g]){printf("PASS SKRange parity (%lu bytes)\n",(unsigned long)d.length);return 0;}
    fprintf(stderr,"FAIL SKRange\n");return 1;
  }
}
