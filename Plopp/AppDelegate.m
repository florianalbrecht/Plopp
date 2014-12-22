//
//  AppDelegate.m
//  Plopp
//
//  Created by Florian Albrecht on 14.11.14.
//  Copyright (c) 2014 Florian Albrecht. All rights reserved.
//

#import "AppDelegate.h"
#import "GameViewController.h"
#import "UIColor+PloppColors.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    GameViewController *controller = [[GameViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    self.window.rootViewController = navigationController;
    
    self.window.tintColor = [UIColor psDefaultTintColor];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
