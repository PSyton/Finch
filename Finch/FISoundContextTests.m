#import "FISoundContext.h"
#import "FISoundDevice.h"

@interface FISoundContextTests : SenTestCase
@end

@implementation FISoundContextTests

- (void) testContextCreation
{
  FISoundDevice *device = [FISoundDevice defaultSoundDevice];
  FISoundContext *context = [[FISoundContext alloc] initWithFIDevice:device error:nil];
  STAssertNotNil(context, @"Create a context");
}

@end
