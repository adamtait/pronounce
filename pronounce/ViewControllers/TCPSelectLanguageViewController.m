//
//  TCPSelectLanguageViewController.m
//  pronounce
//
//  Created by Jonathan Xu on 2/9/14.
//  Copyright (c) 2014 Team Canada. All rights reserved.
//

#import "TCPSelectLanguageViewController.h"
#import "TCPAvailableLanguages.h"
#import "TCPLanguageCell.h"

@interface TCPSelectLanguageViewController ()
@property (weak, nonatomic) TCPAvailableLanguages *availableLanguages;
@property (weak, nonatomic) IBOutlet UITableView *languagesTableView;
@end

@implementation TCPSelectLanguageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.availableLanguages = [TCPAvailableLanguages sharedInstance];
    
    UINib *languageCellNib = [UINib nibWithNibName:@"TCPLanguageCell" bundle:nil];
    [self.languagesTableView registerNib:languageCellNib forCellReuseIdentifier:@"languageCell"];
    self.languagesTableView.rowHeight = 80;
    
    self.languagesTableView.dataSource = self;
    self.languagesTableView.delegate = self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.availableLanguages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"languageCell";
    TCPLanguageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.model = [self.availableLanguages objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCPLanguageCell *cell = (TCPLanguageCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self.selectLanguageDelegate selectLanguage:cell.model];
}

@end
