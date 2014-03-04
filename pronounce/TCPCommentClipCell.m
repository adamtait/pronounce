//
//  TCPCommentClipCell.m
//  pronounce
//
//  Created by Adam Tait on 3/2/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPCommentClipCell.h"
#import "TCPAwsAPI.h"


@interface TCPCommentClipCell ()

    // private properties (view outlet references)
    @property (weak, nonatomic) IBOutlet UILabel *upvoteNumberLabel;
    @property (weak, nonatomic) IBOutlet UILabel *downvoteNumberLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *userProfileImageView;
    @property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

    @property (strong, nonatomic) AVAudioPlayer *player;

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
    _model = model;
//    self.frame = CGRectMake(0, 0, 320, 80);
//    self.contentView.frame = CGRectMake(0, 0, 320, 80);
}


#pragma mark - public instance methods

- (void)updateSubviews
{
    _upvoteNumberLabel.text = @"5";
    _downvoteNumberLabel.text = @"1";
    _usernameLabel.text = @"Adam";
}


#pragma mark - UIButton Action delegate

- (IBAction)upvoteButtonGotTouch:(id)sender
{
    
}

- (IBAction)downvoteButtonGotTouch:(id)sender
{
    
}

- (IBAction)playButtonGotTouch:(id)sender
{
    NSURL *audioFileUrl = [NSURL URLWithString:[TCPAwsAPI generateS3KeyForUUID:self.model.uniqueID]];
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileUrl error:&error];
    self.player.delegate = self;
    
    if (error) {
        NSLog(@"Error trying to play audio with url / %@ /: %@", audioFileUrl, [error localizedDescription]);
    } else {
        [self.player play];
    }
}


#pragma mark - audio player delegate

-(void)audioPlayerDidFinishPlaying:
(AVAudioPlayer *)player successfully:(BOOL)flag
{
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                error:(NSError *)error
{
}

@end
