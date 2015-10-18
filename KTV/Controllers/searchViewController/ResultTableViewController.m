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
@interface ResultTableViewController ()<UITableViewDataSource,UITableViewDelegate,searchSongDelegate,UISearchBarDelegate> {
    NSInteger _previousRow;
    BOOL canSearch;
}
@property (nonatomic,strong)NSIndexPath *selectedIndexPath;
@property (nonatomic,strong)NSMutableArray *dataList;
@property (nonatomic,strong)NSMutableArray *singerList;
@property (nonatomic,strong)FMDatabase *searchDb;

@end

@implementation ResultTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _previousRow=-1;
    canSearch=YES;
    _searchSelectIndex = 0;
    _dataList = [[NSMutableArray alloc] init];
    _singerList = [[NSMutableArray alloc] init];
    [self initializeSearchController];
    _searchDb = [DataMananager instanceShare].db;
    [_searchDb open];
}

- (void)initializeSearchController {
//    UINib *nib=[UINib nibWithNibName:@"SearchTableCell" bundle:nil];
//    [self.tableView registerNib:nib forCellReuseIdentifier:TOPCELLIDENTIFY];
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
/*
#pragma mark - use song cell or singer cell
- (SearchTableCell*)songCell :(UITableView*)tableView :(NSIndexPath*)indexPath {
    SearchTableCell *cell = [tableView dequeueReusableCellWithIdentifier:TOPCELLIDENTIFY forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.oneSong=self.dataList[indexPath.row];
    cell.backgroundColor=[UIColor clearColor];
    if (cell.opened) {
        cell.sanjiaoxing.hidden=NO;
    } else {
        cell.sanjiaoxing.hidden=YES;
    }
    return cell;
}
- (SingsTableViewCell*)singerCell :(UITableView*)tableView :(NSIndexPath*)indexPath {
    SingsTableViewCell *singerCell = [tableView dequeueReusableCellWithIdentifier:SINGERCELLIDENTIFY];
    if (!singerCell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:SINGERCELLIDENTIFY owner:self options:nil];
        singerCell = [nib objectAtIndex:0];
        singerCell.backgroundColor=[UIColor clearColor];
        singerCell.singer = self.dataList[indexPath.row];
        [singerCell.SingerLabel setTextColor:[UIColor groupTableViewBackgroundColor]];
        return singerCell;
    }else {
        return nil;
    }
} */
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
    [cell configWithObject:_dataList[indexPath.row]];
//    if (_previousRow >= 0 && _previousRow+1==indexPath.row) {
//        SongBottomCell *cell=[tableView dequeueReusableCellWithIdentifier:BOTTOMCELLIDENTIFY];
//        if (!cell) {
//            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:BOTTOMCELLIDENTIFY owner:self options:nil];
//            cell = [nib objectAtIndex:0];
//            cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"song_bt_bg"]];
//            cell.oneSong=self.dataList[_previousRow];
//            
//        }
//        return cell;
//    } else {
//        if (_searchSelectIndex == 0) {//查询全部
//            if ([self.dataList[indexPath.row] isKindOfClass:[Song class]]) {
//                return [self songCell:tableView :indexPath];
//            }else {
//                return [self singerCell:tableView :indexPath];
//            }
//            
//        }else if(_searchSelectIndex == searchSong) {//查询单个
//            return [self songCell:tableView :indexPath];
//        }else {
//            return [self singerCell:tableView :indexPath];
//        }
//    }
    return cell;
    
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
//    return 45.0f;
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id object=_dataList[indexPath.row];
    if ([object isKindOfClass:[Singer class]]) {
        if ([_delegate respondsToSelector:@selector(clickSinger:)]) {
            [_delegate clickSinger:(Singer*)object];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(clickSong:)]) {
            [_delegate clickSong:(Song*)object];
        }
      }
    
    //    if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[SearchTableCell class]]) {
//    SearchTableCell *cell=(SearchTableCell*)[tableView cellForRowAtIndexPath:indexPath];
//    if (cell.opened) {
//        cell.sanjiaoxing.hidden=NO;
//    } else {
//        cell.sanjiaoxing.hidden=YES;
//    }
//    if (_previousRow >= 0) {
//        NSIndexPath *preIndexPath=[NSIndexPath indexPathForRow:_previousRow inSection:0];
//        SearchTableCell *preCell=(SearchTableCell*)[tableView cellForRowAtIndexPath:preIndexPath];
//        
//        if (indexPath.row == _previousRow + 1) {
//        }
//        else if (indexPath.row == _previousRow) {
//            cell.opened=!cell.opened;
//            if (cell.opened) {
//                cell.sanjiaoxing.hidden=NO;
//            } else {
//                cell.sanjiaoxing.hidden=YES;
//            }
//            [_dataList removeObjectAtIndex:_previousRow+1];
//            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//            _previousRow = -1;
//        }
//        else if (indexPath.row < _previousRow) {
//            if (preCell.opened) {
//                preCell.sanjiaoxing.hidden=NO;
//            } else {
//                preCell.sanjiaoxing.hidden=YES;
//            }
//            
//            [_dataList removeObjectAtIndex:_previousRow+1];
//            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//            _previousRow = indexPath.row;
//            [_dataList insertObject:@"增加的" atIndex:indexPath.row+1];
//            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
//        }
//        else {
//            if (preCell.opened) {
//                preCell.sanjiaoxing.hidden=NO;
//            } else {
//                preCell.sanjiaoxing.hidden=YES;
//            }
//            
//            NSInteger oler=_previousRow;
//            _previousRow = indexPath.row;
//            [_dataList insertObject:@"增加的" atIndex:indexPath.row+1];
//            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
//            [_dataList removeObjectAtIndex:oler+1];
//            _previousRow -=1;
//            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oler+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//        }
//        
//    } else {
//        _previousRow = indexPath.row;
//        [_dataList insertObject:@"增加的" atIndex:_previousRow+1];
//        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
//    }
//    }else {
//        SingsTableViewCell *cell=[self singerCell:tableView :indexPath];
//        if ([_delegate respondsToSelector:@selector(clickSingerWithSingerName:)]) {
//            [_delegate clickSingerWithSingerName:cell.singer.singer];
//        }
//    }
//    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)reloadData {
    if (self.dataList.count > 0) {
        if ([self.delegate respondsToSelector:@selector(searching)]) {
            [self.delegate searching];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(searchDone)]) {
            [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [self.delegate searchDone];
        }
    }
    [self.tableView reloadData];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchStr=[searchController.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self.dataList removeAllObjects];
    if (!canSearch) return;
    if ( searchStr && searchStr.length>0) {
        canSearch=NO;
        [self initializeTableContent:searchStr];
    } else {
        canSearch=YES;
        [self reloadData];
    }
    
}

#pragma mark - sql method
- (void)searchSongData:(NSString*)tableName :(NSString*)conditionColumn :(NSString*)searchStr :(NSString*)column {
    NSString *temStr = [NSString stringWithFormat:@"%@%@",searchStr,@"%"];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE songname LIKE '%@' OR %@ LIKE '%@'",tableName,temStr,conditionColumn,temStr];
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
}

- (void)searchSingData:(NSString*)tableName :(NSString*)conditionColumn :(NSString*)searchStr :(NSString*)column {
    NSString *temStr = [NSString stringWithFormat:@"%@%@",searchStr,@"%"];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE singer LIKE '%@' OR  %@ LIKE '%@'",tableName,temStr,conditionColumn,temStr];
    FMResultSet *rs = [_searchDb executeQuery:sql];
    while ([rs next]) {
//        Singer *tempSinger = [[Singer alloc] init];
//        tempSinger.singer = [rs stringForColumn:column];
//        [self.dataList addObject:tempSinger];
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
    [self.dataList removeAllObjects];
    [self.singerList removeAllObjects];
    if (_searchSelectIndex == searchAll) {
        [self searchSongData:SONGTABLE :@"songpiy" :enCodeSearchStr :@"songname"];
        [self searchSingData:SINGERTABLE :@"pingyin" :enCodeSearchStr :@"singer"];
        
    }else if (_searchSelectIndex == searchSong){
        [self searchSongData:SONGTABLE :@"songpiy" :enCodeSearchStr :@"songname"];
    }else {
        [self searchSingData:SINGERTABLE :@"pingyin" :enCodeSearchStr :@"singer"];
    }
    canSearch = YES;
    [self reloadData];

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
@end
