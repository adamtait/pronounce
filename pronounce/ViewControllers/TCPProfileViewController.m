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
@property (weak, nonatomic) IBOutlet UITableView *languageTableView;

@property (weak, nonatomic) TCPUserProperties *userProperties;
@end

@implementation TCPProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.userProperties = [TCPUserProperties currentUserProperties];
    [self.profilePictureImageView setImageWithURL:[NSURL URLWithString:self.userProperties.pictureURLString]];
    self.nameLabel.text = self.userProperties.name;
    self.locationLabel.text = self.userProperties.locationString;
}


@end
