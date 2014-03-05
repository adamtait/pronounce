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
#import "TCPUserProperties.h"
#import "TCPFavoriteTranslationModel.h"

@interface TCPFavoritesTableViewController () <UISearchBarDelegate>
@property (weak, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *translations;
@end

@implementation TCPFavoritesTableViewController

- (void)setup
{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    UINib *translationCellNib = [UINib nibWithNibName:@"TCPTranslationCell" bundle:nil];
    [self.tableView registerNib:translationCellNib forCellReuseIdentifier:@"TranslationCell"];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
}

#pragma mark - Table view data source

- (void)reloadData
{
    __weak TCPFavoritesTableViewController *weakSelf = self;
    [TCPFavoriteTranslationModel favoritesWithCompletion:^(NSArray *models)
     {
         weakSelf.translations = [[NSMutableArray alloc] initWithArray:models];
     }];
}

- (void)setTranslations:(NSMutableArray *)translations
{
    _translations = translations;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.translations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCPFavoriteTranslationModel *model = [self.translations objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"TranslationCell";
    TCPTranslationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    cell.model = model.translation;
    cell.favoriteTranslationModel = model;
    
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
    TCPFavoriteTranslationModel *favoriteModel = [self.translations objectAtIndex:indexPath.row];
    TCPTranslationModel *model = favoriteModel.translation;

    CGFloat height = [self calculateHeightForText:model.fromLanguage.englishName
                                         fontSize:12.0];
    height += [self calculateHeightForText:model.phrase
                                  fontSize:13.0];
    height += [self calculateHeightForText:model.toLanguage.englishName
                                  fontSize:12.0];
    height += [self calculateHeightForText:model.exampleTranslation
                                  fontSize:13.0];
    
    return height + [TCPTranslationCell verticalMargins];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    
    TCPFavoriteTranslationModel *model = [self.translations objectAtIndex:indexPath.row];
    
    TCPTranslationDetailViewController *detailVC = [[TCPTranslationDetailViewController alloc] initWithNibName:@"TCPTranslationDetailViewController" bundle:nil];

    detailVC.model = model.translation;

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
