//
//  GameBoardView.m
//  Plopp
//
//  Created by Florian Albrecht on 24.05.13.
//  Copyright (c) 2013 Florian Albrecht. All rights reserved.
//

#import "GameboardView.h"
#import "Ball.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@interface Coordinate : NSObject <NSCopying>

@property (assign, nonatomic) NSInteger x;
@property (assign, nonatomic) NSInteger y;

+ (Coordinate *)coordinateWithX:(NSInteger)x Y:(NSInteger)y;

@end

@implementation Coordinate

+ (Coordinate *)coordinateWithX:(NSInteger)x Y:(NSInteger)y
{
    Coordinate *coordinate = [[Coordinate alloc] init];
    coordinate.x = x;
    coordinate.y = y;
    return coordinate;
}

- (id)copy
{
    return [Coordinate coordinateWithX:self.x Y:self.y];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self copy];
}

- (BOOL)isEqual:(id)object
{
    Coordinate *coordinate = (Coordinate *)object;
    
    if (coordinate.x == self.x && coordinate.y == self.y) {
        return YES;
    }
    
    return NO;
}

@end


@interface GameboardView()

@property (assign, nonatomic) BOOL gameActive;
@property (assign, nonatomic) BOOL containsBonus;
@property (assign, nonatomic, readwrite) BOOL isAnimating;
@property (strong, nonatomic) NSMutableArray *balls;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation GameboardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.clipsToBounds = YES;
        
        self.gameActive = NO;
        
        UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipeLeftRecognizer];
        
        UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeRightRecognizer];
        
        UISwipeGestureRecognizer *swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:swipeUpRecognizer];
        
        UISwipeGestureRecognizer *swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeDownRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        [self addGestureRecognizer:swipeDownRecognizer];
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    }
    
    return self;
}


#pragma mark - Game lifecycle

- (void)startGame
{
    [self createBalls];
    self.gameActive = YES;
}

- (void)stopGame
{
    self.gameActive = NO;
}

- (void)createBalls
{
    self.isAnimating = YES;
    self.containsBonus = NO;
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    self.balls = [[NSMutableArray alloc] init];
    for (NSInteger x = 0; x < self.numberOfBalls; x++) {
        self.balls[x] = [[NSMutableArray alloc] init];
        
        for (NSInteger y = 0; y < self.numberOfBalls; y++) {
            Ball *ball = [Ball ballWithRandomColorAllowBonus:NO];
            self.balls[x][y] = ball;
        }
    }
    
    for (NSInteger y = (self.numberOfBalls - 1); y >= 0; y--) {
        for (NSInteger x = 0; x < self.numberOfBalls; x++) {
            Ball *ball = self.balls[x][y];
            CGPoint ballPosition = [self positionForBallWithX:x y:y];
            ball.center = CGPointMake(ballPosition.x, -22);
            
            [self addSubview:ball];
            
            CGFloat animationDuration = ((ballPosition.y - ball.center.y) / CGRectGetHeight(self.bounds)) * 0.1;
            CGFloat animationDelay = ((self.numberOfBalls - 1 - y) * 0.2) + (x * animationDuration);
            
            [UIView animateWithDuration:animationDuration delay:animationDelay options:
                UIViewAnimationOptionCurveEaseIn animations:^{
                ball.center = ballPosition;
            } completion:^(BOOL finished) {
                if ((x == self.numberOfBalls - 1) && (y == 0)) {
                    [self findAllChains];
                }
            }];
        }
    }
}


#pragma mark - Helper

- (CGPoint)positionForBallWithX:(NSInteger)x y:(NSInteger)y
{
    return CGPointMake(
		(x + 0.5) * ((CGRectGetWidth(self.bounds) - (self.ballInsets.left + self.ballInsets.right)) / self.numberOfBalls) + self.ballInsets.left,
		(y + 0.5) * ((CGRectGetHeight(self.bounds) - (self.ballInsets.top + self.ballInsets.bottom)) / self.numberOfBalls) + self.ballInsets.top
	);
}

- (Coordinate *)coordinateForPosition:(CGPoint)position
{
    CGFloat ballSizeHorizontal = (CGRectGetWidth(self.bounds) - (self.ballInsets.left + self.ballInsets.right)) / self.numberOfBalls;
    CGFloat ballSizeVertical = (CGRectGetHeight(self.bounds) - (self.ballInsets.top + self.ballInsets.bottom)) / self.numberOfBalls;
    
    NSInteger x = (position.x - self.ballInsets.left) / ballSizeHorizontal;
    NSInteger y = (position.y - self.ballInsets.top) / ballSizeVertical;
    
    if ((x < 0) || (x > self.numberOfBalls - 1) ||
        (y < 0) || (y > self.numberOfBalls - 1)) {
        return nil;
    }
    
    return [Coordinate coordinateWithX:x Y:y];
}

- (Ball *)ballForCoordinate:(Coordinate *)coordinate
{
    if ([self.balls[coordinate.x][coordinate.y] isEqual:[NSNull null]]) {
        return nil;
    }
    
    return self.balls[coordinate.x][coordinate.y];
}

- (Coordinate *)neighbourFromCoordinate:(Coordinate *)fromCoordinate inSwipeDirection:(UISwipeGestureRecognizerDirection)direction
{
    Coordinate *toCoordinate = [Coordinate coordinateWithX:fromCoordinate.x Y:fromCoordinate.y];
    
    switch (direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            if (fromCoordinate.x <= 0) {
                return nil;
            }
            toCoordinate.x = fromCoordinate.x - 1;
            break;
        case UISwipeGestureRecognizerDirectionRight:
            if (fromCoordinate.x >= self.numberOfBalls - 1) {
                return nil;
            }
            toCoordinate.x = fromCoordinate.x + 1;
            break;
        case UISwipeGestureRecognizerDirectionDown:
            if (fromCoordinate.y >= self.numberOfBalls - 1) {
                return nil;
            }
            toCoordinate.y = fromCoordinate.y + 1;
            break;
        case UISwipeGestureRecognizerDirectionUp:
            if (fromCoordinate.y <= 0) {
                return nil;
            }
            toCoordinate.y = fromCoordinate.y - 1;
            break;
        default:
            break;
    }
    
    return toCoordinate;
}


#pragma mark - Moves

- (void)handleSwipe:(id)sender
{
    if (!self.gameActive || self.isAnimating) {
        return;
    }
    
    UISwipeGestureRecognizer *recognizer = sender;
    
    CGPoint position = [recognizer locationInView:self];
    
    Coordinate *fromCoordinate = [self coordinateForPosition:position];
    
    if (!fromCoordinate) {
        return;
    }
    
    self.isAnimating = YES;
    
    if ([self isValidMoveFromCoordinate:fromCoordinate inSwipeDirection:recognizer.direction]) {
        Coordinate *toCoordinate = [self neighbourFromCoordinate:fromCoordinate inSwipeDirection:recognizer.direction];
        
        if (toCoordinate) {
            [self swapBallsAtCoordinate1:fromCoordinate coordinate2:toCoordinate];
        } else {
            self.isAnimating = NO;
        }
    } else {
        self.isAnimating = NO;
        [self animationForInvalidMoveAtCoordinate:fromCoordinate forSwipeDirection:recognizer.direction];
    }
}

- (BOOL)isValidMoveFromCoordinate:(Coordinate *)fromCoordinate inSwipeDirection:(UISwipeGestureRecognizerDirection)direction
{
    if ([self moveCompletesChainFromCoordinate:fromCoordinate inSwipeDirection:direction]) {
        return YES;
    }
    
    UISwipeGestureRecognizerDirection oppositeDirection;
    if (direction == UISwipeGestureRecognizerDirectionDown) {
        oppositeDirection = UISwipeGestureRecognizerDirectionUp;
    } else if (direction == UISwipeGestureRecognizerDirectionUp) {
        oppositeDirection = UISwipeGestureRecognizerDirectionDown;
    } else if (direction == UISwipeGestureRecognizerDirectionLeft) {
        oppositeDirection = UISwipeGestureRecognizerDirectionRight;
    } else {
        oppositeDirection = UISwipeGestureRecognizerDirectionLeft;
    }
    
    Coordinate *toCoordinate = [self neighbourFromCoordinate:fromCoordinate inSwipeDirection:direction];
    
    if ([self moveCompletesChainFromCoordinate:toCoordinate inSwipeDirection:oppositeDirection]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)moveCompletesChainFromCoordinate:(Coordinate *)fromCoordinate inSwipeDirection:(UISwipeGestureRecognizerDirection)direction
{
    Coordinate *toCoordinate = [self neighbourFromCoordinate:fromCoordinate inSwipeDirection:direction];
    Ball *movedBall = [self ballForCoordinate:fromCoordinate];
    
    if ((toCoordinate.x >= 2) && (direction != UISwipeGestureRecognizerDirectionRight)) {
        Ball *ball1 = [self ballForCoordinate:[Coordinate coordinateWithX:toCoordinate.x-1 Y:toCoordinate.y]];
        Ball *ball2 = [self ballForCoordinate:[Coordinate coordinateWithX:toCoordinate.x-2 Y:toCoordinate.y]];
        if ([ball1 matchesBall:movedBall] && [ball2 matchesBall:movedBall] && [ball1 matchesBall:ball2]) {
            return YES;
        }
    }
    
    if ((toCoordinate.x <= self.numberOfBalls - 3) && (direction != UISwipeGestureRecognizerDirectionLeft)) {
        Ball *ball1 = [self ballForCoordinate:[Coordinate coordinateWithX:toCoordinate.x+1 Y:toCoordinate.y]];
        Ball *ball2 = [self ballForCoordinate:[Coordinate coordinateWithX:toCoordinate.x+2 Y:toCoordinate.y]];
        if ([ball1 matchesBall:movedBall] && [ball2 matchesBall:movedBall] && [ball1 matchesBall:ball2]) {
            return YES;
        }
    }
    
    if ((toCoordinate.y >= 2) && (direction != UISwipeGestureRecognizerDirectionDown)) {
        Ball *ball1 = [self ballForCoordinate:[Coordinate coordinateWithX:toCoordinate.x Y:toCoordinate.y-1]];
        Ball *ball2 = [self ballForCoordinate:[Coordinate coordinateWithX:toCoordinate.x Y:toCoordinate.y-2]];
        if ([ball1 matchesBall:movedBall] && [ball2 matchesBall:movedBall] && [ball1 matchesBall:ball2]) {
            return YES;
        }
    }
    
    if ((toCoordinate.y <= self.numberOfBalls - 3) && (direction != UISwipeGestureRecognizerDirectionUp)) {
        Ball *ball1 = [self ballForCoordinate:[Coordinate coordinateWithX:toCoordinate.x Y:toCoordinate.y+1]];
        Ball *ball2 = [self ballForCoordinate:[Coordinate coordinateWithX:toCoordinate.x Y:toCoordinate.y+2]];
        if ([ball1 matchesBall:movedBall] && [ball2 matchesBall:movedBall] && [ball1 matchesBall:ball2]) {
            return YES;
        }
    }
    
    if ((toCoordinate.x >= 1) && (toCoordinate.x <= self.numberOfBalls - 2) && (direction != UISwipeGestureRecognizerDirectionLeft) && (direction != UISwipeGestureRecognizerDirectionRight)) {
        Ball *ball1 = [self ballForCoordinate:[Coordinate coordinateWithX:toCoordinate.x-1 Y:toCoordinate.y]];
        Ball *ball2 = [self ballForCoordinate:[Coordinate coordinateWithX:toCoordinate.x+1 Y:toCoordinate.y]];
        if ([ball1 matchesBall:movedBall] && [ball2 matchesBall:movedBall] && [ball1 matchesBall:ball2]) {
            return YES;
        }
    }
    
    if ((toCoordinate.y >= 1) && (toCoordinate.y <= self.numberOfBalls - 2) && (direction != UISwipeGestureRecognizerDirectionDown) && (direction != UISwipeGestureRecognizerDirectionUp)) {
        Ball *ball1 = [self ballForCoordinate:[Coordinate coordinateWithX:toCoordinate.x Y:toCoordinate.y-1]];
        Ball *ball2 = [self ballForCoordinate:[Coordinate coordinateWithX:toCoordinate.x Y:toCoordinate.y+1]];
        if ([ball1 matchesBall:movedBall] && [ball2 matchesBall:movedBall] && [ball1 matchesBall:ball2]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)swapBallsAtCoordinate1:(Coordinate *)coordinate1 coordinate2:(Coordinate *)coordinate2
{
    Ball *ball1 = [self ballForCoordinate:coordinate1];
    Ball *ball2 = [self ballForCoordinate:coordinate2];
    
    CGPoint ball1Center = ball1.center;
    
    [UIView animateWithDuration:0.15 animations:^{
        ball1.center = ball2.center;
        ball2.center = ball1Center;
    } completion:^(BOOL finished) {
        self.balls[coordinate1.x][coordinate1.y] = ball2;
        self.balls[coordinate2.x][coordinate2.y] = ball1;
        
        [self findAllChains];
    }];
}

- (void)animationForInvalidMoveAtCoordinate:(Coordinate *)coordinate forSwipeDirection:(UISwipeGestureRecognizerDirection)direction
{
    Ball *ball = [self ballForCoordinate:coordinate];
    [self bringSubviewToFront:ball];
    
    NSString *keypath = nil;
    CGFloat baseValue;
    CGFloat offset = 20.f;
    
    if (direction == UISwipeGestureRecognizerDirectionLeft || direction == UISwipeGestureRecognizerDirectionRight) {
        keypath = @"position.x";
        baseValue = ball.center.x;
    } else {
        keypath = @"position.y";
        baseValue = ball.center.y;
    }
    
    if (direction == UISwipeGestureRecognizerDirectionLeft || direction == UISwipeGestureRecognizerDirectionUp) {
        offset = -offset;
    }
    
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:keypath];
    moveAnimation.fromValue = [NSNumber numberWithFloat:baseValue];
    moveAnimation.toValue = [NSNumber numberWithFloat:baseValue + offset];
    moveAnimation.duration = 0.15;
    
    CABasicAnimation *bounceAnimation = [CABasicAnimation animationWithKeyPath:keypath];
    bounceAnimation.fromValue = [NSNumber numberWithFloat:baseValue + offset];
    bounceAnimation.toValue = [NSNumber numberWithFloat:baseValue];
    bounceAnimation.duration = 0.2;
    bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.5 :2 :1 :1];
    bounceAnimation.beginTime = moveAnimation.duration;
    
    CAAnimationGroup* group = [CAAnimationGroup animation];
    group.duration = moveAnimation.duration + bounceAnimation.duration;
    group.animations = @[moveAnimation, bounceAnimation];
    [ball.layer addAnimation:group forKey:nil];
}

- (BOOL)movesPossible
{
    for (NSInteger x = 0; x < [self.balls count]; x++) {
        for (NSInteger y = 0; y < [self.balls[x] count]; y++) {
            Coordinate *coordinate = [Coordinate coordinateWithX:x Y:y];
            
            if ([self isValidMoveFromCoordinate:coordinate inSwipeDirection:UISwipeGestureRecognizerDirectionDown]) {
                return YES;
            }
            
            if ([self isValidMoveFromCoordinate:coordinate inSwipeDirection:UISwipeGestureRecognizerDirectionLeft]) {
                return YES;
            }
            
            if ([self isValidMoveFromCoordinate:coordinate inSwipeDirection:UISwipeGestureRecognizerDirectionRight]) {
                return YES;
            }
            
            if ([self isValidMoveFromCoordinate:coordinate inSwipeDirection:UISwipeGestureRecognizerDirectionUp]) {
                return YES;
            }
        }
    }
    
    return NO;
}


#pragma mark - Chains

- (void)findAllChains
{
    NSMutableArray *balls = [[NSMutableArray alloc] init];
    
    [balls addObjectsFromArray:[self findChainsHorizontal:YES]];
    
    NSArray *verticalChains = [self findChainsHorizontal:NO];
    
    for (Ball *ball in verticalChains) {
        if (![balls containsObject:ball]) {
            [balls addObject:ball];
        }
    }
    
    if (balls.count > 0) {
        [self clearBallsAtCoordinates:balls];
    } else {
        self.isAnimating = NO;
        if ([self.delegate respondsToSelector:@selector(gameBoardDidFinishAnimating)]) {
            [self.delegate gameBoardDidFinishAnimating];
        }
        
        if (![self movesPossible]) {
            [self performSelector:@selector(shuffleGameboard) withObject:nil afterDelay:0.5];
        }
    }
}

- (NSArray *)findChainsHorizontal:(BOOL)horizontal
{
    NSMutableArray *balls = [NSMutableArray array];
    NSMutableArray *currentCoordinates = nil;
    
    BallColor currentColor;
    
    for (NSInteger x = 0; x < self.numberOfBalls; x++) {
        Coordinate *firstBallCoordinate = horizontal ? [Coordinate coordinateWithX:0 Y:x] : [Coordinate coordinateWithX:x Y:0];
        currentColor = [self ballForCoordinate:firstBallCoordinate].ballColor;
        currentCoordinates = [NSMutableArray arrayWithObject:firstBallCoordinate];
        
        for (NSInteger y = 1; y < self.numberOfBalls; y++) {
            Coordinate *currentCoordinate = horizontal ? [Coordinate coordinateWithX:y Y:x] : [Coordinate coordinateWithX:x Y:y];
            Ball *currentBall = [self ballForCoordinate:currentCoordinate];
            
            if (currentColor == BallColorBonus) {
                currentColor = currentBall.ballColor;
            }
            
            if (currentBall.ballColor == currentColor || currentBall.ballColor == BallColorBonus) {
                [currentCoordinates addObject:currentCoordinate];
            } else {
                if ([currentCoordinates count] >= 3) {
                    [balls addObjectsFromArray:currentCoordinates];
                }
                
                currentCoordinates = [NSMutableArray arrayWithObject:currentCoordinate];
                                
                Coordinate *previousCoordinate = horizontal ? [Coordinate coordinateWithX:y-1 Y:x] : [Coordinate coordinateWithX:x Y:y-1];
                if ([self ballForCoordinate:previousCoordinate].ballColor == BallColorBonus) {
                    [currentCoordinates addObject:previousCoordinate];
                }
                
                currentColor = currentBall.ballColor;
            }
        }
        
        if ([currentCoordinates count] >= 3) {
            [balls addObjectsFromArray:currentCoordinates];
        }
    }
    
    return balls;
}

- (void)clearBallsAtCoordinates:(NSArray *)coordinates
{
    [self playSound];
    
    __block BOOL clearedBonus = NO;
    
    __block NSInteger animationsCount = [coordinates count];
    for (Coordinate *coordinate in coordinates) {
        Ball *oldBall = [self ballForCoordinate:coordinate];
        
        [UIView animateWithDuration:0.2 animations:^{
            oldBall.frame = CGRectMake(oldBall.center.x, oldBall.center.y, 0, 0);
        } completion:^(BOOL finished) {
            if (oldBall.ballColor == BallColorBonus) {
                self.containsBonus = NO;
                clearedBonus = YES;
            }
            
            [oldBall removeFromSuperview];
            self.balls[coordinate.x][coordinate.y] = [NSNull null];
            
            animationsCount--;
            
            if (animationsCount == 0) {
                if ([self.delegate respondsToSelector:@selector(gameBoardDidClearBalls:includesBonus:)]) {
                    [self.delegate gameBoardDidClearBalls:[coordinates count] includesBonus:clearedBonus];
                }
                
                [self fillEmptyPositions];
            }
        }];
    }
}

- (void)fillEmptyPositions
{
    for (NSInteger x = 0; x < [self.balls count]; x++) {
        for (NSInteger y = [self.balls[x] count] - 2; y >= 0 ; y--) {
            if ([self.balls[x][y] isEqual:[NSNull null]]) {
                continue;
            }
            
            NSInteger testY = y + 1;
            BOOL move = NO;
            
            while (testY < [self.balls[x] count] && [self.balls[x][testY] isEqual:[NSNull null]]) {
                testY++;
                move = YES;
            }
            
            if (move) {
                self.balls[x][testY - 1] = self.balls[x][y];
                self.balls[x][y] = [NSNull null];
            }
        }
    }
    
    __block NSInteger animationCount = 0;
    for (NSInteger x = 0; x < [self.balls count]; x++) {
        for (NSInteger y = 0; y < [self.balls[x] count]; y++) {
            animationCount++;
            
            if ([self.balls[x][y] isEqual:[NSNull null]]) {
                Ball *newBall = [Ball ballWithRandomColorAllowBonus:!self.containsBonus];
                newBall.center = CGPointMake([self positionForBallWithX:x y:y].x, -50.f);
                [self addSubview:newBall];
                self.balls[x][y] = newBall;
                
                if (newBall.ballColor == BallColorBonus) {
                    self.containsBonus = YES;
                }
            }
        }
    }
    
    for (NSInteger y = [self.balls[0] count] - 1; y >= 0; y--) {
        for (NSInteger x = 0; x < [self.balls count]; x++) {
            Ball *ball = self.balls[x][y];
            
            [UIView animateWithDuration:0.1 animations:^{
                ball.center = [self positionForBallWithX:x y:y];
                
                animationCount--;
                
                if (animationCount == 0) {
                    [self findAllChains];
                }
            }];
        }
    }
}

- (BOOL)shuffleGameboard
{
    if (!self.gameActive || self.isAnimating) {
        return NO;
    }
    
    self.isAnimating = YES;
    
    NSMutableArray *fromPositions = [NSMutableArray array];
    for (NSInteger x = 0; x < [self.balls count]; x++) {
        for (NSInteger y = 0; y < [self.balls[x] count]; y++) {
            [fromPositions addObject:[Coordinate coordinateWithX:x Y:y]];
        }
    }
    NSMutableArray *toPositions = [[NSMutableArray alloc] initWithArray:fromPositions copyItems:YES];
    
    NSMutableArray *newBallsArray = [NSMutableArray array];
    for (NSInteger x = 0; x < self.numberOfBalls; x++) {
        newBallsArray[x] = [NSMutableArray array];
        
        for (NSInteger y = 0; y < self.numberOfBalls; y++) {
            newBallsArray[x][y] = [NSNull null];
        }
    }
    
    for (NSInteger x = 0; x < [newBallsArray count]; x++) {
        for (NSInteger y = 0; y < [newBallsArray[x] count]; y++) {
            NSInteger randomFrom = arc4random() % [fromPositions count];
            Coordinate *fromCoordinate = fromPositions[randomFrom];
            [fromPositions removeObjectAtIndex:randomFrom];
            
            newBallsArray[x][y] = self.balls[fromCoordinate.x][fromCoordinate.y];
        }
    }
    
    self.balls = newBallsArray;
    
    __block NSInteger count = 0;
    __block NSInteger numberOfAnimations = [toPositions count];
    
    while ([toPositions count] > 0) {
        NSInteger randomTo = arc4random() % [toPositions count];
        Coordinate *toCoordinate = toPositions[randomTo];
        [toPositions removeObjectAtIndex:randomTo];
        
        Ball *ball = self.balls[toCoordinate.x][toCoordinate.y];
        
        [UIView animateWithDuration:0.075 delay:count * 0.01 options:UIViewAnimationOptionCurveEaseIn animations:^{
            ball.center = [self positionForBallWithX:toCoordinate.x y:toCoordinate.y];
            count++;
        } completion:^(BOOL finished) {
            numberOfAnimations--;
            
            if (numberOfAnimations == 0) {
                [self findAllChains];
            }
        }];
    }
    
    return YES;
}


#pragma mark - Sounds

- (void)playSound
{
    NSString *filename;
    
    CGFloat random = arc4random() % 4;
    
    if (random < 1) {
        filename = @"plopp01";
    } else if ((random >=1) && (random < 2)) {
        filename = @"plopp02";
    } else {
        filename = @"plopp03";
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.audioPlayer.volume = 1.0;
    
    [self.audioPlayer play];
}

@end
