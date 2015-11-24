/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The table view controller responsible for displaying the filtered products as the user types in the search field.
 */

#import "APLResultsTableController.h"
#import "Song.h"
#import "Singer.h"
#import "SearchResultCell.h"
#import "WebImage.h"
NSString *const SFCellIdentifier = @"SearchResultCell_Identify";
@implementation APLResultsTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
    [self.tableView registerClass:[SearchResultCell class] forCellReuseIdentifier:SFCellIdentifier];
    self.tableView.showsHorizontalScrollIndicator=NO;
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredProducts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultCell *cell = (SearchResultCell *)[self.tableView dequeueReusableCellWithIdentifier:SFCellIdentifier];
    cell.contentView.backgroundColor=[UIColor clearColor];
    cell.backgroundColor=[UIColor clearColor];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    [self configureCell:cell forProduct:self.filteredProducts[indexPath.row]];
    return cell;
}

- (void)configureCell:(SearchResultCell *)cell forProduct:(id)object {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (object==nil) return;
        if ([object isKindOfClass:[Singer class]]) {
            Singer *oneSinger=(Singer*)object;
            cell.titleLabel.text=oneSinger.singer;
            NSString *urlStr=[[NSString stringWithFormat:@"http://%@:8080/puze?cmd=0x02&filename=%@",[Utility instanceShare].serverIPAddress,oneSinger.singer]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [cell.header sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"Default_Header"]];
        } else if ([object isKindOfClass:[Song class]]){
            cell.header.image=[UIImage imageNamed:@"music_icon"];
            cell.titleLabel.text=[(Song*)object songname];
        }
    });
    
 
}



@end