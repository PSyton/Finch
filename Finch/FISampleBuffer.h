#import "FISampleFormat.h"

@interface FISampleBuffer : NSObject

@property(assign, readonly) ALuint handle;
@property(assign, readonly) UInt64 size;

- (id) initWithData:(NSData*)data sampleRate:(NSUInteger)sampleRate sampleFormat:(FISampleFormat)sampleFormat error: (NSError**)error;
-(int)setData:(NSData*)data withError:(NSError**)error;
@end
