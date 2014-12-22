//
//  ScoreView.m
//  Plopp
//
//  Created by Florian Albrecht on 25.05.13.
//  Copyright (c) 2013 Florian Albrecht. All rights reserved.
//

#import "ScoreView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+PloppColors.h"

@interface ScoreView()

@property (assign, nonatomic) NSInteger leftScore;
@property (assign, nonatomic) NSInteger rightScore;
@property (strong, nonatomic) UIView *leftBar;
@property (strong, nonatomic) UIView *rightBar;
@property (strong, nonatomic) UILabel *leftScoreLabel;
@property (strong, nonatomic) UILabel *rightScoreLabel;

- (void)resizeBars;

@end

@implementation ScoreView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.rightBar = [[UIImageView alloc] init];
        self.rightBar.backgroundColor = [UIColor psBlueColor];
        self.rightBar.layer.cornerRadius = 21.f;
        [self addSubview:self.rightBar];
        
        self.leftBar = [[UIImageView alloc] init];
        self.leftBar.backgroundColor = [UIColor psGreenColor];
        self.leftBar.layer.cornerRadius = 21.f;
        [self addSubview:self.leftBar];
        
        self.leftScoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.leftScoreLabel.backgroundColor = [UIColor clearColor];
        self.leftScoreLabel.textColor = [UIColor whiteColor];
        self.leftScoreLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13];
        [self.leftBar addSubview:self.leftScoreLabel];
        
        self.rightScoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.rightScoreLabel.backgroundColor = [UIColor clearColor];
        self.rightScoreLabel.textColor = [UIColor whiteColor];
        self.rightScoreLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13];
        [self.rightBar addSubview:self.rightScoreLabel];
    }
    
    return self;
}

- (void)setLeftScore:(NSInteger)leftScore WithAnimation:(BOOL)animation
{
    NSInteger oldLeftscore = _leftScore;
    
    _leftScore = leftScore;
    
    self.leftScoreLabel.text = [NSString stringWithFormat:@"%li", (long)leftScore];
    
    CGFloat animationDuration = animation ? 0.5 : 0.f;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self resizeBars];
    } completion:^(BOOL finished) {
        if (_rightScore > 0 && oldLeftscore <= _rightScore && _leftScore > _rightScore) {
            [self bounceLeftBar];
        }
    }];
}

- (void)setRightScore:(NSInteger)rightScore WithAnimation:(BOOL)animation
{
    _rightScore = rightScore;
    
    self.rightScoreLabel.text = [NSString stringWithFormat:@"%li", (long)rightScore];
    
    CGFloat animationDuration = animation ? 0.5 : 0.f;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self resizeBars];
    }];
}

- (void)resizeBars
{
    [self.leftScoreLabel sizeToFit];
    
    if (self.rightScore == 0) {
        self.leftBar.frame = CGRectMake(0, 0, self.frame.size.width, 42);
        self.rightBar.frame = CGRectNull;
    } else {
        [self.rightScoreLabel sizeToFit];
        
        CGFloat minBarWidth = MAX(self.leftScoreLabel.frame.size.width, self.rightScoreLabel.frame.size.width) + 42;
        
        CGFloat leftBarWidth = ((float)self.leftScore / (self.leftScore + self.rightScore)) * (self.frame.size.width - (2 * minBarWidth));
        
        self.leftBar.frame = CGRectMake(0, 0, leftBarWidth + minBarWidth, 42);
        self.rightBar.frame = CGRectMake(self.leftBar.frame.size.width, 0, self.frame.size.width - self.leftBar.frame.size.width, 42);
        
        self.rightScoreLabel.center = CGPointMake(CGRectGetMidX(self.rightBar.bounds), CGRectGetMidY(self.rightBar.bounds));
    }
    
    self.leftScoreLabel.center = CGPointMake(CGRectGetMidX(self.leftBar.bounds), CGRectGetMidY(self.leftBar.bounds));
}

- (void)bounceLeftBar
{
    [UIView animateWithDuration:0.2 animations:^{
        self.leftBar.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.leftBar.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 animations:^{
                self.leftBar.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.15, 1.15);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.15 animations:^{
                    self.leftBar.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                }];
            }];
        }];
    }];
}

@end
