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
#import "TCPTranslateAPICompletionDelegate.h"
#import "TCPCommentClipModel.h"
#import "TCPCommentClipCell.h"
#import "TCPFavoriteTranslationModel.h"
#import "TCPColorFactory.h"
#import <QuartzCore/QuartzCore.h>

static NSString * const cellReuseIdentifier = @"TCPCommentClipCell";

@interface TCPTranslateViewController () <UITextViewDelegate, TCPTranslateAPICompletionDelegate>


    // private properties
    @property (strong, nonatomic) TCPLanguageModel *fromLanguage;
    @property (strong, nonatomic) TCPLanguageModel *toLanguage;
    @property (nonatomic, strong) TCPTranslationModel *translationModel;


// top language selector area
@property (weak, nonatomic) IBOutlet UIButton *fromButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet UIButton *toButton;

// from / input area
@property (weak, nonatomic) IBOutlet UITextView *fromTextView;


// to / record & play area
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *play_recordSpacingWidth;

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;



// to / output area
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toOuterViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UIButton *toSpeakerButton;

@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;

@property (strong, nonatomic) TCPCommentClipModel *addedCommentClipModel;


// ClipComment Table View
@property (weak, nonatomic) IBOutlet UITableView *commentClipTableView;

// Favorite
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (strong, nonatomic) TCPFavoriteTranslationModel *favorite;

@end

@implementation TCPTranslateViewController

static NSString *const kYellowStar = @"⭐️";
static NSString *const kWhiteStar = @"☆";

- (void)viewDidLoad
{
    [self setupRecordingViews];
    [super viewDidLoad];
    
    [self.commentClipTableView registerNib:[UINib nibWithNibName:@"TCPCommentClipCell" bundle:nil] forCellReuseIdentifier:cellReuseIdentifier];
    self.commentClipTableView.delegate = self;
    self.commentClipTableView.dataSource = self;
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
                   selectionTitle:(NSString *)selectionTitle
{
    TCPSelectLanguageViewController *slvc = [[TCPSelectLanguageViewController alloc] init];
    slvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    slvc.selectLanguageDelegate = self;
    slvc.currentLanguage = currentLanguage;
    slvc.selectionTitle = selectionTitle;
    [self presentViewController:slvc animated:YES completion:nil];
}

- (IBAction)touchFromButton
{
    [self launchSelectLanguageModal:self.fromLanguage selectionTitle:@"From Language"];
}

- (IBAction)touchToButton
{
    [self launchSelectLanguageModal:self.toLanguage selectionTitle:@"To Language"];
}


// TCPSelectLanguageDelegate

- (void)selectLanguage:(TCPLanguageModel *)language selectionTitle:(NSString *)selectionTitle
{
    NSLog(@"TCPTranslateViewController:selectLanguage: %@, %@", selectionTitle, language.ietfLongCode);
        if ([selectionTitle isEqualToString:@"From Language"]) {
            self.fromLanguage = language;
        }
        else {
            self.toLanguage = language;
        }
}

#pragma mark - translate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
  replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self refreshFromTextView];
}

- (void)refreshFromTextView
{
    NSString *fromText = self.fromTextView.text;
    NSLog(@"TCPTranslateViewController:textViewDidEndEditing: %@", fromText);

    [TCPTranslationModel asyncLoadWithPhrase:fromText
                                fromLanguage:_fromLanguage
                                  toLanguage:_toLanguage
                                viewDelegate:self
                                  completion:^(TCPTranslationModel *loadedModel)
    {
        _translationModel = loadedModel;
        NSLog(@"succesfully loaded translation model!! / %@ /", _translationModel);
        NSLog(@"new translation model has lots of clips / %lu /", (unsigned long)[_translationModel.commentClips count]);
        [_commentClipTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [self prepareAVRecorder];
    }];
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

- (void)setupRecordingViews
{
    _recordButton.layer.cornerRadius = 12;
    _playButton.layer.cornerRadius = 12;

    _recordButtonWidth.constant = 300;
    _playButtonWidth.constant = 0;
    _play_recordSpacingWidth.constant = 0;
}

- (void)enableRecordingView
{
    [_recordButton setEnabled:YES];
    [_recordButton setAlpha:1.0];
}

- (void)prepareAVRecorder
{
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
    
    _addedCommentClipModel = [[TCPCommentClipModel alloc] initWithAudioDataFileURL:outputFileURL
                                                                  translationModel:_translationModel
                              userPropertiesModel:[TCPUserProperties currentUserProperties]];
    
    [self performSelectorOnMainThread:@selector(enableRecordingView) withObject:nil waitUntilDone:NO];
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
                         _playButtonWidth.constant = 180;
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
        [_addedCommentClipModel saveAudioData];
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



#pragma mark - TableViewDataSource for CommentClip table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_translationModel.commentClips count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCPCommentClipCell *cell = [_commentClipTableView dequeueReusableCellWithIdentifier:cellReuseIdentifier
                                                                           forIndexPath:indexPath];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"TCPCommentClipCell" bundle:nil] forCellReuseIdentifier:cellReuseIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    }
    cell.model = _translationModel.commentClips[indexPath.row];
    NSLog(@"created cell for model / %@ /", _translationModel.commentClips[indexPath.row]);
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0)
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

#pragma mark - favorite

- (void)setFavorite:(TCPFavoriteTranslationModel *)favorite
{
    _favorite = favorite;
    if (favorite) {
        [self.favoriteButton setEnabled:YES];
        [self.favoriteButton setTitle:kYellowStar forState:UIControlStateNormal];
    }
    else
    {
        [self.favoriteButton setEnabled:NO];
        [self.favoriteButton setTitle:kWhiteStar forState:UIControlStateNormal];
    }
}


@end
