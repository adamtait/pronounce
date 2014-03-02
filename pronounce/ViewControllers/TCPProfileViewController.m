//
//  TCPProfileViewController.m
//  pronounce
//
//  Created by Jonathan Xu on 2/11/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPProfileViewController.h"
#import "TCPUserProperties.h"
#import "TCPLanguageProficiencyTableView.h"
#import "TCPSelectLanguageViewController.h"
#import "UIImageView+AFNetworking.h"

@interface TCPProfileViewController () <TCPSelectLanguagePresenterDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet TCPLanguageProficiencyTableView *languageTableView;
@property (weak, nonatomic) IBOutlet UIButton *addLanguageButton;

@property (weak, nonatomic) TCPUserProperties *userProperties;
@end

@implementation TCPProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.languageTableView.selectLanguagePresenterDelegate = self;

    self.userProperties = [TCPUserProperties currentUserProperties];
    [self.profilePictureImageView setImageWithURL:[NSURL URLWithString:self.userProperties.pictureURLString]];
    self.nameLabel.text = self.userProperties.name;
    self.locationLabel.text = self.userProperties.locationString;
}

- (void)readyToAddLanguage:(BOOL)ready
{
    self.addLanguageButton.enabled = ready;
}

- (IBAction)addLanguageButton:(id)sender
{
    [self.languageTableView addLanguage];
}

- (void)presentLanguageSelectionModal:(NSString *)title
               selectLanguageDelegate:(id <TCPSelectLanguageDelegate>)selectLanguageDelegate
{
    TCPSelectLanguageViewController *slvc = [[TCPSelectLanguageViewController alloc] init];
    slvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    slvc.selectLanguageDelegate = selectLanguageDelegate;
    slvc.currentLanguage = nil;
    slvc.title = title;
    [self presentViewController:slvc animated:YES completion:nil];
}

@end
