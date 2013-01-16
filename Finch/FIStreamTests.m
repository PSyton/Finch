//
//  FIStreamTests.m
//  Finch
//
//  Created by Sysolyatin Pavel on 1/19/13.
//
//

#import "FITestCase.h"
#import "FIDefaultStream.h"

@interface FIStreamTests : FITestCase
@end


@implementation FIStreamTests

-(void)testInitializationWithNilPath
{
  FIStream *stream = nil;
  NSError* error = nil;
  STAssertNoThrow(stream = [[FIDefaultStream alloc] initWithPath:nil error:&error],
                  @"Do not throw when trying to load a sound from a nil path");
  STAssertNil(stream, @"Return nil when loading a sound from a nil path");
}

-(void)test8BitMonoWave
{
  NSError *error = nil;
  FIDefaultStream* stream = nil;
  
  STAssertNoThrow(stream = [[FIDefaultStream alloc] initWithPath:[[self soundBundle] pathForResource:@"mono8bit" ofType:@"wav"]
                                                    error:&error],
                  @"Don't throw when trying to load a simple sound from a valid path");
  STAssertNotNil(stream, @"Load a 8-bit mono sound %@", error);
  STAssertEquals([stream sampleRate], (NSUInteger)44100, @"Detect sample rate for 8-bit mono files");
  STAssertEquals([stream sampleFormat], FISampleFormatMono8, @"Detect sample format for 8-bit mono files");
  STAssertEquals([stream bytesPerSample], (NSUInteger)1, @"Detect bytes per sample for 8-bit mono files");
}


-(void)test8BitStereoWave
{
  NSError *error = nil;
  FIDefaultStream* stream = nil;
  STAssertNoThrow(stream = [[FIDefaultStream alloc] initWithPath:[[self soundBundle] pathForResource:@"stereo8bit" ofType:@"wav"]
                                                    error:&error],
                  @"Don't throw when trying to load a simple sound from a valid path");
  STAssertNotNil(stream, @"Load a 8-bit stereo sound %@", error);
  STAssertEquals([stream sampleRate], (NSUInteger)44100, @"Detect sample rate for 8-bit stereo files");
  STAssertEquals([stream sampleFormat], FISampleFormatStereo8, @"Detect sample format for 8-bit stereo files");
  STAssertEquals([stream bytesPerSample], (NSUInteger)2, @"Detect bytes per sample for 8-bit stereo files");
}

-(void)test16BitMonoWave
{
  NSError *error = nil;
  FIDefaultStream* stream = nil;
  STAssertNoThrow(stream = [[FIDefaultStream alloc] initWithPath:[[self soundBundle] pathForResource:@"mono16bit" ofType:@"wav"]
                                                    error:&error],
                  @"Don't throw when trying to load a simple sound from a valid path");
  STAssertNotNil(stream, @"Load a 16-bit mono sound %@", error);
  STAssertEquals([stream sampleRate], (NSUInteger)44100, @"Detect sample rate for 16-bit mono files");
  STAssertEquals([stream sampleFormat], FISampleFormatMono16, @"Detect sample format for 16-bit mono files");
  STAssertEquals([stream bytesPerSample], (NSUInteger)2, @"Detect bytes per sample for 16-bit mono files");
}

-(void)test16BitStereoWave
{
  NSError *error = nil;
  FIDefaultStream* stream = nil;
  STAssertNoThrow(stream = [[FIDefaultStream alloc] initWithPath:[[self soundBundle] pathForResource:@"stereo16bit" ofType:@"wav"]
                                                    error:&error],
                  @"Don't throw when trying to load a simple sound from a valid path");
  STAssertNotNil(stream, @"Load a 16-bit stereo sound %@", error);
  STAssertEquals([stream sampleRate], (NSUInteger)44100, @"Detect sample rate for 16-bit stereo files");
  STAssertEquals([stream sampleFormat], FISampleFormatStereo16, @"Detect sample format for 16-bit stereo files");
  STAssertEquals([stream bytesPerSample], (NSUInteger)4, @"Detect bytes per sample for 16-bit stereo files");
}

- (void) test8BitMonoM4a
{
  NSError *error = nil;
  FIDefaultStream* stream = nil;
  STAssertNoThrow(stream = [[FIDefaultStream alloc] initWithPath:[[self soundBundle] pathForResource:@"mono8bit" ofType:@"m4a"]
                                                    error:&error],
                  @"Don't throw when trying to load a compressed sound from a valid path");
  STAssertNotNil(stream, @"Load a 8-bit mono compressed sound %@", error);
  STAssertEquals([stream sampleRate], (NSUInteger)44100, @"Detect sample rate for 8-bit mono m4a file");
  STAssertEquals([stream sampleFormat], FISampleFormatMono16, @"Detect sample format for 8-bit mono m4a file");
  STAssertEquals([stream bytesPerSample], (NSUInteger)2, @"Detect bytes per sample for 8-bit mono m4a file");
}

-(void)test8BitStereoM4a
{
  NSError *error = nil;
  FIDefaultStream* stream = nil;
  STAssertNoThrow(stream = [[FIDefaultStream alloc] initWithPath:[[self soundBundle] pathForResource:@"stereo8bit" ofType:@"m4a"]
                                                    error:&error],
                  @"Don't throw when trying to load a simple sound from a valid path");
  STAssertNotNil(stream, @"Load a 8-bit stereo sound %@", error);
  STAssertEquals([stream sampleRate], (NSUInteger)44100, @"Detect sample rate for 8-bit stereo files");
  STAssertEquals([stream sampleFormat], FISampleFormatStereo16, @"Detect sample format for 8-bit stereo files");
  STAssertEquals([stream bytesPerSample], (NSUInteger)4, @"Detect bytes per sample for 8-bit stereo files");
}

-(void)test16BitMonoM4a
{
  NSError *error = nil;
  FIDefaultStream* stream = nil;
  STAssertNoThrow(stream = [[FIDefaultStream alloc] initWithPath:[[self soundBundle] pathForResource:@"mono16bit" ofType:@"m4a"]
                                                    error:&error],
                  @"Don't throw when trying to load a simple sound from a valid path");
  STAssertNotNil(stream, @"Load a 16-bit mono sound %@", error);
  STAssertEquals([stream sampleRate], (NSUInteger)44100, @"Detect sample rate for 16-bit mono files");
  STAssertEquals([stream sampleFormat], FISampleFormatMono16, @"Detect sample format for 16-bit mono files");
  STAssertEquals([stream bytesPerSample], (NSUInteger)2, @"Detect bytes per sample for 16-bit mono files");
}

-(void)test16BitStereoM4a
{
  NSError *error = nil;
  FIDefaultStream* stream = nil;
  STAssertNoThrow(stream = [[FIDefaultStream alloc] initWithPath:[[self soundBundle] pathForResource:@"stereo16bit" ofType:@"m4a"]
                                           error:&error],
                  @"Don't throw when trying to load a simple sound from a valid path");
  STAssertNotNil(stream, @"Load a 16-bit stereo sound %@", error);
  STAssertEquals([stream sampleRate], (NSUInteger)44100, @"Detect sample rate for 16-bit stereo files");
  STAssertEquals([stream sampleFormat], FISampleFormatStereo16, @"Detect sample format for 16-bit stereo files");
  STAssertEquals([stream bytesPerSample], (NSUInteger)4, @"Detect bytes per sample for 16-bit stereo files");
}

@end
