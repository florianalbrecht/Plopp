//
//  GameBoardView.h
//  Plopp
//
//  Created by Florian Albrecht on 24.05.13.
//  Copyright (c) 2013 Florian Albrecht. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameboardView : UIView

@property (weak, nonatomic) id delegate;

@property (assign, nonatomic) NSInteger numberOfBalls;
@property (assign, nonatomic) UIEdgeInsets ballInsets;

@property (assign, nonatomic, readonly) BOOL isAnimating;

- (void)startGame;
- (void)stopGame;

@end


@protocol GameBoardViewDelegate

- (void)gameBoardDidClearBalls:(NSInteger)numberOfBalls includesBonus:(BOOL)bonus;
- (void)gameBoardDidFinishAnimating;

@end