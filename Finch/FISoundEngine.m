#import "FISoundEngine.h"
#import "FISoundContext.h"
#import "FISoundDevice.h"
#import "FIDefaultStreamFactory.h"
#import "FISampleBuffer.h"
#import "FIError.h"
#import "FIVector.h"

@interface FISoundEngine ()
@property(strong) FISoundDevice *soundDevice;
@property(strong) FISoundContext *soundContext;
@property(strong) NSMutableArray *factory;
@end

@implementation FISoundEngine

@dynamic listenerPosition;

#pragma mark Initialization

- (id)init
{
  self = [super init];

  _soundDevice = [FISoundDevice defaultSoundDevice];
  _soundContext = [FISoundContext contextForDevice:_soundDevice error:NULL];
  if (!_soundContext) {
      return nil;
  }

  [self setSoundBundle:[NSBundle bundleForClass:[self class]]];
  [_soundContext setCurrent:YES];

  [self setListenerPosition: [FIVector vector]];

  self.factory = [NSMutableArray array];
  [self.factory addObject:[[FIDefaultStreamFactory alloc] init]];
  return self;
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (id) sharedEngine
{
  static dispatch_once_t once;
  static FISoundEngine *sharedEngine = nil;
  dispatch_once(&once, ^{
    sharedEngine = [[self alloc] init];
  });
  return sharedEngine;
}

#pragma mark Decoding

-(id<FIStreamProtocol>)createStreamWithPath:(NSString*)path error:(NSError**)error
{
  NSError* localError = nil;
  id<FIStreamProtocol> stream = nil;
  NSEnumerator *e = [self.factory objectEnumerator];
  id object;
  while (object = [e nextObject]) {
    if ([object respondsToSelector:@selector(createStreamWithPath:error:)]) {
      stream = [object createStreamWithPath:path error:&localError];
    }
    if (stream) {
      return stream;
    }
    if (localError && ([localError code] != FIErrorFormatNotSupported)) {
      break;
    }
  }
  if (error) {
    *error = localError;
  }
  return nil;
}

-(BOOL)registerStreamFactory:(id <FIStreamFactoryDelegate>)factory
{
  if (!factory) {
    return NO;
  }
  if (![self.factory containsObject:factory]) {
    [self.factory insertObject:factory atIndex:0];
    return YES;
  }
  return NO;
}

-(BOOL)unregisterStreamFactory:(id <FIStreamFactoryDelegate>)factory
{
  if (!factory) {
    return NO;
  }
  if ([self.factory containsObject:factory]) {
    [self.factory removeObject:factory];
    return YES;
  }
  return NO;
}

-(FIVector*)listenerPosition
{
  ALfloat x;
  ALfloat y;
  ALfloat z;
  alGetListener3f(AL_POSITION, &x, &y, &z);
  return [FIVector vectorWithX:x Y:y Z:z];
}

-(void)setListenerPosition:(FIVector *)listenerPosition
{
  alListener3f(AL_POSITION, listenerPosition.x, listenerPosition.y, listenerPosition.z);
}

#pragma mark Interruption Handling

// TODO: Resume may fail here, and in that case
// we would like to keep _suspended at YES.
- (void) setSuspended: (BOOL) newValue
{
    if (newValue != _suspended) {
        _suspended = newValue;
        if (_suspended) {
            [_soundContext setCurrent:NO];
            [_soundContext setSuspended:YES];
        } else {
            [_soundContext setCurrent:YES];
            [_soundContext setSuspended:NO];
        }
    }
}

@end