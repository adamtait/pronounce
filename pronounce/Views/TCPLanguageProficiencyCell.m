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
    [self setSliderValue:model.proficiencyLevel];
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

// TCPSelectLanguageDelegate

- (void)selectLanguage:(TCPLanguageModel *)language selectionTitle:(NSString *)selectionTitle
{
    _model.language = language;
    [self updateLanguage:_model.language];
}

#pragma mark - slider

- (void)setSliderValue:(NSUInteger)value
{
    [self.proficiencySlider setValue:value animated:YES];
    
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

- (void)proficiencySliderHandleValueChange
{
    int intValue = (int)roundf(self.proficiencySlider.value);
    [self setSliderValue:intValue];
    self.model.proficiencyLevel = intValue;
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
