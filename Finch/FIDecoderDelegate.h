//
//  FISoundDecoderDelegate.h
//  Finch
//
//  Created by Sysolyatin Pavel on 1/14/13.
//
//

#ifndef Finch_FISoundDecoderDelegate_h
#define Finch_FISoundDecoderDelegate_h

@class FISampleBuffer;

@protocol FIDecoderDelegate <NSObject>

@required
-(FISampleBuffer*)decodeAtPath:(NSString*) path error: (NSError**) error;
@end
#endif
