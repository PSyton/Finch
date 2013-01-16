#import <OpenAL/al.h>
#define FI_INIT_ERROR_IF_NULL(error) error = error ? error : &(NSError*){ nil }
#define alClearError alGetError

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
    FIUnknowError
};

@interface FIError : NSObject

+ (id) errorWithMessage: (NSString*) message code: (NSUInteger) errorCode;
+ (id) errorWithMessage: (NSString*) message code: (NSUInteger) errorCode OpenALCode: (ALenum) underlyingCode;

@end