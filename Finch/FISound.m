#import "FISound.h"
#import "FISampleDecoder.h"
#import "FISampleBuffer.h"
#import "FISoundSource.h"
#import "FISoundEngine.h"

@interface FISound ()
@property(strong) NSArray *voices;
@property(assign) NSUInteger currentVoiceIndex;

- (id) initWithSound:(FISound*) sound;
@end

@implementation FISound
@dynamic isPlaying, loop, gain, pitch, duration;



- (id) initWithSound:(FISound*) sound
{
  self = [super init];
  _voices = @[];
  if (self)
  {
    NSEnumerator *e = [sound.voices objectEnumerator];
    id object;
    while (object = [e nextObject])
    {
      FISoundSource *voice = [[FISoundSource alloc] initWithSampleBuffer:((FISoundSource*)object).sampleBuffer
                                                                   error:nil];
      if (!voice)
        return nil;
      _voices = [_voices arrayByAddingObject:voice];
    }
  }
  return self;
}

-(id)copyWithZone:(NSZone *)zone
{
  // We'll ignore the zone for now
  return [[FISound alloc] initWithSound:self];
}

+ (id) soundWithPath: (NSString*) path maxPolyphony: (NSUInteger) voices error: (NSError**) error
{
  return [[FISound alloc] initWithPath:path maxPolyphony:voices error:error];
}

+ (id) soundWithPath: (NSString*) path error: (NSError**) error
{
  return [[FISound alloc] initWithPath:path maxPolyphony:1 error:error];
}


#pragma mark Initialization

- (id) initWithPath: (NSString*) path maxPolyphony: (NSUInteger) maxPolyphony error: (NSError**) error
{
    self = [super init];
    _voices = @[];
  
    if (!maxPolyphony) {
      return nil;
    }

    FISampleBuffer *buffer = nil;

    FISoundEngine* engine = [FISoundEngine sharedEngine];
    if (engine) {
       buffer = [engine decodeAtPath:path error:error];
    }

    if (!buffer) {
        return nil;
    }

    for (int i=0; i<maxPolyphony; i++) {
        FISoundSource *voice = [[FISoundSource alloc] initWithSampleBuffer:buffer error:error];
        if (voice) {
            _voices = [_voices arrayByAddingObject:voice];
        } else {
            return nil;
        }
    }

    return self;
}

- (void) dealloc
{
}

- (id) initWithPath: (NSString*) path error: (NSError**) error
{
    return [self initWithPath:path maxPolyphony:1 error:error];
}

#pragma mark Playback

- (void) play
{
    _currentVoiceIndex = (_currentVoiceIndex + 1) % [_voices count];
    [(FISoundSource*) [_voices objectAtIndex:_currentVoiceIndex] play];
}

- (void) stop
{
    for (FISound *voice in _voices) {
        [voice stop];
    }
}

#pragma mark Sound Properties

- (NSTimeInterval) duration
{
    return [[[_voices lastObject] sampleBuffer] duration];
}

- (void) forwardInvocation: (NSInvocation*) invocation
{
    for (FISoundSource *voice in _voices)
        [invocation invokeWithTarget:voice];
}

- (NSMethodSignature*) methodSignatureForSelector: (SEL) selector
{
    NSMethodSignature *our = [super methodSignatureForSelector:selector];
    NSMethodSignature *voiced = [[_voices lastObject] methodSignatureForSelector:selector];
    return our ? our : voiced;
}

@end
