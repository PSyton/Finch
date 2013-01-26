#import <OpenAL/al.h>

extern NSString *const FIErrorDomain;
extern NSString *const FIOpenALErrorCodeKey;

enum {
  FIErrorNone,
  FIErrorCannotCreateContext,
  FIErrorNoActiveContext,
  FIErrorCannotCreateBuffer,
  FIErrorCannotUploadData,
  FIErrorCannotReadFile,
  FIErrorInvalidSampleFormat,
  FIErrorCannotAllocateMemory,
  FIErrorCannotCreateSoundSource,
  FIErrorFormatNotSupported,
  FIErrorStreaming,
  FIUnknowError
};

@interface FIError : NSObject

+(BOOL)setError:(NSError**)error withMessage:(NSString*)message withCode:(NSInteger)errorCode;
+(BOOL)alErrorWithMessage:(NSString*)message withCode:(NSInteger)errorCode withError: (NSError**)error;
@end