//
//  TCPLoginViewController.m
//  pronounce
//
//  Created by Adam Tait on 2/11/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPLoginViewController.h"
#import "TCPTranslateViewController.h"
#import "TCPUserProperties.h"
#import <Parse/Parse.h>

@implementation TCPLoginViewController

- (IBAction)loginButtonTouchHandler:(id)sender
{
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_location" ];
    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            if (!error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidLogin" object:nil];
        }
    }];
}

@end
