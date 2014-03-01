//
//  TCPLanguageProficiencyTableView.m
//  pronounce
//
//  Created by Jonathan Xu on 2/28/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPLanguageProficiencyTableView.h"

@interface TCPLanguageProficiencyTableView () <UITableViewDataSource, UITableViewDelegate>
@end

@implementation TCPLanguageProficiencyTableView

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

- (void)setup {
    self.dataSource = self;
    self.delegate = self;
    
    [self addObserver:self
           forKeyPath:@"contentSize"
              options:0
              context:NULL];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"contentSize"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
    //    return [self.userProperties.languagesByProficiencyLevel count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LanguageProficiencyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TCPLanguageProficiencyCell"
                                              owner:self
                                            options:nil] lastObject];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    [label setText:@"My Languages"]; // TODO: localize
    [view addSubview:label];

    return view;
}

#pragma mark - adjust table height

- (void)adjustLanguageTableViewHeight
{
    CGFloat height = self.contentSize.height;
    CGFloat maxHeight = self.superview.frame.size.height - self.frame.origin.y;
    
    // if the height of the content is greater than the maxHeight of
    // total space on the screen, limit the height to the size of the
    // superview.
    
    if (height > maxHeight)
        height = maxHeight;
    
    // now set the frame accordingly
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.frame;
        frame.size.height = height;
        self.frame = frame;
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self performSelectorOnMainThread:@selector(adjustLanguageTableViewHeight)
                           withObject:nil
                        waitUntilDone:NO];
}

@end
