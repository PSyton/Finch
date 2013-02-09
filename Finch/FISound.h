#import "FISampleFormat.h"

@class FIVector;

@interface FISound : NSObject <NSCopying>

@property(assign, readonly) BOOL isPlaying;
@property(assign, nonatomic) BOOL loop;
@property(assign, nonatomic) float gain;
@property(assign, nonatomic) float pitch;
@property(assign, nonatomic) FIVector* position;
@property(assign, readonly) NSTimeInterval duration;
@property(assign, readonly) NSString* path;


+(id)soundWithPath:(NSString*)path enableStreaming:(BOOL)streaming error:(NSError**)error;
+(id)soundWithName:(NSString*)name enableStreaming:(BOOL)streaming error:(NSError**)error;
-(id)initWithPath:(NSString*)path enableStreaming:(BOOL)streaming error:(NSError**)error;

-(void)play;
-(void)stop;
-(void)update;
-(void)pause;

@end
