#import "FIError.h"

NSString* const FIErrorDomain = @"FIErrorDomain";
NSString* const FIOpenALErrorCodeKey = @"FIOpenALErrorCodeKey";
NSString* const FIOpenALErrorDescriptionKey = @"FIOpenALErrorDescriptionKey";

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
      NSString* errorDesc = [NSString stringWithCString:alGetString(status)
                                               encoding:NSWindowsCP1251StringEncoding];
      *error = [NSError errorWithDomain:FIErrorDomain
                                   code:errorCode
                               userInfo:@{NSLocalizedDescriptionKey: message,
                                               FIOpenALErrorCodeKey: @(status),
                                        FIOpenALErrorDescriptionKey: errorDesc}];
    }
    return YES;
  }
  return NO;
}

@end