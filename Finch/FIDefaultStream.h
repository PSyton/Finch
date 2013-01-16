//
//  FIDefaultStream.h
//  Finch
//
//  Created by Sysolyatin Pavel on 1/20/13.
//
//

#import "FIStream.h"

@interface FIDefaultStream : FIStream<FIStreamProtocol>
@property(assign, readonly) NSUInteger sampleRate;
@property(assign, readonly) FISampleFormat sampleFormat;
@property(assign, readonly) NSUInteger numberOfSamples;
@property(assign, readonly) NSUInteger bytesPerSample;
@property(assign, readonly) NSTimeInterval duration;

@property(assign, readonly) UInt64 dataSize;
@property(strong, readonly) NSString* path;
@end
