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
#import "SearchSongResultCell.h"
#import "WebImage.h"
NSString *const SFCellIdentifierSinger = @"SFCellIdentifierSinger";
NSString *const SFCellIdentifierSong = @"SFCellIdentifierSong";

@implementation APLResultsTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
    [self.tableView registerClass:[SearchResultCell class] forCellReuseIdentifier:SFCellIdentifierSinger];
        [self.tableView registerClass:[SearchSongResultCell class] forCellReuseIdentifier:SFCellIdentifierSong];
    self.tableView.showsHorizontalScrollIndicator=NO;
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredProducts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=nil;
    if ([self.filteredProducts[indexPath.row] isKindOfClass:[Singer class]]) {
      cell = (SearchResultCell *)[self.tableView dequeueReusableCellWithIdentifier:SFCellIdentifierSinger];

    } else {
    cell = (SearchSongResultCell *)[self.tableView dequeueReusableCellWithIdentifier:SFCellIdentifierSong];
    }
    cell.contentView.backgroundColor=[UIColor clearColor];
    cell.backgroundColor=[UIColor clearColor];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if ([self.filteredProducts[indexPath.row] isKindOfClass:[Song class]]) {
        [(SearchSongResultCell*)cell setOneSong:self.filteredProducts[indexPath.row]];
    }
    [self configureCell:cell forProduct:self.filteredProducts[indexPath.row]];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cellObject forProduct:(id)object {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (object==nil) return;
        if ([object isKindOfClass:[Singer class]]) {
            Singer *oneSinger=(Singer*)object;
            SearchResultCell*cell=(SearchResultCell*)cellObject;
            cell.titleLabel.text=oneSinger.singer;
            NSString *urlStr=[[NSString stringWithFormat:@"http://%@:8080/puze?cmd=0x02&filename=%@",[Utility instanceShare].serverIPAddress,oneSinger.singer]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [cell.header sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"Default_Header"]];
        } else if ([object isKindOfClass:[Song class]]){
            SearchSongResultCell*cell=(SearchSongResultCell*)cellObject;
            cell.header.image=[UIImage imageNamed:@"music_icon"];
        }
    });

}



@end