//
//  TCPTranslateViewController.m
//  pronounce
//
//  Created by Jonathan Xu on 2/8/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPTranslateViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface TCPTranslateViewController ()
@property (weak, nonatomic) IBOutlet UIButton *fromButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet UIButton *toButton;
@property (weak, nonatomic) IBOutlet UITextView *fromTextView;
@property (weak, nonatomic) IBOutlet UIButton *fromMicrophoneButton;
@property (weak, nonatomic) IBOutlet UIButton *fromSpeakerButton;
@property (weak, nonatomic) IBOutlet UILabel *toTextView;
@property (weak, nonatomic) IBOutlet UIButton *starButton;
@property (weak, nonatomic) IBOutlet UIButton *toSpeakerButton;

@property (strong,nonatomic) AVSpeechSynthesizer *synthesizer;
@end

@implementation TCPTranslateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self setBorderOnButton:@[self.fromButton, self.toggleButton, self.toButton]];
    
    [self.fromButton setTitle:@"English" forState:UIControlStateNormal];
    [self.toButton setTitle:@"Chinese" forState:UIControlStateNormal];
    
    self.synthesizer = [[AVSpeechSynthesizer alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.fromTextView becomeFirstResponder];
}

- (void)setBorderOnButton:(NSArray *)buttons
{
    // TODO: borders on adjacent buttons would double up.
    //       need to draw these borders directly if we want nice looking borders.
    for (UIButton *button in buttons)
    {
        button.layer.borderWidth = 1.0f;
        button.layer.borderColor = [[UIColor grayColor] CGColor];
    }
}

#pragma mark - buttion actions
- (IBAction)touchFromSpeakerButton:(id)sender
{
    NSLog(@"TCPTranslateViewController.touchFromSpeakerButton");

    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:self.fromTextView.text];
    utterance.rate = AVSpeechUtteranceMinimumSpeechRate;
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    [self.synthesizer speakUtterance:utterance];
}


@end
