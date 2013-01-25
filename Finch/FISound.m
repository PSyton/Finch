#import "FISound.h"
#import "FIDefaultStreamFactory.h"
#import "FISampleBuffer.h"
#import "FISoundSource.h"
#import "FISoundEngine.h"

@interface FISound ()
@property(strong, retain) FISoundSource* source;

- (id) initWithSound:(FISound*) sound;
@end

@implementation FISound
@synthesize source;
@dynamic isPlaying, loop, gain, pitch, duration, path;

-(id)initWithSound:(FISound*)sound
{
  self = [super init];
  source = [sound.source copy];
  if (!source) {
    return nil;
  }
  return self;
}

-(id)copyWithZone:(NSZone *)zone
{
  // We'll ignore the zone for now
  return [[FISound alloc] initWithSound:self];
}

+(id)soundWithPath:(NSString*)aPath enableStreaming:(BOOL)streaming error:(NSError**)error;
{
  NSRange range = [aPath rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
  if (NSNotFound == range.location || range.location > 0) {
    return [self soundWithName:aPath enableStreaming:streaming error:error];
  }
  return [[FISound alloc] initWithPath:aPath enableStreaming:streaming error:error];
}

+(id)soundWithName:(NSString*)name enableStreaming:(BOOL)streaming error:(NSError**)error
{
  NSString* path = [[[FISoundEngine sharedEngine] soundBundle] pathForResource:name ofType:nil];
  if (!path) {
    return nil;
  }
  return [[FISound alloc] initWithPath:path enableStreaming:streaming error:error];
}

#pragma mark Initialization
-(id)initWithPath:(NSString*)aPath enableStreaming:(BOOL)streaming error: (NSError**)error;
{
  self = [super init];
  source = [FISoundSource sourceWithPath:aPath enableStreaming:streaming error:error];
  if (!source) {
    return nil;
  }
  return self;
}

-(void)dealloc
{
  [self stop];
  source = nil;
}

-(void)play
{
  if (source) {
    [source play];
  }
}

-(void)stop
{
  if (source) {
    [source stop];
  }
}

-(void)update
{
  if (source) {
    [source update];
  }
}

-(void)pause
{
  if (source) {
    [source pause];
  }
}

-(NSString*)path
{
  if (source)
    return [source path];
  return nil;
}

#pragma mark Sound Properties
-(void)forwardInvocation:(NSInvocation*)invocation
{
  [invocation invokeWithTarget:source];
}


-(NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
  NSMethodSignature *our = [super methodSignatureForSelector:selector];
  return our ? our : [source methodSignatureForSelector:selector];
}

@end
