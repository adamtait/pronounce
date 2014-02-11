//
//  TCPTranslateViewController.m
//  pronounce
//
//  Created by Jonathan Xu on 2/8/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPTranslateViewController.h"
#import "TCPSelectLanguageViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface TCPTranslateViewController ()
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

@property (strong,nonatomic) AVSpeechSynthesizer *synthesizer;
@end

@implementation TCPTranslateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self setBorderOnButton:@[self.fromButton, self.toggleButton, self.toButton]];
    
    [self.fromButton setTitle:@"English" forState:UIControlStateNormal];
    [self.toButton setTitle:@"Chinese" forState:UIControlStateNormal];
    
    // demo code
    self.fromTextView.text = @"Where is the train station";
    self.toLabel.text = @"车站在哪里";
    
    self.synthesizer = [[AVSpeechSynthesizer alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.fromTextView becomeFirstResponder];
}

// TODO: borders on adjacent buttons would double up.
//       need to draw these borders directly if we want nice looking borders.
//- (void)setBorderOnButton:(NSArray *)buttons
//{
//    for (UIButton *button in buttons)
//    {
//        button.layer.borderWidth = 1.0f;
//        button.layer.borderColor = [[UIColor grayColor] CGColor];
//    }
//}

#pragma mark - buttion actions

- (IBAction)touchFromButton
{
    TCPSelectLanguageViewController *slVC = [[TCPSelectLanguageViewController alloc] init];
    slVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    slVC.selectLanguageDelegate = self;
    [self presentViewController:slVC animated:YES completion:nil];
}

- (IBAction)touchToButton
{
    TCPSelectLanguageViewController *slVC = [[TCPSelectLanguageViewController alloc] init];
    slVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    slVC.selectLanguageDelegate = self;
    [self presentViewController:slVC animated:YES completion:nil];
}

// TCPSelectLanguageDelegate
- (void)selectLanguage:(TCPLanguageModel *)language
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)touchToSpeakerButton:(id)sender
{
    NSLog(@"TCPTranslateViewController.touchFromSpeakerButton");

    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:self.toLabel.text];
    utterance.rate = AVSpeechUtteranceMinimumSpeechRate;
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    [self.synthesizer speakUtterance:utterance];
}


@end
