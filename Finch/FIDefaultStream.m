//
//  FIDefaultStream.m
//  Finch
//
//  Created by Sysolyatin Pavel on 1/20/13.
//
//

#import "FIDefaultStream.h"
#import "FIError.h"

@interface FIDefaultStream ()
@property (assign) AudioFileID fileId;
@property (assign) ExtAudioFileRef extFileRef;
@property (assign) AudioStreamBasicDescription outFormat;
@property (assign) UInt64 dataSize;
@property (assign) UInt64 bytesRead;
@property(strong) NSString* path;
@end

@implementation FIDefaultStream

-(id)initWithPath:(NSString*)filePath error:(NSError**)error
{
  self = [super init];
  if (!filePath) {
    return nil;
  }
  _fileId = 0;
  _extFileRef = 0;
  _dataSize = 0;
  _bytesRead = 0;
  _path = filePath;

  UInt32 propertySize = sizeof(_outFormat);
  memset(&_outFormat, 0, propertySize);

  OSStatus errcode = noErr;

  NSURL *fileURL = [NSURL fileURLWithPath:_path];
  errcode = AudioFileOpenURL((__bridge CFURLRef) fileURL, kAudioFileReadPermission, 0, &_fileId);
  if (errcode) {
    [FIError setError:error withMessage:@"Can’t read file"
             withCode:FIErrorCannotReadFile];
    return nil;
  }

  errcode = AudioFileGetProperty(_fileId, kAudioFilePropertyDataFormat, &propertySize, &_outFormat);
  if (errcode) {
    [FIError setError:error withMessage:@"Can’t read file format"
             withCode:FIErrorInvalidSampleFormat];
    return nil;
  }

  if (_outFormat.mFormatID != kAudioFormatLinearPCM) {
    errcode = ExtAudioFileWrapAudioFileID(_fileId, false, &_extFileRef);
    if (errcode) {
      [FIError setError:error withMessage:@"Can’t read file"
               withCode:FIErrorCannotReadFile];
      return nil;
    }

    AudioStreamBasicDescription extFileFormat;
    propertySize = sizeof(extFileFormat);
    errcode = ExtAudioFileGetProperty(_extFileRef, kExtAudioFileProperty_FileDataFormat, &propertySize, &extFileFormat);
    if (errcode) {
      [FIError setError:error withMessage:@"Can’t read file format"
               withCode:FIErrorInvalidSampleFormat];
      return nil;
    }

    if (extFileFormat.mChannelsPerFrame > 2) {
      [FIError setError:error withMessage:@"Too many channels (better than stereo!)."
               withCode:FIErrorInvalidSampleFormat];
    }
    _outFormat = [FIStream internalAudioInfoWithSampleRate:extFileFormat.mSampleRate
                                              withChannels:extFileFormat.mChannelsPerFrame];

    errcode = ExtAudioFileSetProperty(_extFileRef, kExtAudioFileProperty_ClientDataFormat, sizeof(_outFormat), &_outFormat);
    if (errcode) {
      [FIError setError:error withMessage:@"Couldn't set output format."
               withCode:FIErrorInvalidSampleFormat];
      return nil;
    }
    SInt64 numFrames;
    propertySize = sizeof(numFrames);
    errcode = ExtAudioFileGetProperty(_extFileRef, kExtAudioFileProperty_FileLengthFrames, &propertySize, &numFrames);
    if (errcode) {
      [FIError setError:error withMessage:@"Couldn't get frames count."
               withCode:FIErrorInvalidSampleFormat];
      return nil;
    }
    _dataSize = numFrames * _outFormat.mBytesPerFrame;
  }
  else {
    // Get audio data size for Wave file
    propertySize = sizeof(_dataSize);
    errcode = AudioFileGetProperty(_fileId, kAudioFilePropertyAudioDataByteCount, &propertySize, &_dataSize);
    if (errcode) {
      [FIError setError:error withMessage:@"Can’t read audio data byte count"
               withCode:FIErrorInvalidSampleFormat];
      return nil;
    }
  }
  if (![FIStream checkInternalFormatSanity:&(_outFormat) error:error]) {
    return nil;
  }

  _sampleRate = _outFormat.mSampleRate;
  _sampleFormat = FISampleFormatMake(_outFormat.mChannelsPerFrame, _outFormat.mBitsPerChannel);
  _bytesPerSample = [FIStream calculateBytesPerSample:_sampleFormat];
  
  _numberOfSamples = _dataSize / _bytesPerSample;
  _duration = _numberOfSamples / _sampleRate;
  return self;
}

-(NSData*)readData:(UInt64)size
{
  if (size < 1 || (!_fileId))
    return nil;

  UInt64 restBytes = _dataSize - _bytesRead;
  UInt64 readSize = (restBytes > size) ? size : restBytes;
  UInt64 readBytes = 0;
  OSStatus errcode = noErr;

  void *data = malloc(readSize);

  if (_extFileRef) {
    // Decode data

    AudioBufferList theDataBuffer;
    theDataBuffer.mNumberBuffers = 1;
    theDataBuffer.mBuffers[0].mDataByteSize = readSize;
    theDataBuffer.mBuffers[0].mNumberChannels = _outFormat.mChannelsPerFrame;
    theDataBuffer.mBuffers[0].mData = data;

    UInt64 numFrames = readSize / _outFormat.mBytesPerFrame;
    // Read the data into an AudioBufferList
    errcode = ExtAudioFileRead(_extFileRef, (UInt32*)&numFrames, &theDataBuffer);
    if (errcode) {
      free(data);
      return nil;
    }
    readBytes = numFrames * _outFormat.mBytesPerFrame;
  }
  else {
    // Read wave data
    UInt32 bytesForRead = (UInt32)readSize;
    errcode = AudioFileReadBytes(_fileId, false, _bytesRead, &bytesForRead, data);
    if (errcode) {
      free(data);
      return nil;
    }
    readBytes = bytesForRead;
  }
  if (readBytes == 0) {
    free(data);
    return [NSData data];
  }
  _bytesRead += readSize;
  return [NSData dataWithBytesNoCopy:data length:readSize freeWhenDone:YES];
}

-(void)close
{
  if (_extFileRef) {
    ExtAudioFileDispose(_extFileRef);
    _extFileRef = 0;
  }
  if (_fileId) {
    AudioFileClose(_fileId);
    _fileId = 0;
  }
}

-(void)rewind
{
  if (_extFileRef) {
    ExtAudioFileSeek(_extFileRef, 0);
  }
  _bytesRead = 0;
}

-(void)dealloc
{
  [self close];
}

@end
