//
//  ScoreView.h
//  Plopp
//
//  Created by Florian Albrecht on 25.05.13.
//  Copyright (c) 2013 Florian Albrecht. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreView : UIView

- (void)setLeftScore:(NSInteger)leftScore WithAnimation:(BOOL)animation;
- (void)setRightScore:(NSInteger)rightScore WithAnimation:(BOOL)animation;

@end
