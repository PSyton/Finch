#import "FIStreamFactoryDelegate.h"

@class FISampleBuffer;

@interface FIDefaultStreamFactory
  : NSObject <FIStreamFactoryDelegate>
-(id<FIStreamProtocol>)createStreamWithPath:(NSString*)path error:(NSError**)error;
@end
