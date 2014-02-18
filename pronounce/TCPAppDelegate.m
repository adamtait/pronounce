//
//  TCPAppDelegate.m
//  pronounce
//
//  Created by Adam Tait on 2/5/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPAppDelegate.h"
#import "TCPLoginViewController.h"
#import "TCPTranslateViewController.h"
#import "TCPProfileViewController.h"
#import <Parse/Parse.h>

@interface TCPAppDelegate () <UITabBarControllerDelegate>
@property (strong, nonatomic) UITabBarController *tabBar;
@end

@implementation TCPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"8oW0hcIkvbhY8OtqIvGdSZkqoIk1KmTUva1ibJml"
                  clientKey:@"HR1pVdxiYi677COVOey10sJZ8AFjNmqc9OUQfNAQ"];
    
    [PFFacebookUtils initializeFacebook];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
//    TCPLoginViewController *vc = [[TCPLoginViewController alloc] init];
    self.window.rootViewController = self.tabBar;
    //[self.window addSubview:self.tabBar.view];
    
    return YES;
}

#pragma mark - UITabBarController and UITabBarControllerDelegate

@synthesize tabBar = _tabBar;

- (UITabBarController *)tabBar
{
    if (!_tabBar) {
        // Note: do not embed these views in UINavigationControllers
        //       we do not use the nav bar.
        TCPTranslateViewController *translateView = [[TCPTranslateViewController alloc] init];
        translateView.title = @"Translate";
        TCPProfileViewController *profileView = [[TCPProfileViewController alloc] init];
        profileView.title = @"Profile";
        
        NSArray *views = @[translateView, profileView];
        
        _tabBar = [[UITabBarController alloc] init];
        _tabBar.delegate = self;
        [_tabBar setViewControllers:views];
    }
    return _tabBar;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSUInteger tabIndex = [tabBarController.viewControllers indexOfObject:viewController];
    if (viewController == [tabBarController.viewControllers objectAtIndex:tabIndex] ) {
        return YES;
    }
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
