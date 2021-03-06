//
//  FIVector.m
//  Finch
//
//  Created by Sysolyatin Pavel on 1/20/13.
//
//

#import "FIVector.h"

@implementation FIVector
@synthesize x;
@synthesize y;
@synthesize z;

+(id)vector
{
  return [[FIVector alloc] initWithX:0 Y:0 Z:0];
}

+(id)vectorWithX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z
{
  return [[FIVector alloc] initWithX:x Y:y Z:z];
}

-(id)initWithX:(CGFloat)aX Y:(CGFloat)aY Z:(CGFloat)aZ
{
  self = [super init];
  if (self) {
    x = aX;
    y = aY;
    z = aZ;
  }
  return self;
}

-(BOOL)isEqual:(id)object
{
  if ([object isKindOfClass:[self class]])
  {
    FIVector* other = (FIVector*)object;
    return ([other x] == x
            && [other y] == y
            && [other z] == z);
  }
  return false;
}

-(NSString*)description
{
  return [NSString stringWithFormat:@"(%.2f, %.2f, %.2f)", x, y, z];
}

@end
