//
//  TCPTranslateViewController.m
//  pronounce
//
//  Created by Jonathan Xu on 2/8/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPTranslateViewController.h"
#import "TCPSelectLanguageViewController.h"
#import "TCPAvailableLanguages.h"
#import "TCPTranslateAPI.h"
#import <AVFoundation/AVFoundation.h>

@interface TCPTranslateViewController () <UITextViewDelegate>
@property (strong, nonatomic) TCPLanguageModel *fromLanguage;
@property (strong, nonatomic) TCPLanguageModel *toLanguage;

// top language selector area
@property (weak, nonatomic) IBOutlet UIButton *fromButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet UIButton *toButton;
// from / input area
@property (weak, nonatomic) IBOutlet UITextView *fromTextView;
@property (weak, nonatomic) IBOutlet UIButton *starButton;
@property (strong, nonatomic) NSString *whiteStar;
@property (strong, nonatomic) NSString *yellowStar;
// to / output area
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toOuterViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UIButton *toSpeakerButton;
@property (weak, nonatomic) IBOutlet UIButton *toMicrophoneButton;

@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;
@end

@implementation TCPTranslateViewController

static NSString *const kYellowStar = @"⭐️";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshFromTextView];
    [self setToLabelText:@""];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.fromLanguage = [self loadLanguageForKey:@"fromLanguage" defaultLongCode:@"en-US"];
    self.toLanguage = [self loadLanguageForKey:@"toLanguage" defaultLongCode:@"zh-CN"];

    // set up delegate to respond to textViewDidEndEditing notification
    self.fromTextView.delegate = self;
    
    [self.fromTextView becomeFirstResponder];
}

#pragma mark - language selection

@synthesize fromLanguage = _fromLanguage;
@synthesize toLanguage = _toLanguage;

- (TCPLanguageModel *)loadLanguageForKey:(NSString *)persistKey
                         defaultLongCode:(NSString *)defaultLongCode
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    NSString *longCode = [defaults objectForKey:persistKey];
    if (!longCode) {
        longCode = defaultLongCode;
    }
    return [[TCPAvailableLanguages sharedInstance] languageByLongCode:longCode];
}

- (void)saveLanguage:(TCPLanguageModel *)language forKey:(NSString *)persistKey
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    [defaults setObject:language.ietfLongCode forKey:persistKey];
    [defaults synchronize];
}

- (void)setFromLanguage:(TCPLanguageModel *)fromLanguage
{
    _fromLanguage = fromLanguage;
    [self.fromButton setTitle:fromLanguage.englishName forState:UIControlStateNormal];
    [self saveLanguage:fromLanguage forKey:@"fromLanguage"];
}

- (void)setToLanguage:(TCPLanguageModel *)toLanguage
{
    _toLanguage = toLanguage;
    [self.toButton setTitle:toLanguage.englishName forState:UIControlStateNormal];
    [self saveLanguage:toLanguage forKey:@"toLanguage"];
}

- (void)launchSelectLanguageModal:(TCPLanguageModel *)currentLanguage
                         fromOrTo:(NSString *)fromOrTo
{
    TCPSelectLanguageViewController *slvc = [[TCPSelectLanguageViewController alloc] init];
    slvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    slvc.selectLanguageDelegate = self;
    slvc.currentLanguage = currentLanguage;
    slvc.fromOrTo = fromOrTo;
    [self presentViewController:slvc animated:YES completion:nil];
}

- (IBAction)touchFromButton
{
    [self launchSelectLanguageModal:self.fromLanguage fromOrTo:@"From"];
}

- (IBAction)touchToButton
{
    [self launchSelectLanguageModal:self.toLanguage fromOrTo:@"To"];
}

// TCPSelectLanguageDelegate

- (void)selectLanguage:(TCPLanguageModel *)language fromOrTo:(NSString *)fromOrTo
{
    NSLog(@"TCPTranslateViewController:selectLanguage: %@, %@", fromOrTo, language.ietfLongCode);
    [self dismissViewControllerAnimated:YES completion:^{
        if ([fromOrTo isEqualToString:@"From"]) {
            self.fromLanguage = language;
        }
        else {
            self.toLanguage = language;
        }
    }];
}

#pragma mark - translate

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
  replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    [self refreshFromTextView];
}

- (void)refreshFromTextView
{
    NSString *fromText = self.fromTextView.text;
    if ([fromText length] > 0) {
        NSLog(@"TCPTranslateViewController:textViewDidEndEditing: %@", fromText);
        
        [self.starButton setEnabled:YES];
        [self.starButton setTitle:kYellowStar forState:UIControlStateNormal];
        
        TCPTranslateAPI *translator = [TCPTranslateAPI sharedInstance];
        NSString *toText = [translator translate:fromText
                                    fromLanguage:self.fromLanguage
                                      toLanguage:self.toLanguage];
        [self setToLabelText:toText];
    }
    else {
        [self.starButton setEnabled:NO];
        [self.starButton setTitle:@"" forState:UIControlStateNormal];
    }
}

- (void)setToLabelText:(NSString *)toText
{
    CGFloat heightBefore = self.toLabel.frame.size.height;
    self.toLabel.text = toText;
    [self.toLabel sizeToFit];
    CGFloat heightAfter = self.toLabel.frame.size.height;
    self.toOuterViewHeightConstraint.constant += (heightAfter - heightBefore);

    BOOL enabled = ([toText length] > 0);
    [self.toSpeakerButton setEnabled:enabled];
    [self.toSpeakerButton setAlpha:enabled ? 1.0 : 0.5];
    [self.toMicrophoneButton setEnabled:enabled];
    [self.toMicrophoneButton setAlpha:enabled ? 1.0 : 0.5];
}

#pragma mark - text to speech

@synthesize synthesizer = _synthesizer;

- (AVSpeechSynthesizer *)synthesizer
{
    if (!_synthesizer) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
    }
    return _synthesizer;
}

- (IBAction)touchToSpeakerButton:(id)sender
{
    NSLog(@"TCPTranslateViewController.touchFromSpeakerButton");

    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:self.toLabel.text];
    utterance.rate = AVSpeechUtteranceMinimumSpeechRate;
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:self.toLanguage.ietfLongCode];
    [self.synthesizer speakUtterance:utterance];
}


@end
