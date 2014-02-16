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
#import <AVFoundation/AVFoundation.h>

@interface TCPTranslateViewController ()
@property (strong, nonatomic) TCPLanguageModel *fromLanguage;
@property (strong, nonatomic) TCPLanguageModel *toLanguage;

// top language selector area
@property (weak, nonatomic) IBOutlet UIButton *fromButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet UIButton *toButton;
// from / input area
@property (weak, nonatomic) IBOutlet UITextView *fromTextView;
@property (weak, nonatomic) IBOutlet UIButton *starButton;
// to / output area
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UIButton *toSpeakerButton;
@property (weak, nonatomic) IBOutlet UIButton *toMicrophoneButton;

@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;
@end

@implementation TCPTranslateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.fromLanguage = [self loadLanguageForKey:@"fromLanguage" defaultLongCode:@"en-US"];
    self.toLanguage = [self loadLanguageForKey:@"toLanguage" defaultLongCode:@"zh-CN"];

    //[self.fromTextView becomeFirstResponder];
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

- (void)launchSelectLanguageModal:(NSString *)fromOrTo
{
    TCPSelectLanguageViewController *slvc = [[TCPSelectLanguageViewController alloc] init];
    slvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    slvc.selectLanguageDelegate = self;
    slvc.fromOrTo = fromOrTo;
    [self presentViewController:slvc animated:YES completion:nil];
}

- (IBAction)touchFromButton
{
    [self launchSelectLanguageModal:@"From"];
}

- (IBAction)touchToButton
{
    [self launchSelectLanguageModal:@"To"];
}

// TCPSelectLanguageDelegate

- (void)selectLanguage:(TCPLanguageModel *)language fromOrTo:(NSString *)fromOrTo
{
    NSLog(@"TCPTranslateViewController:selectLanguage: %@", fromOrTo);
    [self dismissViewControllerAnimated:YES completion:^{
        if ([fromOrTo isEqualToString:@"From"]) {
            self.fromLanguage = language;
        }
        else {
            self.toLanguage = language;
        }
    }];
}

#pragma mark - text to speech

@synthesize synthesizer = _synthesizer;

- (AVSpeechSynthesizer *)getSynthesizer
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
