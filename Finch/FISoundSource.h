#import "FISampleFormat.h"

@class FISampleBuffer;
@class FIVector;

@interface FISoundSource : NSObject <NSCopying>
@property(assign, readonly) BOOL isPlaying;
@property(assign, readonly) BOOL isPaused;
@property(assign, readonly) BOOL isStream;

@property(assign, nonatomic) BOOL loop;
@property(assign, nonatomic) float gain;
@property(assign, nonatomic) float pitch;
@property(copy, nonatomic) FIVector* position;
@property(strong, readonly) NSString* path;


@property(assign, readonly) NSUInteger sampleRate;
@property(assign, readonly) FISampleFormat sampleFormat;
@property(assign, readonly) NSUInteger bytesPerSample;
@property(assign, readonly) NSTimeInterval duration;

+(id)sourceWithPath:(NSString*)path enableStreaming:(BOOL)streaming error:(NSError**)error;

-(void)update;
-(void)play;
-(void)stop;
-(void)pause;
@end
