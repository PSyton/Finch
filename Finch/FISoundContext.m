#import "FISoundContext.h"
#import "FISoundDevice.h"
#import "FIError.h"

@implementation FISoundContext

#pragma mark Initialization

-(id)initWithFIDevice:(FISoundDevice*)device error:(NSError**)error
{
  self = [super init];
  if (!device) {
    return nil;
  }
  
  alGetError();
  _device = device;
  _handle = alcCreateContext([device handle], 0);
  if (!_handle) {
    [FIError alErrorWithMessage:@"Can’t create OpenAL context"
                  withCode:FIErrorCannotCreateContext withError:error];
    return nil;
  }
  return self;
}

+(id)contextForDevice:(FISoundDevice*)device error:(NSError**)error
{
  return [[self alloc] initWithFIDevice:device error:error];
}

- (void) dealloc
{
  if (_handle) {
    if ([self isCurrent]) {
      [self setCurrent:NO];
    }
    alcDestroyContext(_handle);
    _handle = 0;
  }
}

#pragma mark Switching

-(BOOL)isCurrent
{
  return (alcGetCurrentContext() == _handle);
}

-(void)setCurrent:(BOOL)flag
{
  alcMakeContextCurrent(flag ? _handle : NULL);
}

#pragma mark Suspending

-(void)setSuspended:(BOOL)flag
{
  if (flag != _suspended) {
    if (flag) {
      alcSuspendContext(_handle);
      _suspended = YES;
    } else {
      alcProcessContext(_handle);
      _suspended = NO;
    }
  }
}

@end
