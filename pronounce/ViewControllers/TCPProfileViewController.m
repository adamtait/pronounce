//
//  TCPProfileViewController.m
//  pronounce
//
//  Created by Jonathan Xu on 2/11/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPProfileViewController.h"
#import "TCPUser.h"
#import "UIImageView+AFNetworking.h"

@interface TCPProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation TCPProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    TCPUser *user = [TCPUser currentUser];
    [self.profilePictureImageView setImageWithURL:[NSURL URLWithString:user.pictureURLString]];
    self.nameLabel.text = user.name;
}

@end
