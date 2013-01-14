#import "FISoundEngine.h"
#import "FISoundContext.h"
#import "FISoundDevice.h"
#import "FIDecoder.h"
#import "FISampleBuffer.h"
#import "FIError.h"

@interface FISoundEngine ()
@property(strong) FISoundDevice *soundDevice;
@property(strong) FISoundContext *soundContext;
@property(strong) NSMutableArray *decoders;
@end

@implementation FISoundEngine

#pragma mark Initialization

- (id) init
{
    self = [super init];

    _soundDevice = [FISoundDevice defaultSoundDevice];
    _soundContext = [FISoundContext contextForDevice:_soundDevice error:NULL];
    if (!_soundContext) {
        return nil;
    }

    [self setSoundBundle:[NSBundle bundleForClass:[self class]]];
    [_soundContext setCurrent:YES];

    self.decoders = [NSMutableArray array];
    [self.decoders addObject:[[FIDecoder alloc] init]];
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

- (FISampleBuffer*)decodeAtPath:(NSString *)path error:(NSError **)error
{
  FI_INIT_ERROR_IF_NULL(error);

  FISampleBuffer *buffer = nil;
  NSEnumerator *e = [self.decoders objectEnumerator];
  id object;
  while (object = [e nextObject])
  {
    if ([object respondsToSelector:@selector(decodeAtPath:error:)])
      buffer = [object decodeAtPath:path error:error];
    if (buffer || [*error code] == FIErrorFormatNotSupported)
      break;
  }
  return nil;
}

- (BOOL) registerDecoder: (id <FIDecoderDelegate>) decoder
{
  if (!decoder)
    return NO;
  if (![self.decoders containsObject:decoder])
  {
    [self.decoders insertObject:decoder atIndex:0];
    return YES;
  }
  return NO;
}

- (BOOL) unregisterDecoder: (id <FIDecoderDelegate>) decoder
{
  if (!decoder)
    return NO;
  if ([self.decoders containsObject:decoder])
  {
    [self.decoders removeObject:decoder];
    return YES;
  }
  return NO;
}


/*
#pragma mark Sound Loading

- (FISound*) soundNamed: (NSString*) soundName maxPolyphony: (NSUInteger) voices error: (NSError**) error
{
    return [[FISound alloc]
        initWithPath:[_soundBundle pathForResource:soundName ofType:nil]
        maxPolyphony:voices error:error];
}

- (FISound*) soundNamed: (NSString*) soundName error: (NSError**) error
{
    return [self soundNamed:soundName maxPolyphony:1 error:error];
}
*/

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