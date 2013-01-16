#import "FISound.h"
#import "FIStreamFactoryDelegate.h"

@class FIVector;

@interface FISoundEngine : NSObject <FIStreamFactoryDelegate>

@property(strong) NSBundle *soundBundle;
@property(assign, nonatomic, getter = isSuspended) BOOL suspended;
@property(copy, nonatomic) FIVector* listenerPosition;
+(id)sharedEngine;

-(id<FIStreamProtocol>)createStreamWithPath:(NSString*)path error:(NSError**)error;

-(BOOL)registerStreamFactory: (id <FIStreamFactoryDelegate>)factory;
-(BOOL)unregisterStreamFactory: (id <FIStreamFactoryDelegate>)factory;
@end