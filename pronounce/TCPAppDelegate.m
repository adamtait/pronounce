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
#import "TCPFavoritesTableViewController.h"
#import "TCPProfileViewController.h"
#import "TCPUserProperties.h"
#import "TCPTranslationModel.h"
#import "TCPLanguageModel.h"
#import "TCPLanguageProficiencyModel.h"
#import "TCPCommentClipModel.h"
#import "TCPFavoriteTranslationModel.h"
#import "TCPUpvote.h"
#import <Parse/Parse.h>

@interface TCPAppDelegate () <UITabBarControllerDelegate>

// private instance properties
@property (strong, nonatomic) UITabBarController *tabBar;

@end

@implementation TCPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // register Parse classes
    [TCPUserProperties registerSubclass];
    [TCPTranslationModel registerSubclass];
    [TCPLanguageModel registerSubclass];
    [TCPLanguageProficiencyModel registerSubclass];
    [TCPCommentClipModel registerSubclass];
    [TCPUpvote registerSubclass];
    [TCPFavoriteTranslationModel registerSubclass];

    [Parse setApplicationId:@"8oW0hcIkvbhY8OtqIvGdSZkqoIk1KmTUva1ibJml"
                  clientKey:@"HR1pVdxiYi677COVOey10sJZ8AFjNmqc9OUQfNAQ"];

    [PFFacebookUtils initializeFacebook];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    PFUser *user = [PFUser currentUser];
    if (user && [PFFacebookUtils isLinkedWithUser:user]) {
        [[TCPUserProperties currentUserProperties] loginPFUser:user];
        self.window.rootViewController = self.tabBar;
    }
    else {
        [self observeLogin];
        self.window.rootViewController = [[TCPLoginViewController alloc] init];
    }
    return YES;
}

- (void)observeLogin
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogin:)
                                                 name:@"userDidLogin"
                                               object:nil];
}

#pragma mark - UITabBarController and UITabBarControllerDelegate

@synthesize tabBar = _tabBar;

- (UITabBarController *)tabBar
{
    if (!_tabBar) {
        // Note: do not embed these views in UINavigationControllers
        //       we do not use the nav bar.
        TCPTranslateViewController *translateVC = [[TCPTranslateViewController alloc] init];
        translateVC.title = @"Translate";
        
        TCPFavoritesTableViewController *favoritesVC = [[TCPFavoritesTableViewController alloc] init];
        favoritesVC.title = @"Favorites";
        UINavigationController *favoritesVCNC = [[UINavigationController alloc] initWithRootViewController:favoritesVC];
        
        TCPProfileViewController *profileVC = [[TCPProfileViewController alloc] init];
        profileVC.title = @"Profile";
        UINavigationController *profileVCNC = [[UINavigationController alloc] initWithRootViewController:profileVC];

        NSArray *views = @[translateVC, favoritesVCNC, profileVCNC];

        _tabBar = [[UITabBarController alloc] init];
        _tabBar.delegate = self;
        [_tabBar setViewControllers:views];
        
        _tabBar.selectedIndex = 1;
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

#pragma mark - Application state change handlers

- (void)userDidLogin:(id)notification
{
    PFUser *user = [PFUser currentUser];
    if (user.isAuthenticated) {
        NSLog(@"TCPAppDelegate:userDidLogin: authenticated");
        [[TCPUserProperties currentUserProperties] loginPFUser:user];
        self.window.rootViewController = self.tabBar;
    }
    else {
        NSLog(@"TCPAppDelegate:userDidLogin: WTH?");
    }
}

#pragma mark - AppDelegate methods

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


#pragma - mark App switching methods to support Facebook Single Sign-On.

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */

    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [[PFFacebookUtils session] close];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
