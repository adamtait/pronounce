//
//  TCPTranslationDetailViewController.m
//  pronounce
//
//  Created by Jonathan Xu on 3/3/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPTranslationDetailViewController.h"
#import "TCPCommentClipCell.h"

@interface TCPTranslationDetailViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fromLanguageLabelTopVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet UILabel *fromLanguageLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLanguageLabel;
@property (weak, nonatomic) IBOutlet UILabel *toTextLabel;
// ClipComment Table View
@property (weak, nonatomic) IBOutlet UITableView *commentClipTableView;
@end

static NSString * const cellReuseIdentifier = @"TCPCommentClipCell";

@implementation TCPTranslationDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.commentClipTableView registerNib:[UINib nibWithNibName:@"TCPCommentClipCell" bundle:nil] forCellReuseIdentifier:cellReuseIdentifier];
    self.commentClipTableView.delegate = self;
    self.commentClipTableView.dataSource = self;
    [self render];
    
    // request matching CommentClips from Parse
    __weak TCPTranslationModel *weakModel = _model;
    [TCPCommentClipModel loadAllForTranslation:_model
                                    completion:^(NSArray *commentClips)
     {
         weakModel.commentClips = [NSMutableArray arrayWithArray:commentClips];
         [self.commentClipTableView performSelectorOnMainThread:@selector(reloadData)
                                                     withObject:nil
                                                  waitUntilDone:NO];
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.navigationController.navigationBarHidden) {
        self.fromLanguageLabelTopVerticalSpaceConstraint.constant = self.navigationController.navigationBar.frame.size.height + 40;
    }
}

- (void)setModel:(TCPTranslationModel *)model
{
    _model = model;
    [self render];
}

- (void)render
{
    if (self.model) {
        self.fromLanguageLabel.text = self.model.fromLanguage.englishName;
        self.fromTextLabel.text = self.model.phrase;
        self.toLanguageLabel.text = self.model.toLanguage.englishName;
        self.toTextLabel.text = self.model.exampleTranslation;
    }
}

#pragma mark - TableViewDataSource for CommentClip table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_model.commentClips count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCPCommentClipCell *cell = [_commentClipTableView dequeueReusableCellWithIdentifier:cellReuseIdentifier
                                                                           forIndexPath:indexPath];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"TCPCommentClipCell" bundle:nil] forCellReuseIdentifier:cellReuseIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    }
    cell.model = _model.commentClips[indexPath.row];
    NSLog(@"created cell for model / %@ /", _model.commentClips[indexPath.row]);
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}


@end
