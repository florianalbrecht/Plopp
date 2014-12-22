//
//  GameViewController.m
//  Plopp
//
//  Created by Florian Albrecht on 22.02.13.
//  Copyright (c) 2013 Florian Albrecht. All rights reserved.
//

#import "GameViewController.h"
#import "GameboardView.h"
#import "ScoreView.h"
#import "UIColor+PloppColors.h"
#import "UIFont+PloppFonts.h"

static const NSInteger GameViewControllerTimeLimit = 60;
static NSString *const UserDefaultsHighscore = @"UserDefaultsHighscore";

@interface GameViewController () <GameBoardViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) GameboardView *gameBoard;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) ScoreView *scoreView;
@property (strong, nonatomic) UIProgressView *progressView;

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL gameActive;
@property (assign, nonatomic) BOOL timeOver;
@property (assign, nonatomic) NSInteger time;

@property (assign, nonatomic) NSInteger currentTimeLimit;
@property (assign, nonatomic) NSInteger highscore;
@property (assign, nonatomic) NSInteger score;

@end

@implementation GameViewController

- (id)init
{
    self = [super init];
    
    if (self) {
        _highscore = [[NSUserDefaults standardUserDefaults] integerForKey:UserDefaultsHighscore];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    [super loadView];
    
    self.title = @"Plopp";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.gameBoard = [[GameboardView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds) + 40.f)];
    self.gameBoard.numberOfBalls = 7;
    self.gameBoard.ballInsets = UIEdgeInsetsMake(20.f, 3.f, 20.f, 3.f);
    self.gameBoard.delegate = self;
    [self.view addSubview:self.gameBoard];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.f, CGRectGetHeight(self.view.bounds) - 73.f, CGRectGetWidth(self.view.bounds), 75.f)];
    self.bottomView.backgroundColor = [UIColor colorWithRed:252/255.f green:252/255.f blue:252/255.f alpha:1.f];
    self.bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.bottomView];
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(self.view.bounds), self.progressView.frame.size.height);
    self.progressView.trackTintColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    [self.bottomView addSubview:self.progressView];
    
    self.scoreView = [[ScoreView alloc] initWithFrame:CGRectMake(5.f, 17.f, CGRectGetWidth(self.view.bounds) - 10.f, 40.f)];
    [self.bottomView addSubview:self.scoreView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    self.gameBoard.center = CGPointMake(self.gameBoard.center.x, CGRectGetMidY(self.view.frame) - 70.f);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startGame];
}


#pragma mark - Game progess

- (void)startGame
{
    self.time = 0;
    self.score = 0;
    self.currentTimeLimit = GameViewControllerTimeLimit;
    self.timeOver = NO;

    [self.scoreView setLeftScore:0 WithAnimation:NO];
    [self.scoreView setRightScore:self.highscore WithAnimation:NO];
    
    [self.gameBoard startGame];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(timerFired)
                                                userInfo:nil
                                                 repeats:YES];
    
    self.gameActive = YES;
}

- (void)timerFired
{
    if (!self.gameActive) {
        return;
    }
    
    self.time++;
    
    CGFloat progress = (float)self.time / self.currentTimeLimit;
    [self.progressView setProgress:progress animated:YES];
    
    if (self.time >= self.currentTimeLimit - 10 && self.time <= self.currentTimeLimit) {
        [self bounceProgressView];
    }
    
    if (self.time >= self.currentTimeLimit) {
        [self gameEnded];
    }
}

- (void)gameEnded
{
    self.gameActive = NO;
    
    if (self.gameBoard.isAnimating) {
        self.timeOver = YES;
        return;
    }
    
    [self.timer invalidate];
    
    [self.gameBoard stopGame];
    
    NSString *alertText = nil;
    
    if (self.score > self.highscore) {
        self.highscore = self.score;
        
        [[NSUserDefaults standardUserDefaults] setInteger:self.highscore forKey:UserDefaultsHighscore];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        alertText = [NSString stringWithFormat:@"New highscore: %li", (long)self.score];
    } else {
        alertText = [NSString stringWithFormat:@"Score: %li", (long)self.score];
    }
    
    [[[UIAlertView alloc] initWithTitle:alertText message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Play again", nil] show];
}


#pragma mark - Animations

- (void)bounceProgressView
{
    [UIView animateWithDuration:0.1 animations:^{
        self.progressView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.5);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.progressView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)timeBonusIndicator
{
    UILabel *indicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) / 2 - 25.f, CGRectGetMinY(self.bottomView.frame) - 10.f, 50.f, 20.f)];
    indicatorLabel.alpha = 0.f;
    indicatorLabel.text = @"+10";
    indicatorLabel.font = [UIFont psMediumMainFontWithSize:18.f];
    indicatorLabel.textColor = [UIColor psDefaultTintColor];
    [self.view addSubview:indicatorLabel];
    
    [UIView animateKeyframesWithDuration:1.f delay:0.f options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.f relativeDuration:0.1 animations:^{
            indicatorLabel.frame = CGRectOffset(indicatorLabel.frame, 0.f, -20.f);
            indicatorLabel.alpha = 1.f;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.1 relativeDuration:0.1 animations:^{
            indicatorLabel.frame = CGRectOffset(indicatorLabel.frame, 0.f, -20.f);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.4 animations:^{
            indicatorLabel.frame = CGRectOffset(indicatorLabel.frame, 20.f, -20.f);
            indicatorLabel.alpha = 0.7;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.6 relativeDuration:0.4 animations:^{
            indicatorLabel.frame = CGRectOffset(indicatorLabel.frame, 0.f, -20.f);
            indicatorLabel.alpha = 0.f;
        }];
    } completion:nil];
}


#pragma mark - GameBoardViewDelegate

- (void)gameBoardDidClearBalls:(NSInteger)numberOfBalls includesBonus:(BOOL)bonus
{
    self.score += numberOfBalls;
    
    if (bonus) {
        self.currentTimeLimit += 10;
        [self timeBonusIndicator];
    }
}

- (void)gameBoardDidFinishAnimating
{
    [self.scoreView setLeftScore:self.score WithAnimation:YES];
    
    if (self.timeOver) {
        [self gameEnded];
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self startGame];
}

@end
