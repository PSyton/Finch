#import "FITestCase.h"
#import "FISampleBuffer.h"
#import "FISoundContext.h"
#import "FISoundDevice.h"

@interface FISampleBufferTests : FITestCase
@end

@implementation FISampleBufferTests

- (void) testInitializationWithNilData
{
    FISampleBuffer *buffer = [[FISampleBuffer alloc] initWithData:nil
        sampleRate:0 sampleFormat:FISampleFormatMono8 error:NULL];
    STAssertNil(buffer, @"Creating buffer with nil data returns nil");
}

@end
