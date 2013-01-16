#import "FIDefaultStreamFactory.h"
#import "FISampleBuffer.h"
#import "FIError.h"
#import "FIDefaultStream.h"

@implementation FIDefaultStreamFactory

-(id<FIStreamProtocol>)createStreamWithPath:(NSString*)path error: (NSError**)error
{
  return [[FIDefaultStream alloc] initWithPath:path error:error];
}
@end
