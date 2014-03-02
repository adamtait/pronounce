//
//  TCPLanguageProficiencyCell.m
//  pronounce
//
//  Created by Jonathan Xu on 2/27/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPLanguageProficiencyCell.h"
#import "TCPSelectLanguageViewController.h"
#import "TCPSelectLanguageDelegate.h"

@interface TCPLanguageProficiencyCell () <TCPSelectLanguageDelegate>
@property (weak, nonatomic) UIColor *defaultButtonTintColor;
@property (weak, nonatomic) IBOutlet UIButton *languageButton;
@property (weak, nonatomic) IBOutlet UILabel *languageLabel;
@property (weak, nonatomic) IBOutlet UISlider *proficiencySlider;
@property (weak, nonatomic) IBOutlet UILabel *proficiencyLabel;
@end

@implementation TCPLanguageProficiencyCell

+ (CGFloat)cellHeight
{
    return 65; // from xib
}

- (void)setModel:(TCPLanguageProficiencyModel *)model
{
    _model = model;
    
    if (!self.defaultButtonTintColor) {
        self.defaultButtonTintColor = self.languageButton.tintColor;
    }

    [self updateLanguage:_model.language];
    self.proficiencySlider.value = model.proficiencyLevel;
}

- (void)updateLanguage:(TCPLanguageModel *)language
{
    if (language.englishName) {
        [self.languageButton setTitle:language.englishName forState:UIControlStateNormal];
        self.languageButton.tintColor = [UIColor blackColor];
    }
    else {
        [self.languageButton setTitle:@"Select language" forState:UIControlStateNormal];
        self.languageButton.tintColor = self.defaultButtonTintColor;
    }
}

#pragma mark - select a language

- (IBAction)touchLanguageButton
{
    if (!self.model.language) {
        [self.selectLanguagePresenterDelegate presentLanguageSelectionModal:@"Your Language"
                                                     selectLanguageDelegate:self];
    }
}

- (void)selectLanguage:(TCPLanguageModel *)language selectionTitle:(NSString *)selectionTitle
{
    _model.language = language;
    [self updateLanguage:_model.language];
}

@end
