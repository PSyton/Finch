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

  if (!alcGetCurrentContext()) {
    [FIError setError:error withMessage:@"No OpenAL context" withCode:FIErrorNoActiveContext];
    return nil;
  }

  alGetError(); // Reset error code.
  alGenBuffers(1, &_handle);
  if ([FIError alErrorWithMessage:@"Failed to create OpenAL buffer"
                            withCode:FIErrorCannotCreateBuffer withError:error]) {
    return nil;
  }

  if ([self setData:data withError:error] == 0) {
    return nil;
  }
  return self;
}

-(int)setData:(NSData*)data withError:(NSError**)error
{
  int size = [data length];
  alGetError();
  alBufferData(_handle, _sampleFormat, [data bytes], size, _sampleRate);
  if ([FIError alErrorWithMessage:@"Failed to pass sample data to OpenAL buffer"
                    withCode:FIErrorCannotUploadData
                   withError:error]) {
    size = 0;
  }
  _size = size;
  return size;
}

-(void)dealloc
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
