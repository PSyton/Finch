#import "FISoundSource.h"
#import "FISampleBuffer.h"
#import "FIError.h"
#import "FIStream.h"
#import "FISoundEngine.h"
#import "FIVector.h"

// For default we user 512K buffer
#define READ_BUFFER_SIZE 512 * 1024
#define MAX_BUFFERS 5

@interface FISoundSource ()
@property(assign) ALuint handle;
@property(strong, retain) NSMutableArray* buffers;
@property(strong, retain) id<FIStreamProtocol> stream;
@property(strong, retain) NSString* path;
@end

@implementation FISoundSource
@synthesize loop, stream, path;
@dynamic sampleRate, sampleFormat, bytesPerSample, duration, isPaused, isPlaying, isStream, position;

-(id)initWithSoundSource:(FISoundSource*)other
{
  if ([other isStream]) {
    self = [self initWithPath:[other path] enableStreaming:YES error:NULL];
    _pitch = other.pitch;
    _gain = other.gain;
    path = other.path;
    return self;
  }

  self = [super init];

  alGetError();
  alGenSources(1, &_handle);
  [self setLoop:[other loop]];
  ALenum status = alGetError();
  if (status) {
    return nil;
  }

  stream = [other stream];
  _pitch = other.pitch;
  _gain = other.gain;
  path = other.path;
  _buffers = [NSMutableArray array];

  NSEnumerator *e = [other.buffers objectEnumerator];
  id object;
  while (object = [e nextObject]) {
    [_buffers addObject:object];
    FISampleBuffer* buffer = (FISampleBuffer*)object;
    alSourcei(_handle, AL_BUFFER, [buffer handle]);
  }
  return self;
}

#pragma mark Initialization

-(id)copyWithZone:(NSZone *)zone
{
  // We'll ignore the zone for now
  return [[FISoundSource alloc] initWithSoundSource:self];
}

+(id)sourceWithPath:(NSString*)aPath enableStreaming:(BOOL)streaming error:(NSError**)error
{
  return [[FISoundSource alloc] initWithPath:aPath enableStreaming:streaming error:error];
}

-(id)initWithPath:(NSString*)aPath enableStreaming:(BOOL)streaming error:(NSError**)error
{
  self = [super init];
  _pitch = 1;
  _gain = 1;
  _buffers = [NSMutableArray array];
  alGetError();
  alGenSources(1, &_handle);
  [self setLoop:NO];
  
  if ([FIError alErrorWithMessage:@"Failed to create OpenAL source"
                            withCode:FIErrorCannotCreateSoundSource
                           withError:error]) {
    return nil;
  }
    
  stream = [[FISoundEngine sharedEngine] createStreamWithPath:aPath error:error];
  if (!stream) {
    return nil;
  }

  UInt64 blockSize = [stream dataSize];
  UInt32 buffCount = 1;
  if (streaming) {
    buffCount = MAX_BUFFERS;
    blockSize = READ_BUFFER_SIZE;
  }

  for (int i = 0; i < buffCount; ++i) {
    FISampleBuffer* buffer = [[FISampleBuffer alloc] initWithData:[stream readData:blockSize]
                                                       sampleRate:[stream sampleRate]
                                                     sampleFormat:[stream sampleFormat]
                                                            error:error];
    if (!buffer) {
      return nil;
    }

    [_buffers addObject:buffer];
    if (!streaming) {
      alSourcei(_handle, AL_BUFFER, [buffer handle]);
      [stream close];
    }
    else {
      if (![self queueBuffer:buffer error:error])
        return nil;
    }

    // End of file reached
    if (streaming && [buffer size] < blockSize)
      break;
  }
  path = aPath;
  [self setPosition:[FIVector vector]];
  return self;
}

- (BOOL)queueBuffer:(FISampleBuffer*)buffer error:(NSError**)error
{
  alGetError();
  ALuint bufferId = [buffer handle];
  alSourceQueueBuffers(_handle, 1, &bufferId);

  // \fixme Change Error code for this...
  if ([FIError alErrorWithMessage:@"Failed to queue buffer to OpenAl source"
                            withCode:FIErrorStreaming
                           withError:error]) {
    return NO;
  }
  return YES;
}

-(FISampleBuffer*)findBuffer:(ALuint)bufferId
{
  NSEnumerator *e = [_buffers objectEnumerator];
  id object;
  while (object = [e nextObject]) {
    if ([(FISampleBuffer*)object handle] == bufferId) {
      return (FISampleBuffer*)object;
    }
  }
  return nil;
}

-(void)update
{
  if (![self isStream]) {
    return;
  }

  int processed = 0;
  ALuint bufID = 0;
  NSError* error = nil;

  alGetError();
  // Get count of processed buffers
  alGetSourcei(_handle, AL_BUFFERS_PROCESSED, &processed);
  if ([FIError alErrorWithMessage:@"Failed to get processed buffers"
                                withCode:FIErrorStreaming
                               withError:&error]) {

#ifdef DEBUG
    NSLog(@"processed: %d, %@", processed, [error description]);
#endif
    return;
  }

  while (processed--) {
    alGetError();
    alSourceUnqueueBuffers(_handle, 1, &bufID);
    if ([FIError alErrorWithMessage:@"Failed to unqueue buffer from OpenAl source"
                           withCode:FIErrorStreaming
                          withError:&error]) {
#ifdef DEBUG
      NSLog(@"%@", [error description]);
#endif
      return;
    }

    FISampleBuffer* buffer = [self findBuffer:bufID];
    if (!buffer) {
#ifdef DEBUG
      NSLog(@"OpenAL: Buffer with this id not found.");
#endif
      return;
    }
    
    NSData* data = [stream readData:READ_BUFFER_SIZE];
    if (!data) {
#ifdef DEBUG
      NSLog(@"OpenAL: Can't read data to buffer.");
#endif
      return;
    }
    
    // End of file reached.
    if ([data length] == 0) {
      if ([self loop]) {
        // If looping enabled we need to read buffer from begining
        [stream rewind];
        data = [stream readData:READ_BUFFER_SIZE];
        if (!data) {
          return;
        }
      }
      else {
        break;
      }
    }
    if ([buffer setData:data withError:&error] == 0) {
#ifdef DEBUG
      NSLog(@"%@", [error description]);
#endif
      return;
    }

    if (![self queueBuffer:buffer error:&error]) {
#ifdef DEBUG
      NSLog(@"%@", [error description]);
#endif
      return;
    }
  }
}

-(void)dealloc
{
  if ([self isPlaying]) {
    [self stop];
  }
  if (_handle) {
    alSourcei(_handle, AL_BUFFER, 0 /* detach */);
    alDeleteSources(1, &_handle);
    _handle = 0;
  }
}

#pragma mark Playback

- (void)play
{
  if ([self isPlaying]) {
    [self stop];
  }
  alSourcePlay(_handle);
}

- (void)stop
{
  if ([self isPlaying]) {
    alSourceStop(_handle);
  }
}

-(void)pause
{
  if ([self isPlaying]) {
    alSourcePause(_handle);
  }
}

- (BOOL)isPlaying
{
  ALint state;
  alGetSourcei(_handle, AL_SOURCE_STATE, &state);
  return (AL_PLAYING == state);
}

-(BOOL)isPaused
{
  ALint state;
  alGetSourcei(_handle, AL_SOURCE_STATE, &state);
  return (AL_PAUSED == state);
}

-(BOOL)isStream
{
  ALint type;
  alGetSourcei(_handle, AL_SOURCE_TYPE, &type);
  return (AL_STREAMING == type);
}

#pragma mark Sound Properties

- (void)setGain:(float) value
{
  alSourcef(_handle, AL_GAIN, value);
  _gain = value;
}

- (void)setPitch:(float) value
{
  alSourcef(_handle, AL_PITCH, value);
  _pitch = value;
}

- (void)setLoop:(BOOL)aLoop
{
  if (![self isStream]) {
    alSourcei(_handle, AL_LOOPING, aLoop);
  }
  loop = aLoop;
}

-(NSUInteger)sampleRate
{
  return [stream sampleRate];
}

-(FISampleFormat)sampleFormat
{
  return [stream sampleFormat];
}

-(NSUInteger)bytesPerSample
{
  return [stream bytesPerSample];
}

-(NSTimeInterval)duration
{
  return [stream duration];
}

-(FIVector*)position
{
  ALfloat x;
  ALfloat y;
  ALfloat z;
  alGetSource3f(_handle, AL_POSITION, &x, &y, &z);
  return [FIVector vectorWithX:x Y:y Z:z];
}

-(void)setPosition:(FIVector *)position
{
  alSource3f(_handle, AL_POSITION, position.x, position.y, position.z);
}

@end
