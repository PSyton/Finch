#import "FISound.h"
#import "FIDefaultStreamFactory.h"
#import "FISampleBuffer.h"
#import "FISoundSource.h"
#import "FISoundEngine.h"

@interface FISound ()
@property(strong) FISoundSource* source;
- (id) initWithSound:(FISound*) sound;
@end

@implementation FISound
@dynamic isPlaying, loop, gain, pitch, duration, path;

-(id)initWithSound:(FISound*)sound
{
  self = [super init];
  _source = [sound.source copy];
  if (!_source) {
    return nil;
  }
  return self;
}

-(id)copyWithZone:(NSZone *)zone
{
  // We'll ignore the zone for now
  return [[FISound alloc] initWithSound:self];
}

-(NSString*)path
{
  if (_source)
    return [_source path];
  return [NSString string];
}

+(id)soundWithPath:(NSString*)path enableStreaming:(BOOL)streaming error:(NSError**)error;
{
  NSRange range = [path rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
  if (NSNotFound == range.location || range.location > 0) {
    return [self soundWithName:path enableStreaming:streaming error:error];
  }
  return [[FISound alloc] initWithPath:path enableStreaming:streaming error:error];
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
-(id)initWithPath:(NSString*)path enableStreaming:(BOOL)streaming error: (NSError**)error;
{
  self = [super init];
  _source = [FISoundSource sourceWithPath:path enableStreaming:streaming error:error];
  if (!_source) {
    return nil;
  }
  return self;
}

-(void)dealloc
{
  [self stop];
}

-(void)play
{
  if (_source) {
    [_source play];
  }
}

-(void)stop
{
  if (_source) {
    [_source stop];
  }
}

-(void)update
{
  if (_source) {
    [_source update];
  }
}

-(void)pause
{
  if (_source) {
    [_source pause];
  }
}

#pragma mark Sound Properties
-(void)forwardInvocation:(NSInvocation*)invocation
{
  [invocation invokeWithTarget:_source];
}


-(NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
  NSMethodSignature *our = [super methodSignatureForSelector:selector];
  return our ? our : [_source methodSignatureForSelector:selector];
}

@end
