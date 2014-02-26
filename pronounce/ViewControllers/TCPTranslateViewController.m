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
#import "TCPTranslateAPICompletionDelegate.h"
#import "TCPCommentClipModel.h"
#import <AVFoundation/AVFoundation.h>

@interface TCPTranslateViewController () <UITextViewDelegate, TCPTranslateAPICompletionDelegate>
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

@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;

@property (strong, nonatomic) TCPCommentClipModel *addedCommentClipModel;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;

@end

@implementation TCPTranslateViewController

static NSString *const kYellowStar = @"⭐️";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupRecording];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.fromLanguage = [self loadLanguageForKey:@"fromLanguage" defaultLongCode:@"en-US"];
    self.toLanguage = [self loadLanguageForKey:@"toLanguage" defaultLongCode:@"zh-CN"];

    // set up delegate to respond to textViewDidEndEditing notification
    self.fromTextView.delegate = self;

    [self refreshFromTextView];
    [self setToLabelText:@""];

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
        
        __weak TCPTranslateViewController *weakSelf = self;
        TCPTranslateAPI *translator = [TCPTranslateAPI sharedInstance];
        translator.completionDelegate = weakSelf;
        [translator translate:fromText
                 fromLanguage:self.fromLanguage
                   toLanguage:self.toLanguage];
    }
    else {
        [self.starButton setEnabled:NO];
        [self.starButton setTitle:@"" forState:UIControlStateNormal];
    }
}

- (void)completeWithTranslatedString:(NSString *)toText success:(BOOL)success
{
    if (success) {
        [self performSelectorOnMainThread:@selector(setToLabelText:)
                               withObject:toText
                            waitUntilDone:NO];
    }
}

- (void)setToLabelText:(NSString *)toText
{
    CGFloat heightBefore = self.toLabel.frame.size.height;
    self.toLabel.text = toText;
    [self.toLabel sizeToFit];
    CGFloat heightAfter = self.toLabel.frame.size.height;
    if (heightAfter == 0) {
        heightAfter = heightBefore;
    }
    self.toOuterViewHeightConstraint.constant += (heightAfter - heightBefore);

    BOOL enabled = ([toText length] > 0);
    [self.toSpeakerButton setEnabled:enabled];
    [self.toSpeakerButton setAlpha:enabled ? 1.0 : 0.5];
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

#pragma mark - record

- (void)setupRecording
{
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    _recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    _recorder.delegate = self;
    _recorder.meteringEnabled = YES;
    [_recorder prepareToRecord];
    
    _addedCommentClipModel = [[TCPCommentClipModel alloc] initWithAudioDataFileURL:outputFileURL];
}


- (IBAction)touchToRecordButton:(id)sender
{
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
    {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                NSLog(@"Microphone is enabled..");
            }
            else {
                NSLog(@"Microphone is disabled..");
                
                // We're in a background thread here, so jump to main thread to do UI work.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Microphone Access Denied"
                                                 message:@"This app requires access to your device's Microphone.\n\nPlease enable Microphone access for this app in Settings / Privacy / Microphone"
                                                delegate:nil
                                       cancelButtonTitle:@"Dismiss"
                                       otherButtonTitles:nil] show];
                });
            }
        }];
    }
    
    NSLog(@"got touch to microphone");
    if (!_recorder.recording)
    {
        [_recorder record];
        NSLog(@"recording started!");
    } else {
        [_recorder stop];
        NSLog(@"recording stopped");
        [_addedCommentClipModel saveInBackground];
    }
}


- (IBAction)touchToPlayButton:(id)sender
{
    if (!_recorder.recording)
    {
        NSError *error;
        
        _player = [[AVAudioPlayer alloc]
                        initWithContentsOfURL:_recorder.url
                        error:&error];
        
        _player.delegate = self;
        
        if (error)
            NSLog(@"Error: %@",
                  [error localizedDescription]);
        else
            [_player play];
    }
}

@end
























