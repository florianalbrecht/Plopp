//
//  Ball.h
//  Plopp
//
//  Created by Florian Albrecht on 23.02.13.
//  Copyright (c) 2013 Florian Albrecht. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BallColor) {
    BallColor1 = 1,
    BallColor2,
    BallColor3,
    BallColor4,
    BallColor5,
    BallColor6,
    BallColorBonus
};

@interface Ball : UIImageView <NSCopying>

@property (assign, nonatomic, readonly) BallColor ballColor;

+ (Ball *)ballWithRandomColorAllowBonus:(BOOL)bonus;

- (id)initWithColor:(BallColor)color;
- (BOOL)matchesBall:(Ball *)ball;

@end
