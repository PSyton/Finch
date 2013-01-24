#import "FIStream.h"
#import "FIError.h"

@implementation FIStream

+(AudioStreamBasicDescription)internalAudioInfoWithSampleRate:(Float64)sampleRate withChannels:(UInt32)chanels
{
  AudioStreamBasicDescription audioInfo = {0};
  audioInfo.mSampleRate = sampleRate;
  audioInfo.mChannelsPerFrame = chanels;

  audioInfo.mFormatID = kAudioFormatLinearPCM;
  audioInfo.mBytesPerPacket = 2 * audioInfo.mChannelsPerFrame;
  audioInfo.mFramesPerPacket = 1;
  audioInfo.mBytesPerFrame = 2 * audioInfo.mChannelsPerFrame;
  audioInfo.mBitsPerChannel = 16;
  audioInfo.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
  return audioInfo;
}

+(NSUInteger)calculateBytesPerSample:(FISampleFormat)sampleFormat
{
  if (sampleFormat == FISampleFormatMono16 || sampleFormat == FISampleFormatStereo8)
    return 2;
  else if (sampleFormat == FISampleFormatStereo16)
    return 4;
  return 1;
}

+(BOOL)checkInternalFormatSanity:(AudioStreamBasicDescription*)format error:(NSError**)error
{
  if (!TestAudioFormatNativeEndian((*format))) {
    [FIError setError:error
          withMessage:@"Invalid sample endianity, only native endianity supported"
             withCode:FIErrorInvalidSampleFormat];
    return NO;
  }

  if (format->mChannelsPerFrame != 1 && format->mChannelsPerFrame != 2) {
    [FIError setError:error
          withMessage:@"Invalid number of sound channels, only mono and stereo supported"
             withCode:FIErrorInvalidSampleFormat];
    return NO;
  }

  if (format->mBitsPerChannel != 8 && format->mBitsPerChannel != 16) {
    [FIError setError:error
          withMessage:@"Invalid sample resolution, only 8-bit and 16-bit supported"
             withCode:FIErrorInvalidSampleFormat];
    return NO;
  }
  return YES;
}



@end
