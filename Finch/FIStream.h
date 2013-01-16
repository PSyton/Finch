//
//  FIStream.h
//  Finch
//
//  Created by Sysolyatin Pavel on 1/16/13.
//
//

#import "FISampleFormat.h"
#import <AudioToolbox/AudioToolbox.h>

@interface FIStream : NSObject
+(AudioStreamBasicDescription)internalAudioInfoWithSampleRate:(Float64)sampleRate withChannels:(UInt32)chanels;
+(NSUInteger)calculateBytesPerSample:(FISampleFormat)sampleFormat;
+(BOOL)checkInternalFormatSanity:(AudioStreamBasicDescription*)format error:(NSError**)error;

@end

@protocol FIStreamProtocol <NSObject>
@property(assign, readonly) NSUInteger sampleRate;
@property(assign, readonly) FISampleFormat sampleFormat;
@property(assign, readonly) NSUInteger numberOfSamples;
@property(assign, readonly) NSUInteger bytesPerSample;
@property(assign, readonly) NSTimeInterval duration;

@property(assign, readonly) UInt64 dataSize;
@property(strong, readonly) NSString* path;

@required
+(AudioStreamBasicDescription)internalAudioInfoWithSampleRate:(Float64)sampleRate withChannels:(UInt32)chanels;
+(NSUInteger)calculateBytesPerSample:(FISampleFormat)sampleFormat;
+(BOOL)checkInternalFormatSanity:(AudioStreamBasicDescription*)format error:(NSError**)error;

-(id)initWithPath:(NSString*)path error:(NSError**)error;
-(NSData*)readData:(UInt64)size;
-(void)rewind;
-(void)close;
@end
