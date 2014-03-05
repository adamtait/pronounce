//
//  TCPCommentClipCell.m
//  pronounce
//
//  Created by Adam Tait on 3/2/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPCommentClipCell.h"
#import "TCPUpvote.h"
#import "TCPAwsAPI.h"
#import "TCPColorFactory.h"
#import "UIImageView+AFNetworking.h"

@interface TCPCommentClipCell ()

    // private properties (view outlet references)
    @property (weak, nonatomic) IBOutlet UILabel *upvoteNumberLabel;
    @property (weak, nonatomic) IBOutlet UILabel *dateLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *userProfileImageView;
    @property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
    @property (weak, nonatomic) IBOutlet UILabel *locationLabel;
    @property (weak, nonatomic) IBOutlet UIButton *playButton;
    @property (weak, nonatomic) IBOutlet UIButton *upvoteButton;

    @property (strong, nonatomic) AVAudioPlayer *player;

    // private instance methods
    - (void)setUpvoteButtonAsVoted;
    - (void)setupSubviews;

@end


@implementation TCPCommentClipCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - property override methods

- (void)setModel:(TCPCommentClipModel *)model
{
    // setup views (necessary b/c can't guarantee how self will be created)
    _playButton.layer.cornerRadius = 12;
    _upvoteButton.layer.cornerRadius = 17;
    
    // associate model
    _model = model;
    
    __weak TCPCommentClipCell *weakSelf = self;
    _model.delegate = weakSelf;
}


#pragma mark - private instance methods

- (void)setUpvoteButtonAsVoted
{
    self.upvoteButton.backgroundColor = [TCPColorFactory blueColor];
    self.upvoteButton.enabled = NO;
    self.upvoteButton.userInteractionEnabled = NO;
}

- (void)setupSubviews
{
    // setup view content, from model properties
    if (_model.currentUserHasUpvoted) {
        [self setUpvoteButtonAsVoted];
    }
    _upvoteNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)_model.upvotes];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    _dateLabel.text = [NSString stringWithFormat:@"uploaded on %@ by", [dateFormatter stringFromDate:_model.createdAt]];
    
    [_userProfileImageView setImageWithURL:[NSURL URLWithString:_model.userProperties.pictureURLString]];
    
    _usernameLabel.text = _model.userProperties.name;
    _usernameLabel.numberOfLines = 1;
    _usernameLabel.minimumScaleFactor = 9;
    _usernameLabel.adjustsFontSizeToFitWidth = YES;
    
    _locationLabel.text = _model.userProperties.locationString;
    _usernameLabel.numberOfLines = 1;
    _usernameLabel.minimumScaleFactor = 9;
    _usernameLabel.adjustsFontSizeToFitWidth = YES;
    
    // download the audio file from S3
    NSData *soundData = [NSData dataWithContentsOfURL:[TCPAwsAPI getS3UrlForUUID:self.model.uniqueID]];
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                               NSUserDomainMask, YES) objectAtIndex:0]
                          stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a", self.model.uniqueID]];
    [soundData writeToFile:filePath atomically:YES];
    
    // setup the AVAudioPlayer
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath]
                                                         error:&error];
    self.player.delegate = self;
    
    if (error) {
        NSLog(@"Error trying to play audio with url / %@ /: %@", [TCPAwsAPI getS3UrlForUUID:self.model.uniqueID], [error localizedDescription]);
    }
}

#pragma mark - UIButton Action delegate

- (IBAction)upvoteButtonGotTouch:(id)sender
{
    [TCPUpvote createWithCurrentUserForCommentClipModel:_model];
    int currentValue = [self.upvoteNumberLabel.text intValue];
    self.upvoteNumberLabel.text = [NSString stringWithFormat:@"%d", currentValue + 1];
    [self setUpvoteButtonAsVoted];
}

- (IBAction)playButtonGotTouch:(id)sender
{
    [self startColorFade:self.playButton];
    [self.player play];
}


#pragma mark - audio player delegate

-(void)audioPlayerDidFinishPlaying:
(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.playButton.layer removeAllAnimations];
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                error:(NSError *)error
{
    [self.playButton.layer removeAllAnimations];
}

#pragma mark - animation

-(void)startColorFade:(UIView *)view
{
    view.backgroundColor = [TCPColorFactory blueColor];
    [UIView animateWithDuration:1.0
                          delay:0.5
                        options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear
                     animations:^(void){
                         NSLog(@"animating!");
                         view.backgroundColor = [UIColor whiteColor];
                     }completion:nil];
}

#pragma mark - TCPModelUpdatedDelegate

- (void)modelDidFinishLoadingWithSuccess:(BOOL)success
{
    [self setupSubviews];
}

@end
