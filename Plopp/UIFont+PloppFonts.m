//
//  UIFont+PloppFonts.m
//  Plopp
//
//  Created by Florian Albrecht on 13.10.13.
//  Copyright (c) 2013 Florian Albrecht. All rights reserved.
//

#import "UIFont+PloppFonts.h"

@implementation UIFont (PloppFonts)

+ (UIFont *)psMainFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirNext-Regular" size:size];
}

+ (UIFont *)psMediumMainFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"AvenirNext-Medium" size:size];
}

@end
