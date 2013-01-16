#import "FISampleBuffer.h"
#import "FIError.h"

@interface FISampleBuffer ()
@property(assign) UInt64 size;
@property(assign) ALenum sampleFormat;
@property(assign) NSUInteger sampleRate;

+(ALenum)OpenALSampleFormat:(FISampleFormat)format;
@end

@implementation FISampleBuffer

#pragma mark Initialization

- (id) initWithData:(NSData*)data sampleRate:(NSUInteger)sampleRate sampleFormat:(FISampleFormat)sampleFormat error: (NSError**)error
{
  self = [super init];

  if (data == nil) {
    return nil;
  }
  
  _size = [data length];
  _sampleFormat = [FISampleBuffer OpenALSampleFormat:sampleFormat];
  _sampleRate = sampleRate;

  FI_INIT_ERROR_IF_NULL(error);
  ALenum status = ALC_NO_ERROR;

  if (!alcGetCurrentContext()) {
    *error = [FIError errorWithMessage:@"No OpenAL context"
                                  code:FIErrorNoActiveContext];
    return nil;
  }

  alClearError();
  alGenBuffers(1, &_handle);
  status = alGetError();
  if (status) {
    *error = [FIError errorWithMessage:@"Failed to create OpenAL buffer"
                                  code:FIErrorCannotCreateBuffer OpenALCode:status];
    return nil;
  }

  if (![self setData:data]) {
    *error = [FIError errorWithMessage:@"Failed to pass sample data to OpenAL"
                                  code:FIErrorCannotUploadData OpenALCode:status];
    return nil;
  }
  return self;
}

- (BOOL)setData:(NSData*)data
{
  alClearError();
  alBufferData(_handle, _sampleFormat, [data bytes], [data length], _sampleRate);
  if (AL_NO_ERROR == alGetError()) {
    _size = [data length];
    return YES;
  }
  _size = 0;
  return NO;
}

- (BOOL)queueToSource:(ALint)sourceId error:(NSError**)error
{
  ALenum status = ALC_NO_ERROR;
  alSourceQueueBuffers(sourceId, 1, &_handle);
  status = alGetError();
  if (status) {
    *error = [FIError errorWithMessage:@"Failed to queue buffer to OpenAl source"
                                  code:FIErrorCannotCreateBuffer OpenALCode:status];
    return false;
  }
  return true;
}

- (void) dealloc
{
  if (_handle) {
    alDeleteBuffers(1, &_handle);
    _handle = 0;
  }
}

+(ALenum) OpenALSampleFormat:(FISampleFormat)format
{
  switch (format)
  {
    case FISampleFormatMono8:
      return AL_FORMAT_MONO8;
    case FISampleFormatMono16:
      return AL_FORMAT_MONO16;
    case FISampleFormatStereo8:
      return AL_FORMAT_STEREO8;
    case FISampleFormatStereo16:
      return AL_FORMAT_STEREO16;
  }
}
@end
