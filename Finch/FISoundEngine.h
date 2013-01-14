#import "FISound.h"
#import "FIDecoderDelegate.h"

@interface FISoundEngine : NSObject <FIDecoderDelegate>

@property(strong) NSBundle *soundBundle;
@property(assign, nonatomic, getter = isSuspended) BOOL suspended;

+ (id) sharedEngine;

//- (FISound*) soundNamed: (NSString*) soundName maxPolyphony: (NSUInteger) voices error: (NSError**) error;
//- (FISound*) soundNamed: (NSString*) soundName error: (NSError**) error;

- (BOOL) registerDecoder: (id <FIDecoderDelegate>) decoder;
- (BOOL) unregisterDecoder: (id <FIDecoderDelegate>) decoder;
@end