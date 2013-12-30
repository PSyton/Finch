//
//  FIVector.h
//  Finch
//
//  Created by Sysolyatin Pavel on 1/20/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FIVector : NSObject
@property(nonatomic) CGFloat x;
@property(nonatomic) CGFloat y;
@property(nonatomic) CGFloat z;

+(id)vector;
+(id)vectorWithX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z;
@end
