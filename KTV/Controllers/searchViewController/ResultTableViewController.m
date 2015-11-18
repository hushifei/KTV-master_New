//
//  ResultTableViewController.m
//  ZZKTV
//
//  Created by stevenhu on 15/3/30.
//  Copyright (c) 2015年 zz. All rights reserved.
//

#import "ResultTableViewController.h"
#import "Song.h"
#import "Singer.h"
#import "Utility.h"
#import "PinYinForObjc.h"
//#define TOPCELLIDENTIFY @"SearchTableCell"
//#import "SearchTableCell.h"
//#define BOTTOMCELLIDENTIFY @"SongBottomCell"
//#define SINGERCELLIDENTIFY @"SingsTableViewCell"
//#import "SongBottomCell.h"
#import "SearchResultCell.h"
#define CELL_IDENTIFY @"CELL_IDENTIFY"

#import "MBProgressHUD.h"
//#import "SingsTableViewCell.h"
#define SONGTABLE @"SongTable"
#define SINGERTABLE @"SingerTable"
#import "NSString+Utility.h"
#import "DataMananager.h"

#import "BaseNavigationController.h"
#import "SongListViewController.h"
#import "SearchSongListViewController.h"
@interface ResultTableViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate> {
    NSInteger _previousRow;
    BOOL canSearch;
    NSString *olderStr;

    NSMutableArray *searchArray;
}
@property (nonatomic,strong)NSIndexPath *selectedIndexPath;
@property (nonatomic,strong)FMDatabase *searchDb;

@end

@implementation ResultTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _previousRow=-1;
    canSearch=YES;
    _searchSelectIndex = 0;
    _dataList = [[NSMutableArray alloc] init];
    searchArray=[[NSMutableArray alloc]init];
    [self initializeSearchController];
    _searchDb = [DataMananager instanceShare].db;
    [_searchDb open];
}

- (void)initializeSearchController {
//    self.definesPresentationContext = YES;
    self.edgesForExtendedLayout=UIRectEdgeNone;
    [self.tableView registerClass:[SearchResultCell class] forCellReuseIdentifier:CELL_IDENTIFY];
    _previousRow = -1;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight=50;
    self.tableView.showsHorizontalScrollIndicator=NO;
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.backgroundColor=[UIColor clearColor];
    UIView *backView=[[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.tableFooterView=backView;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultCell *cell=[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFY forIndexPath:indexPath];
    if (!cell) {
        cell=[[SearchResultCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFY];
    }
    cell.contentView.backgroundColor=[UIColor clearColor];
    cell.backgroundColor=[UIColor clearColor];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [cell configWithObject:_dataList[indexPath.row]];
    });
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return 45.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id object=_dataList[indexPath.row];
    if (object==nil) return;
    SongListViewController *songVC=[[SongListViewController alloc]init];
    if ([object isKindOfClass:[Singer class]]) {
        songVC.singerName=[(Singer*)object singer];
        songVC.needLoadData=YES;
    } else {
        songVC.needLoadData=NO;
        [songVC setDataList:object];
    }
    [self.searchSongListVC.navigationController pushViewController:songVC animated:NO];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)reloadData {
    if (self.dataList && self.dataList.count > 0) {
            [self.tableView reloadData];
    }
    canSearch = YES;
}
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchStr=[searchController.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!canSearch) return;
    if (searchStr && searchStr.length>0 && ![olderStr isEqualToString:searchStr]) {
        if (self.dataList.count>0) {
            [self.dataList removeAllObjects];
        }
        canSearch=NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self initializeTableContent:searchStr];
        });
        olderStr=searchStr;
    } else {
        canSearch=YES;
    }
    
}

#pragma mark - sql method
- (void)searchSongData:(NSString*)tableName :(NSString*)conditionColumn :(NSString*)searchStr :(NSString*)column {
    NSString *temStr = [NSString stringWithFormat:@"%@%@%@",@"%",searchStr,@"%"];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE songname LIKE '%@' OR %@ LIKE '%@'" ,tableName,temStr,conditionColumn,temStr];
//    NSLog(@"song:\n%@",sql);
    FMResultSet *rs = [_searchDb executeQuery:sql];
    while ([rs next]) {
        Song *oneSong=[[Song alloc]init];
        oneSong.addtime = [rs stringForColumn:@"addtime"];
        oneSong.bihua = [rs stringForColumn:@"bihua"];
        oneSong.channel = [rs stringForColumn:@"channel"];
        oneSong.language = [rs stringForColumn:@"language"];
        oneSong.movie = [rs stringForColumn:@"movie"];
        oneSong.newsong = [rs stringForColumn:@"newsong"];
        oneSong.number = [rs stringForColumn:@"number"];
        oneSong.pathid = [rs stringForColumn:@"pathid"];
        oneSong.sex = [rs stringForColumn:@"sex"];
        oneSong.singer = [rs stringForColumn:@"singer"];
        oneSong.singer1 = [rs stringForColumn:@"singer1"];
        oneSong.songname = [rs stringForColumn:@"songname"];
        oneSong.songpiy = [rs stringForColumn:@"songpiy"];
        oneSong.spath = [rs stringForColumn:@"spath"];
        oneSong.stype = [rs stringForColumn:@"stype"];
        oneSong.volume = [rs stringForColumn:@"volume"];
        oneSong.word = [rs stringForColumn:@"word"];
//        NSLog(@"%@",oneSong.songname);
        [self.dataList addObject:oneSong];
    }
} // limit 20

- (void)searchSingData:(NSString*)tableName :(NSString*)conditionColumn :(NSString*)searchStr :(NSString*)column {
    NSString *temStr = [NSString stringWithFormat:@"%@%@%@",@"%",searchStr,@"%"];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE singer LIKE '%@' OR  %@ LIKE '%@'",tableName,temStr,conditionColumn,temStr];
//    NSLog(@"singer:\n%@",sql);
    FMResultSet *rs = [_searchDb executeQuery:sql];
    while ([rs next]) {
        Singer *oneSinger=[[Singer alloc]init];
        oneSinger.area = [rs stringForColumn:@"area"];
        oneSinger.pingyin = [rs stringForColumn:@"pingyin"];
        oneSinger.s_bi_hua = [rs stringForColumn:@"s_bi_hua"];
        oneSinger.singer = [rs stringForColumn:@"singer"];
        //        NSLog(@"%@",oneSinger.singer);
        [self.dataList addObject:oneSinger];
       
    }
}


- (void)initializeTableContent:(NSString*)searchStr {
     NSString *enCodeSearchStr = [[searchStr uppercaseString] encodeBase64];
    [searchArray addObject:enCodeSearchStr];
    if (_searchSelectIndex == searchAll) {
        
        [self searchSongData:SONGTABLE :@"songpiy" :enCodeSearchStr :@"songname"];
        
        [self searchSingData:SINGERTABLE :@"pingyin" :enCodeSearchStr :@"singer"];
        
        
    }else if (_searchSelectIndex == searchSong){
        [self searchSongData:SONGTABLE :@"songpiy" :enCodeSearchStr :@"songname"];
    }else {
        [self searchSingData:SINGERTABLE :@"pingyin" :enCodeSearchStr :@"singer"];
    }
    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    canSearch=YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"searchBarCancelButtonClicked");
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searchBarResultsListButtonClicked");
}
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    NSLog(@"currentSlectedIndex:%ld",(long)selectedScope);
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    UIButton *cancelButton;
    UIView *topView = searchBar.subviews[0];
    for (UIView *subView in topView.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
            cancelButton = (UIButton*)subView;
        }
    }
    if (cancelButton) {
        //Set the new title of the cancel button
        [cancelButton setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
        cancelButton.tintColor = [UIColor whiteColor];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    canSearch=YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 20)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 20, 0, 20)];
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 20)];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 20, 0, 20)];
    }
}

#pragma mark - SelectViewOnSelectedDelegate
- (void)selectViewOnSelectedIndex:(NSUInteger)index {
    NSLog(@"%lu",(unsigned long)index);
    switch (index) {
        case 0:
            _searchSelectIndex = searchAll;
            break;
        case 1:
            _searchSelectIndex = searchSong;
            break;
        case 2:
            _searchSelectIndex = searchSinger;
            break;
        default:
            break;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
