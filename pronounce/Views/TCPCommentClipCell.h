//
//  TCPCommentClipCell.h
//  pronounce
//
//  Created by Adam Tait on 3/2/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TCPCommentClipModel.h"
#import "TCPModelUpdatedDelegate.h"

@interface TCPCommentClipCell : UITableViewCell <AVAudioPlayerDelegate, TCPModelUpdatedDelegate>

    // public properties
    @property (nonatomic, weak) TCPCommentClipModel *model;

@end
