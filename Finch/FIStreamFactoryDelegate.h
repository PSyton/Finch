//
//  FISoundDecoderDelegate.h
//  Finch
//
//  Created by Sysolyatin Pavel on 1/14/13.
//
//
#import <Foundation/Foundation.h>

@protocol FIStreamProtocol;

@protocol FIStreamFactoryDelegate <NSObject>

@required
-(id<FIStreamProtocol>)createStreamWithPath:(NSString*)path error: (NSError**)error;
@end
