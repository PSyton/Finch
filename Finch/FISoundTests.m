#import "FITestCase.h"
#import "FISound.h"

@interface FISoundTests : FITestCase
@end

@implementation FISoundTests

-(void)testInitializationWithNilPath
{
  FISound *sound = nil;
  STAssertNoThrow(sound = [FISound soundWithPath:nil enableStreaming:NO error:NULL],
                  @"Do not throw when trying to load a sound from a nil path");
  STAssertNil(sound, @"Return nil when loading a sound from a nil path");

  STAssertNoThrow(sound = [FISound soundWithPath:nil enableStreaming:YES error:NULL],
                  @"Do not throw when trying to load a sound from a nil path");
  STAssertNil(sound, @"Return nil when loading a sound from a nil path");
}

-(void)testSimpleSound
{
  FISound *sound = nil;
  STAssertNoThrow(sound = [FISound soundWithPath:[[self soundBundle] pathForResource:@"mono8bit" ofType:@"wav"]
                                 enableStreaming:NO error:NULL],
                  @"Don't throw when trying to load a simple sound from a valid path");
  STAssertNotNil(sound, @"Load a basic sound");
  STAssertFalse([sound isPlaying], @"Loaded sound not playing");
  STAssertFalse([sound loop], @"Loaded sound not looped");
  STAssertEqualsWithAccuracy([sound gain], 1.f, 0.01, @"Detect gain for sound");
  STAssertEqualsWithAccuracy([sound pitch], 1.f, 0.01, @"Detect pitch for sound");

  STAssertNoThrow([sound play], @"Don't throw when start to play");
  STAssertEquals([sound isPlaying], YES, @"Playing after calling -play");

  STAssertNoThrow([sound stop], @"Don't throw when start to play");
  STAssertEquals([sound isPlaying], NO, @"Playing after calling -stop");
}

- (void)testLoadingStream
{
  FISound *sound = nil;
  STAssertNoThrow(sound = [FISound soundWithPath:[[self soundBundle] pathForResource:@"mono8bit" ofType:@"wav"]
                                 enableStreaming:YES error:NULL],
                  @"Don't throw when trying to load a streamed sound from a valid path");
  STAssertNotNil(sound, @"Load a streamed sound");
  STAssertFalse([sound isPlaying], @"Loaded streamed sound not playing");
  STAssertFalse([sound loop], @"Loaded streamed sound not looped");
  STAssertEqualsWithAccuracy([sound gain], 1.f, 0.01, @"Detect gain for streamed sound");
  STAssertEqualsWithAccuracy([sound pitch], 1.f, 0.01, @"Detect pitch for streamed sound");
}


-(void)test8BitMonoWave
{
  NSError *error = nil;
  FISound* sound = nil;
  STAssertNoThrow(sound = [FISound soundWithPath:[[self soundBundle] pathForResource:@"mono8bit" ofType:@"wav"]
                                 enableStreaming:NO
                                           error:&error],
                  @"Don't throw when trying to load a simple sound from a valid path");
  STAssertNotNil(sound, @"Load a 8-bit mono sound %@", error);
  STAssertEquals([sound duration], (NSTimeInterval)1, @"Calculate duration for 8-bit mono files");
}

-(void)test8BitStereoWave
{
  NSError *error = nil;
  FISound* sound = nil;
  STAssertNoThrow(sound = [FISound soundWithPath:[[self soundBundle] pathForResource:@"stereo8bit" ofType:@"wav"]
                                 enableStreaming:NO
                                           error:&error],
                  @"Don't throw when trying to load a simple sound from a valid path");
  STAssertNotNil(sound, @"Load a 8-bit stereo sound %@", error);
  STAssertEquals([sound duration], (NSTimeInterval)1, @"Calculate duration for 8-bit stereo files");
}

-(void)test16BitMonoWave
{
  NSError *error = nil;
  FISound* sound = nil;
  STAssertNoThrow(sound = [FISound soundWithPath:[[self soundBundle] pathForResource:@"mono16bit" ofType:@"wav"]
                                 enableStreaming:NO
                                           error:&error],
                  @"Don't throw when trying to load a simple sound from a valid path");
  STAssertNotNil(sound, @"Load a 16-bit mono sound %@", error);
  STAssertEquals([sound duration], (NSTimeInterval)1, @"Calculate duration for 16-bit mono files");
}

-(void)test16BitStereoWave
{
  NSError *error = nil;
  FISound* sound = nil;
  STAssertNoThrow(sound = [FISound soundWithPath:[[self soundBundle] pathForResource:@"stereo16bit" ofType:@"wav"]
                                 enableStreaming:NO
                                           error:&error],
                  @"Don't throw when trying to load a simple sound from a valid path");
  STAssertNotNil(sound, @"Load a 16-bit stereo sound %@", error);
  STAssertEquals([sound duration], (NSTimeInterval)1, @"Calculate duration for 16-bit stereo files");
}

- (void) test8BitMonoM4a
{
  NSError *error = nil;
  FISound* sound = nil;
  STAssertNoThrow(sound = [FISound soundWithPath:[[self soundBundle] pathForResource:@"mono8bit" ofType:@"m4a"]
                                 enableStreaming:NO
                                           error:&error],
                  @"Don't throw when trying to load a compressed sound from a valid path");
  STAssertNotNil(sound, @"Load a 8-bit mono compressed sound %@", error);
  STAssertEquals([sound duration], (NSTimeInterval)1, @"Calculate duration for 8-bit mono m4a file");
}

-(void)test8BitStereoM4a
{
  NSError *error = nil;
  FISound* sound = nil;
  STAssertNoThrow(sound = [FISound soundWithPath:[[self soundBundle] pathForResource:@"stereo8bit" ofType:@"m4a"]
                                 enableStreaming:NO
                                           error:&error],
                  @"Don't throw when trying to load a simple sound from a valid path");
  STAssertNotNil(sound, @"Load a 8-bit stereo sound %@", error);
  STAssertEquals([sound duration], (NSTimeInterval)1, @"Calculate duration for 8-bit stereo files");
}

-(void)test16BitMonoM4a
{
  NSError *error = nil;
  FISound* sound = nil;
  STAssertNoThrow(sound = [FISound soundWithPath:[[self soundBundle] pathForResource:@"mono16bit" ofType:@"m4a"]
                                 enableStreaming:NO
                                           error:&error],
                  @"Don't throw when trying to load a simple sound from a valid path");
  STAssertNotNil(sound, @"Load a 16-bit mono sound %@", error);
  STAssertEquals([sound duration], (NSTimeInterval)1, @"Calculate duration for 16-bit mono files");
}

-(void)test16BitStereoM4a
{
  NSError *error = nil;
  FISound* sound = nil;
  STAssertNoThrow(sound = [FISound soundWithPath:[[self soundBundle] pathForResource:@"stereo16bit" ofType:@"m4a"]
                                 enableStreaming:NO
                                           error:&error],
                  @"Don't throw when trying to load a simple sound from a valid path");
  STAssertNotNil(sound, @"Load a 16-bit stereo sound %@", error);
  STAssertEquals([sound duration], (NSTimeInterval)1, @"Calculate duration for 16-bit stereo files");
}

-(void)testCloneSimpleSound
{
  NSError *error = nil;
  FISound* sound = nil;
  STAssertNoThrow(sound = [FISound soundWithPath:[[self soundBundle] pathForResource:@"stereo16bit" ofType:@"m4a"]
                                 enableStreaming:NO
                                           error:&error],
                  @"Don't throw when trying to load a simple sound from a valid path");
  STAssertNotNil(sound, @"Load a 16-bit stereo sound %@", error);
  FISound* sound1 = [sound copy];
  STAssertNotNil(sound1, @"Can't copy sound");
  STAssertEquals([sound path], [sound1 path], @"Path not equals after clone");
}

-(void)testStreamCreation
{
  NSError *error = nil;
  FISound* sound = nil;
  NSString* path = [[self soundBundle] pathForResource:@"stereo16bit" ofType:@"m4a"];
  STAssertNoThrow(sound = [FISound soundWithPath:path
                                 enableStreaming:YES
                                           error:&error],
                  @"Don't throw when trying to load a simple sound from a valid path");
  STAssertNotNil(sound, @"Load a 16-bit stereo sound %@", error);
  STAssertEquals([sound path], path, @"Path not equals");
}

@end
