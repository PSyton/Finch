#import "FISampleDecoder.h"
#import "FISampleBuffer.h"
#import "FIError.h"

@implementation FISampleDecoder

- (FISampleBuffer*) decodeAtPath: (NSString*) path error: (NSError**) error
{
    // Read sample data
    AudioStreamBasicDescription format = {0};
    NSData *sampleData = [self readSampleDataAtPath:path fileFormat:&format error:error];
    if (!sampleData) {
        return nil;
    }

    // Check sample format
    if (![self checkFormatSanity:format error:error]) {
        return nil;
    }

    // Create sample buffer
    NSError *bufferError = nil;
    FISampleBuffer *buffer = [[FISampleBuffer alloc]
        initWithData:sampleData sampleRate:format.mSampleRate
        sampleFormat:FISampleFormatMake(format.mChannelsPerFrame, format.mBitsPerChannel)
        error:&bufferError];

    if (!buffer) {
        *error = [NSError errorWithDomain:FIErrorDomain
            code:FIErrorCannotCreateBuffer userInfo:@{
            NSLocalizedDescriptionKey : @"Cannot create sound buffer",
            NSUnderlyingErrorKey : bufferError
        }];
        return nil;
    }

    return buffer;
}

- (BOOL) checkFormatSanity: (AudioStreamBasicDescription) format error: (NSError**) error
{
    NSParameterAssert(error);

    if (!TestAudioFormatNativeEndian(format)) {
        *error = [FIError
            errorWithMessage:@"Invalid sample endianity, only native endianity supported"
            code:FIErrorInvalidSampleFormat];
        return NO;
    }

    if (format.mChannelsPerFrame != 1 && format.mChannelsPerFrame != 2) {
        *error = [FIError
            errorWithMessage:@"Invalid number of sound channels, only mono and stereo supported"
            code:FIErrorInvalidSampleFormat];
        return NO;
    }

    if (format.mBitsPerChannel != 8 && format.mBitsPerChannel != 16) {
        *error = [FIError
            errorWithMessage:@"Invalid sample resolution, only 8-bit and 16-bit supported"
            code:FIErrorInvalidSampleFormat];
        return NO;
    }

    return YES;
}

- (NSData*) readSampleDataAtPath: (NSString*) path fileFormat: (AudioStreamBasicDescription*) theOutputFormat error: (NSError**) error
{
    NSParameterAssert(theOutputFormat);
    NSParameterAssert(error);

    if (!path) {
        return nil;
    }

    OSStatus errcode = noErr;
    UInt32 propertySize;
    AudioFileID fileId = 0;

    NSURL *fileURL = [NSURL fileURLWithPath:path];
    errcode = AudioFileOpenURL((__bridge CFURLRef) fileURL, kAudioFileReadPermission, 0, &fileId);
    if (errcode) {
        *error = [FIError
            errorWithMessage:@"Can’t read file"
            code:FIErrorCannotReadFile];
        return nil;
    }

    propertySize = sizeof(*theOutputFormat);
    errcode = AudioFileGetProperty(fileId, kAudioFilePropertyDataFormat, &propertySize, theOutputFormat);
    if (errcode) {
        *error = [FIError
            errorWithMessage:@"Can’t read file format"
            code:FIErrorInvalidSampleFormat];
        AudioFileClose(fileId);
        return nil;
    }

    NSData* audioData = nil;
    if (theOutputFormat->mFormatID != kAudioFormatLinearPCM) {

      ExtAudioFileRef extfileRef = 0;

      errcode = ExtAudioFileWrapAudioFileID(fileId, false, &extfileRef);
      if (errcode) {
          *error = [FIError
                    errorWithMessage:@"Can’t read file"
                    code:FIErrorCannotReadFile];
          AudioFileClose(fileId);
          return nil;
      }

      AudioStreamBasicDescription extFileFormat;
      propertySize = sizeof(extFileFormat);
      errcode = ExtAudioFileGetProperty(extfileRef, kExtAudioFileProperty_FileDataFormat, &propertySize, &extFileFormat);

      if (errcode) {
          *error = [FIError
                    errorWithMessage:@"Can’t read file format"
                    code:FIErrorInvalidSampleFormat];

          ExtAudioFileDispose(extfileRef);
          AudioFileClose(fileId);
          return nil;
      }

      if (extFileFormat.mChannelsPerFrame > 2) {
          *error = [FIError
                    errorWithMessage:@"Too many channels (better than stereo!)."
                    code:FIErrorInvalidSampleFormat];
      }

      theOutputFormat->mSampleRate = extFileFormat.mSampleRate;
      theOutputFormat->mChannelsPerFrame = extFileFormat.mChannelsPerFrame;

      theOutputFormat->mFormatID = kAudioFormatLinearPCM;
      theOutputFormat->mBytesPerPacket = 2 * theOutputFormat->mChannelsPerFrame;
      theOutputFormat->mFramesPerPacket = 1;
      theOutputFormat->mBytesPerFrame = 2 * theOutputFormat->mChannelsPerFrame;
      theOutputFormat->mBitsPerChannel = 16;
      theOutputFormat->mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;

      errcode = ExtAudioFileSetProperty(extfileRef, kExtAudioFileProperty_ClientDataFormat, sizeof(theOutputFormat), theOutputFormat);
      if (errcode) {
          *error = [FIError
                    errorWithMessage:@"Couldn't set output format."
                    code:FIErrorInvalidSampleFormat];
          ExtAudioFileDispose(extfileRef);
          AudioFileClose(fileId);
          return nil;
      }

      // Get the total frame count
      SInt64 numFrames;
      propertySize = sizeof(numFrames);
      errcode = ExtAudioFileGetProperty(extfileRef, kExtAudioFileProperty_FileLengthFrames, &propertySize, &numFrames);
      if (errcode) {
          *error = [FIError
                    errorWithMessage:@"Couldn't get frames count."
                    code:FIErrorInvalidSampleFormat];
          ExtAudioFileDispose(extfileRef);
          AudioFileClose(fileId);
          return nil;
      }

      // Read all the data into memory
      UInt64 dataSize = numFrames * theOutputFormat->mBytesPerFrame;
      void *data = malloc(dataSize);
      if (!data) {
          *error = [FIError
                    errorWithMessage:@"Can’t allocate memory for audio data"
                    code:FIErrorCannotAllocateMemory];
          ExtAudioFileDispose(extfileRef);
          AudioFileClose(fileId);
          return nil;
      }

      AudioBufferList theDataBuffer;
      theDataBuffer.mNumberBuffers = 1;
      theDataBuffer.mBuffers[0].mDataByteSize = dataSize;
      theDataBuffer.mBuffers[0].mNumberChannels = theOutputFormat->mChannelsPerFrame;
      theDataBuffer.mBuffers[0].mData = data;

      // Read the data into an AudioBufferList
      errcode = ExtAudioFileRead(extfileRef, (UInt32*)&numFrames, &theDataBuffer);
      if (errcode) {
          *error = [FIError
                    errorWithMessage:@"Can’t read audio data from file"
                    code:FIErrorInvalidSampleFormat];
          ExtAudioFileDispose(extfileRef);
          AudioFileClose(fileId);
          free(data);
          return nil;
      }

      ExtAudioFileDispose(extfileRef);
      audioData = [NSData dataWithBytesNoCopy:data length:dataSize freeWhenDone:YES];
    }
    else
    {
      UInt64 fileSize = 0;
      propertySize = sizeof(fileSize);
      errcode = AudioFileGetProperty(fileId, kAudioFilePropertyAudioDataByteCount, &propertySize, &fileSize);
      if (errcode) {
        *error = [FIError
                  errorWithMessage:@"Can’t read audio data byte count"
                  code:FIErrorInvalidSampleFormat];
        AudioFileClose(fileId);
        return nil;
      }

      UInt32 dataSize = (UInt32) fileSize;
      void *data = malloc(dataSize);
      if (!data) {
        *error = [FIError
                  errorWithMessage:@"Can’t allocate memory for audio data"
                  code:FIErrorCannotAllocateMemory];
        AudioFileClose(fileId);
        return nil;
      }

      errcode = AudioFileReadBytes(fileId, false, 0, &dataSize, data);
      if (errcode) {
        *error = [FIError
                  errorWithMessage:@"Can’t read audio data from file"
                  code:FIErrorInvalidSampleFormat];
        AudioFileClose(fileId);
        free(data);
        return nil;
      }

      audioData = [NSData dataWithBytesNoCopy:data length:dataSize freeWhenDone:YES];
    }

    AudioFileClose(fileId);
    return audioData;
}

@end
