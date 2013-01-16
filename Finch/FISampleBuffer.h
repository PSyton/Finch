#import "FISampleFormat.h"

@interface FISampleBuffer : NSObject

@property(assign, readonly) ALuint handle;
@property(assign, readonly) UInt64 size;

- (id) initWithData:(NSData*)data sampleRate:(NSUInteger)sampleRate sampleFormat:(FISampleFormat)sampleFormat error: (NSError**)error;
- (BOOL)setData:(NSData*)data;
- (BOOL)queueToSource:(ALint)sourceId error:(NSError**)error;
@end
