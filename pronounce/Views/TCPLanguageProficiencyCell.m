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
#import "TCPAvailableLanguages.h"

@interface TCPLanguageProficiencyCell () <TCPSelectLanguageDelegate>
@property (weak, nonatomic) UIColor *defaultButtonTintColor;
@property (weak, nonatomic) IBOutlet UIButton *languageButton;
@property (weak, nonatomic) IBOutlet UILabel *nativeLanguageLabel;
@property (weak, nonatomic) IBOutlet UISlider *proficiencySlider;
@property (weak, nonatomic) IBOutlet UILabel *proficiencyLabel;

@property (strong, nonatomic) TCPLanguageModel *language;
@end

@implementation TCPLanguageProficiencyCell

+ (CGFloat)cellHeight
{
    return 70; // from xib
}

- (void)setModel:(TCPLanguageProficiencyModel *)model
{
    _model = model;
    
    if (!self.defaultButtonTintColor) {
        self.defaultButtonTintColor = self.languageButton.tintColor;
    }

    self.language = [[TCPAvailableLanguages sharedInstance] languageByLongCode:_model.languageLongCode];
    [self setSliderLabel:model.proficiencyLevel];
}

#pragma mark - select a language

- (void)setLanguage:(TCPLanguageModel *)language
{
    _language = language;
    if (language.englishName) {
        [self.languageButton setTitle:language.englishName forState:UIControlStateNormal];
        self.nativeLanguageLabel.text = language.nativeName;
        self.languageButton.tintColor = [UIColor blackColor];
    }
    else {
        [self.languageButton setTitle:@"Select language" forState:UIControlStateNormal];
        self.nativeLanguageLabel.text = nil;
        self.languageButton.tintColor = self.defaultButtonTintColor;
    }
}

- (IBAction)touchLanguageButton
{
    if (!self.language) {
        [self.selectLanguagePresenterDelegate presentLanguageSelectionModal:@"Your Language"
                                                     selectLanguageDelegate:self];
    }
}

// TCPSelectLanguageDelegate

- (void)selectLanguage:(TCPLanguageModel *)language selectionTitle:(NSString *)selectionTitle
{
    self.model.languageLongCode = language.ietfLongCode;
    [self.model saveInBackground]; // WTH: Parse does not save this from the top level object
    self.language = language;
}

#pragma mark - slider

- (void)setSliderLabel:(NSUInteger)value
{
    // TODO: use localized strings
    if (value == 0) {
        self.proficiencyLabel.text = @"Learning";
    }
    else if (value == 1) {
        self.proficiencyLabel.text = @"Pretty good";
    }
    else if (value == 2) {
        self.proficiencyLabel.text = @"Native";
    }
    else {
        self.proficiencyLabel.hidden = YES;
    }
}

- (IBAction)proficiencySliderTouchDragInside:(id)sender
{
    int intValue = (int)roundf(self.proficiencySlider.value);
    [self setSliderLabel:intValue];
}

- (void)proficiencySliderHandleValueChange
{
    int intValue = (int)roundf(self.proficiencySlider.value);
    [self setSliderLabel:intValue];
    [self.proficiencySlider setValue:(float)intValue animated:YES];

    self.model.proficiencyLevel = intValue;
    [self.model saveInBackground]; // WTH: Parse does not save this from the top level object
}

- (IBAction)proficiencySliderTouchUpInside:(id)sender
{
    [self proficiencySliderHandleValueChange];
}

- (IBAction)proficiencySliderTouchUpOutside:(id)sender
{
    [self proficiencySliderHandleValueChange];
}

@end
