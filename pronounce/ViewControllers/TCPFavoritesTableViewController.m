//
//  TCPFavoritesViewController.m
//  pronounce
//
//  Created by Jonathan Xu on 3/2/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPFavoritesTableViewController.h"
#import "TCPTranslationCell.h"
#import "TCPAvailableLanguages.h"
#import "TCPTranslationDetailViewController.h"

@interface TCPFavoritesTableViewController () <UISearchBarDelegate>
@property (weak, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *translations;
@end

@implementation TCPFavoritesTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //[self setup];
    }
    return self;
}

- (void)setup
{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    UINib *translationCellNib = [UINib nibWithNibName:@"TCPTranslationCell" bundle:nil];
    [self.tableView registerNib:translationCellNib forCellReuseIdentifier:@"TranslationCell"];
    
    TCPAvailableLanguages *languages = [TCPAvailableLanguages sharedInstance];
    
    TCPTranslationModel *fakeModel = [[TCPTranslationModel alloc] init];
    fakeModel.fromText = @"Hello";
    fakeModel.fromLanguage = [languages languageByLongCode:@"en-US"];
    fakeModel.toText = @"你好";
    fakeModel.toLanguage = [languages languageByLongCode:@"zh-CN"];
    
    TCPTranslationModel *fakeModel2 = [[TCPTranslationModel alloc] init];
    fakeModel2.fromText = @"Google has pushed around eight big Glass updates since the Explorer program launched less than a year ago, which is a surprisingly steady pace given how slow it takes to get Android updates out.";
    fakeModel2.fromLanguage = [languages languageByLongCode:@"en-US"];
    fakeModel2.toText = @"谷歌一直推来推去八大玻璃更新，因为资源管理器程序推出不到一年前，这是一个令人惊讶的稳步给出了如何慢需要得到Android的更新了。";
    fakeModel2.toLanguage = [languages languageByLongCode:@"zh-CN"];
    
    self.translations = [[NSMutableArray alloc] init];
    [self.translations addObject:fakeModel2];
    [self.translations addObject:fakeModel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setup];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // add search bar
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    self.searchBar = searchBar;
    self.searchBar.delegate = self;
    [self.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchBar;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.translations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCPTranslationModel *model = [self.translations objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"TranslationCell";
    TCPTranslationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    cell.model = model;
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)calculateHeightForText:(NSString *)text fontSize:(CGFloat)fontSize
{
    CGFloat width = self.view.frame.size.width - [TCPTranslationCell horizontalMargins]; // margins
    
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGRect frame = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:attributes
                                      context:nil];
    
    return frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCPTranslationModel *model = [self.translations objectAtIndex:indexPath.row];

    CGFloat height = [self calculateHeightForText:model.fromLanguage.englishName
                                         fontSize:12.0];
    height += [self calculateHeightForText:model.fromText
                                  fontSize:13.0];
    height += [self calculateHeightForText:model.toLanguage.englishName
                                  fontSize:12.0];
    height += [self calculateHeightForText:model.toText
                                  fontSize:13.0];
    
    return height + [TCPTranslationCell verticalMargins];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    
    TCPTranslationModel *model = [self.translations objectAtIndex:indexPath.row];
    
    TCPTranslationDetailViewController *detailVC = [[TCPTranslationDetailViewController alloc] initWithNibName:@"TCPTranslationDetailViewController" bundle:nil];

    detailVC.model = model;

    [self.navigationController pushViewController:detailVC
                                         animated:YES];
//    [UIView animateWithDuration:1.0
//                     animations:^{
//                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//                         [self.navigationController pushViewController:detailVC animated:NO];
//                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
//                                                forView:self.navigationController.view
//                                                  cache:NO];
//                     }];
}


#pragma mark - search bar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

@end
