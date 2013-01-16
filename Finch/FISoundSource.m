#import "FISoundSource.h"
#import "FISampleBuffer.h"
#import "FIError.h"
#import "FIStream.h"
#import "FISoundEngine.h"
#import "FIVector.h"

// For default we user 512K buffer
#define READ_BUFFER_SIZE 512 * 1024
#define MAX_BUFFERS 4

@interface FISoundSource ()
@property(assign) ALuint handle;
@property(strong) NSMutableArray* buffers;
@property(strong) id<FIStreamProtocol> stream;
@end

@implementation FISoundSource
@synthesize loop;
@dynamic sampleRate, sampleFormat, bytesPerSample, duration, isPaused, isPlaying, isStream, position, path;

-(id)initWithSoundSource:(FISoundSource*)other
{
  if ([other isStream]) {
    self = [self initWithPath:other.stream.path enableStreaming:YES error:NULL];
    _pitch = other.pitch;
    _gain = other.gain;
    return self;
  }

  self = [super init];

  alClearError();
  alGenSources(1, &_handle);
  [self setLoop:[other loop]];
  ALenum status = alGetError();
  if (status) {
    return nil;
  }

  NSError* error = nil;

  _stream = [[FISoundEngine sharedEngine] createStreamWithPath:other.stream.path error:&error];
  if (!_stream) {
    return nil;
  }
  [_stream close];

  _pitch = other.pitch;
  _gain = other.gain;
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

+(id)sourceWithPath:(NSString*)path enableStreaming:(BOOL)streaming error:(NSError**)error
{
  return [[FISoundSource alloc] initWithPath:path enableStreaming:streaming error:error];
}

-(id)initWithPath:(NSString*)path enableStreaming:(BOOL)streaming error:(NSError**)error
{
  self = [super init];
  _pitch = 1;
  _gain = 1;
  _buffers = [NSMutableArray array];
  alClearError();
  alGenSources(1, &_handle);
  [self setLoop:NO];
  FI_INIT_ERROR_IF_NULL(error);
  ALenum status = alGetError();
  if (status) {
    *error = [FIError
              errorWithMessage:@"Failed to create OpenAL source"
              code:FIErrorCannotCreateSoundSource OpenALCode:status];
    return nil;
  }
  _stream = [[FISoundEngine sharedEngine] createStreamWithPath:path error:error];
  if (!_stream) {
    return nil;
  }

  UInt64 blockSize = [_stream dataSize];
  UInt32 buffCount = 1;
  if (streaming) {
    buffCount = MAX_BUFFERS;
    blockSize = READ_BUFFER_SIZE;
  }

  for (int i = 0; i < buffCount; ++i) {
    FISampleBuffer* buffer = [[FISampleBuffer alloc] initWithData:[_stream readData:blockSize]
                                                       sampleRate:[_stream sampleRate]
                                                     sampleFormat:[_stream sampleFormat]
                                                            error:error];
    if (!buffer) {
      return nil;
    }

    [_buffers addObject:buffer];
    if (!streaming) {
      alSourcei(_handle, AL_BUFFER, [buffer handle]);
      [_stream close];
    }
    else {
      if (![self queueBuffer:buffer error:error])
        return nil;
    }

    // End of file reached
    if (streaming && [buffer size] < blockSize)
      break;
  }
  [self setPosition:[FIVector vector]];
  return self;
}

- (BOOL)queueBuffer:(FISampleBuffer*)buffer error:(NSError**)error
{
  ALenum status = ALC_NO_ERROR;
  ALuint bufferId = [buffer handle];
  alSourceQueueBuffers(_handle, 1, &bufferId);
  status = alGetError();
  if (status) {
    if (error) {
      *error = [FIError errorWithMessage:@"Failed to queue buffer to OpenAl source"
                                    code:FIErrorCannotCreateBuffer OpenALCode:status];
    }
    return false;
  }
  return true;
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
  ALuint bufID;

  // Get count of processed buffers
  alGetSourcei(_handle, AL_BUFFERS_PROCESSED, &processed);

  while (processed--) {
    alSourceUnqueueBuffers(_handle, 1, &bufID);
    if (alGetError() != AL_NO_ERROR) {
      NSLog(@"Error unqueue");
      return;
    }

    FISampleBuffer* buffer = [self findBuffer:bufID];
    if (!buffer) {
      NSLog(@"OpenAL: Buffer with this id not found.");
      return;
    }
    
    NSData* data = [_stream readData:READ_BUFFER_SIZE];
    if (!data) {
      NSLog(@"OpenAL: Can't read data to buffer.");
      return;
    }
    
    // End of file reached.
    if ([data length] == 0) {
      if ([self loop]) {
        // If looping enabled we need to read buffer from begining
        [_stream rewind];
        data = [_stream readData:READ_BUFFER_SIZE];
        if (!data) {
          return;
        }
      }
      else {
        break;
      }
    }
    [buffer setData:data];
    if (![self queueBuffer:buffer error:NULL]) {
      NSLog(@"OpenAL: Can't queue buffer.");
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
  return [_stream sampleRate];
}

-(FISampleFormat)sampleFormat
{
  return [_stream sampleFormat];
}

-(NSUInteger)bytesPerSample
{
  return [_stream bytesPerSample];
}

-(NSTimeInterval)duration
{
  return [_stream duration];
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

-(NSString*)path
{
  return [_stream path];
}

@end
