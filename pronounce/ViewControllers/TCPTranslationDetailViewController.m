//
//  TCPTranslationDetailViewController.m
//  pronounce
//
//  Created by Jonathan Xu on 3/3/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPTranslationDetailViewController.h"

@interface TCPTranslationDetailViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fromLanguageLabelTopVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet UILabel *fromLanguageLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLanguageLabel;
@property (weak, nonatomic) IBOutlet UILabel *toTextLabel;
@end

@implementation TCPTranslationDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self render];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.navigationController.navigationBarHidden) {
        self.fromLanguageLabelTopVerticalSpaceConstraint.constant = self.navigationController.navigationBar.frame.size.height + 40;
    }
}

- (void)setModel:(TCPTranslationModel *)model
{
    _model = model;
    [self render];
}

- (void)render
{
    if (self.model) {
        self.fromLanguageLabel.text = self.model.fromLanguage.englishName;
        self.fromTextLabel.text = self.model.fromText;
        self.toLanguageLabel.text = self.model.toLanguage.englishName;
        self.toTextLabel.text = self.model.toText;
    }
}

@end
