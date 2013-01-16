#import "FITestCase.h"
#import "FISoundContext.h"
#import "FISoundDevice.h"
#import "FISoundEngine.h"

@implementation FITestCase

- (void) setUp
{
  [super setUp];
  _soundBundle = [NSBundle bundleForClass:[self class]];
  [FISoundEngine sharedEngine];
}

- (void) tearDown
{
  _soundBundle = nil;
  [super tearDown];
}

@end
