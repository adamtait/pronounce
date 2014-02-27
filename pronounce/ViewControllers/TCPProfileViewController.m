//
//  TCPProfileViewController.m
//  pronounce
//
//  Created by Jonathan Xu on 2/11/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPProfileViewController.h"
#import "TCPUserProperties.h"
#import "UIImageView+AFNetworking.h"

@interface TCPProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@end

@implementation TCPProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    TCPUserProperties *userProperties = [TCPUserProperties currentUserProperties];
    [self.profilePictureImageView setImageWithURL:[NSURL URLWithString:userProperties.pictureURLString]];
    self.nameLabel.text = userProperties.name;
    self.locationLabel.text = userProperties.locationString;
}

@end
