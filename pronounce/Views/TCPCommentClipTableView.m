//
//  TCPCommentClipTableView.m
//  pronounce
//
//  Created by Jonathan Xu on 3/6/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPCommentClipTableView.h"
#import "TCPCommentClipCell.h"

static NSString * const cellReuseIdentifier = @"TCPCommentClipCell";

@interface TCPCommentClipTableView () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation TCPCommentClipTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.dataSource = self;
    self.delegate = self;
    
    [self registerNib:[UINib nibWithNibName:@"TCPCommentClipCell" bundle:nil] forCellReuseIdentifier:cellReuseIdentifier];
}

- (void)setCommentClips:(NSArray *)commentClips
{
    _commentClips = commentClips;
    [self reloadData];
}

#pragma mark - TableViewDataSource for CommentClip table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.commentClips count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCPCommentClipCell *cell = [self dequeueReusableCellWithIdentifier:cellReuseIdentifier
                                                          forIndexPath:indexPath];
    cell.model = self.commentClips[indexPath.row];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0)
{
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

@end
