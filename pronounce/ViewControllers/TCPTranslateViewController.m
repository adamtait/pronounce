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
#import "TCPColorFactory.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

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

// to / record & play area
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *play_recordSpacingWidth;

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;

@end

@implementation TCPTranslateViewController

static NSString *const kYellowStar = @"⭐️";

- (void)viewDidLoad
{
    [self setupRecording];
    [super viewDidLoad];
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

        [_recordButton setEnabled:YES];
        [_recordButton setAlpha:1.0];
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
    [self.recordButton setEnabled:enabled];
    [self.recordButton setAlpha:enabled ? 1.0 : 0.5];
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
    _recordButton.layer.cornerRadius = 12;
    _playButton.layer.cornerRadius = 12;

    _recordButtonWidth.constant = 300;
    _playButtonWidth.constant = 0;
    _play_recordSpacingWidth.constant = 0;

    NSURL *outputFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"translation.m4a"]];

    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithFloat:44100],AVSampleRateKey,
                                   [NSNumber numberWithInt: kAudioFormatAppleLossless],AVFormatIDKey,
                                   [NSNumber numberWithInt: 1],AVNumberOfChannelsKey,
                                   [NSNumber numberWithInt:AVAudioQualityMedium],AVEncoderAudioQualityKey,nil];

    // Initiate and prepare the recorder
    _recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:audioSettings error:NULL];
    _recorder.delegate = self;
    _recorder.meteringEnabled = YES;
    [_recorder prepareToRecord];

    _addedCommentClipModel = [[TCPCommentClipModel alloc] initWithAudioDataFileURL:outputFileURL];
}

- (void)requestMicrophonePermissions
{
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
    {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                NSLog(@"Microphone is enabled..");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self startRecording];
                });
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
}

-(void)startColorFade:(UIView *)view
{
    view.backgroundColor = [TCPColorFactory blueColor];
    [UIView animateWithDuration:1.0
                          delay:1.0
                        options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear
                     animations:^(void){
                         NSLog(@"animating!");
                         view.backgroundColor = [UIColor whiteColor];
                     }completion:nil];
}

- (void)startRecording
{
    NSLog(@"recording started!");
    [_recorder recordAtTime:1.0];
    [self startColorFade:_recordButton];
}

- (void)stopRecording
{
    NSLog(@"recording stopped");
    [_recordButton.layer removeAllAnimations];

    [UIView animateWithDuration:2.0
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(void){
                         _recordButtonWidth.constant = 80;
                         _playButtonWidth.constant = 200;
                         _play_recordSpacingWidth.constant = 20;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (IBAction)touchToRecordButton:(id)sender
{
    if (!_recorder.recording)
    {
        [self requestMicrophonePermissions];
    }
    else
    {
        [_recorder stop];
        NSLog(@"recording stopped");
        [_addedCommentClipModel saveInBackground];
        [self stopRecording];
    }
}

- (void)stopPlaying
{
    NSLog(@"stop playing");
    [_playButton.layer removeAllAnimations];
    _recordButton.enabled = YES;
    [self.recordButton setAlpha:1.0];
}


- (IBAction)touchToPlayButton:(id)sender
{
    if (!_recorder.recording)
    {
        _recordButton.enabled = NO;
        [self.recordButton setAlpha:0.5];

        NSError *error;
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:_recorder.url error:&error];
        _player.delegate = self;

        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            NSLog(@"start playing");
            [_player play];
            [self startColorFade:_playButton];
        }
    }
}


#pragma - mark AudioPlayer & AudioRecorder Delegates



-(void)audioPlayerDidFinishPlaying:
(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopPlaying];
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                error:(NSError *)error
{
    NSLog(@"Decode Error occurred");
    [self stopPlaying];
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                          successfully:(BOOL)flag
{
    NSLog(@"recorder was forced to stop recording");
    [self stopRecording];
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                  error:(NSError *)error
{
    NSLog(@"Encode Error occurred");
}

@end
