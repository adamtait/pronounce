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

@interface TCPFavoritesTableViewController ()
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
    
    self.translations = [[NSMutableArray alloc] init];
    [self.translations addObject:fakeModel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setup];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

@end
