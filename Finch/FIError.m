#import "FIError.h"

NSString *const FIErrorDomain = @"FIErrorDomain";
NSString *const FIOpenALErrorCodeKey = @"FIOpenALErrorCodeKey";

@implementation FIError

+(BOOL)setError:(NSError**)error withMessage:(NSString*)message withCode:(NSInteger)errorCode
{
  if (error) {
    *error = [NSError errorWithDomain:FIErrorDomain
                                 code:errorCode
                             userInfo:@{NSLocalizedDescriptionKey: message}];
    return YES;
  }
  return NO;
}

+(BOOL)alErrorWithMessage:(NSString*)message withCode:(NSInteger)errorCode withError: (NSError**)error
{
  ALenum status = alGetError();
  if (AL_NO_ERROR != status)
  {
    if (error) {
      *error = [NSError errorWithDomain:FIErrorDomain
                                   code:errorCode
                               userInfo:@{NSLocalizedDescriptionKey : message,
                  FIOpenALErrorCodeKey : @(status)}];
    }
    return YES;
  }
  return NO;
}

@end