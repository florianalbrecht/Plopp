//
//  Ball.m
//  Plopp
//
//  Created by Florian Albrecht on 23.02.13.
//  Copyright (c) 2013 Florian Albrecht. All rights reserved.
//

#import "Ball.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+PloppColors.h"

static const CGFloat BallBonusProbability = 1.0;

@implementation Ball

+ (Ball *)ballWithRandomColorAllowBonus:(BOOL)bonus
{
    CGFloat random = arc4random() % 100;
    
    CGFloat colorRange = (100.0 - (bonus ? BallBonusProbability : 0)) / 6;
    
    BallColor color;
    
    if (random < colorRange) {
        color = BallColor1;
    } else if ((random >= colorRange) && (random < 2 * colorRange)) {
        color = BallColor2;
    } else if ((random >= 2 * colorRange) && (random < 3 * colorRange)) {
        color = BallColor3;
    } else if ((random >= 3 * colorRange) && (random < 4 * colorRange)) {
        color = BallColor4;
    } else if ((random >= 4 * colorRange) && (random < 5 * colorRange)) {
        color = BallColor5;
    } else if ((random >= 5 * colorRange) && (random < 6 * colorRange)) {
        color = BallColor6;
    } else {
        color = BallColorBonus;
    }
    
    Ball *ball = [[Ball alloc] initWithColor:color];

    return ball;
}

- (id)initWithColor:(BallColor)color
{
    self = [super initWithFrame:CGRectMake(0, 0, 42.f, 42.f)];
    
    if (self) {
        switch (color) {
            case BallColor1:
                self.backgroundColor = [UIColor psBallColor1];
                break;
            case BallColor2:
                self.backgroundColor = [UIColor psBallColor2];
                break;
            case BallColor3:
                self.backgroundColor = [UIColor psBallColor3];
                break;
            case BallColor4:
                self.backgroundColor = [UIColor psBallColor4];
                break;
            case BallColor5:
                self.backgroundColor = [UIColor psBallColor5];
                break;
            case BallColor6:
                self.backgroundColor = [UIColor psBallColor6];
                break;
            case BallColorBonus:
                self.backgroundColor = [UIColor whiteColor];
                self.image = [UIImage imageNamed:@"bonus"];
                break;
            default:
                break;
        }
        
        _ballColor = color;
        
        self.layer.cornerRadius = 21.f;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[Ball alloc] initWithColor:self.ballColor];
}

- (BOOL)matchesBall:(Ball *)ball
{
    return (self.ballColor == ball.ballColor || self.ballColor == BallColorBonus || ball.ballColor == BallColorBonus);
}

@end
