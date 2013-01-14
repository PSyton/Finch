#import "FIDecoderDelegate.h"
@class FISampleBuffer;

@interface FIDecoder : NSObject <FIDecoderDelegate>

- (NSData*) readDataAtPath: (NSString*) path fileFormat: (AudioStreamBasicDescription*) theOutputFormat error: (NSError**) error;

@end
