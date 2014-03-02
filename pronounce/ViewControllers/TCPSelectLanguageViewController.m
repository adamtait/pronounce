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
@property (weak, nonatomic) IBOutlet UILabel *translateLabel;
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
    
    self.translateLabel.text = self.selectionTitle;
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
    cell.checked = [self.currentLanguage.ietfLongCode isEqualToString:cell.model.ietfLongCode];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCPLanguageCell *cell = (TCPLanguageCell *)[tableView cellForRowAtIndexPath:indexPath];

    __weak id <TCPSelectLanguageDelegate> weakDelegate = self.selectLanguageDelegate;
    NSString *selectionTitleCopy = [self.selectionTitle copy];
    [self dismissViewControllerAnimated:YES completion:^{
        [weakDelegate selectLanguage:cell.model selectionTitle:selectionTitleCopy];
    }];
}

@end
