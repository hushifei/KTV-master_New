 //
//  newSongViewController.m
//  KTV
//
//  Created by stevenhu on 15/4/25.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import "newSongViewController.h"
#define TOPCELLIDENTIFY @"SongTopCell"
#define BOTTOMCELLIDENTIFY @"newSongBottomCell"
#import "SongTopCell.h"
#import "newSongBottomCell.h"
#import "YiDianViewController.h"
#import "BBBadgeBarButtonItem.h"
#import "MBProgressHUD.h"
#import "Song.h"
#import "DataMananager.h"
#import "CommandControler.h"
@interface newSongViewController ()<MBProgressHUDDelegate,SongDelegate> {
    NSInteger _previousRow;
    HuToast *myToast;
}
@end

@implementation newSongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=NSLocalizedString(@"newsong", nil);
    myToast=[[HuToast alloc]init];
    UIImageView *bgImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"newSong_bg"]];
    self.tableView.backgroundView=bgImageView;
//    UINib *nib=[UINib nibWithNibName:@"SongTopCell" bundle:nil];
//    [self.tableView registerNib:nib forCellReuseIdentifier:TOPCELLIDENTIFY];
    _previousRow = -1;
    UIImageView  *headerImageV=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    [headerImageV setImage:[UIImage imageNamed:@"newsong_header"]];
    self.tableView.tableHeaderView=headerImageV;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight=54;
    totalRowCount=300;
    [self loadMJRefreshingView];
}

- (void)initializeTableContent{
    NSString *newSongFlag=[@"1" encodeBase64];
    NSString *sqlStr= [NSString stringWithFormat:@"select * from SongTable where newsong='%@' ORDER BY singer limit %d OFFSET %@",newSongFlag,pageLimint,offset];
    FMResultSet *rs=[[DataMananager instanceShare].db executeQuery:sqlStr];
    while ([rs next]) {
        Song *oneSong=[[Song alloc]init];
        oneSong.number = [rs stringForColumn:@"number"];
        oneSong.songname = [rs stringForColumn:@"songname"];
        oneSong.singer = [rs stringForColumn:@"singer"];
        oneSong.singer1 = [rs stringForColumn:@"singer1"];
        oneSong.songpiy = [rs stringForColumn:@"songpiy"];
        oneSong.word = [rs stringForColumn:@"word"];
        oneSong.language = [rs stringForColumn:@"language"];
        oneSong.volume = [rs stringForColumn:@"volume"];
        oneSong.channel = [rs stringForColumn:@"channel"];
        oneSong.sex = [rs stringForColumn:@"sex"];
        oneSong.stype = [rs stringForColumn:@"stype"];
        oneSong.newsong = [rs stringForColumn:@"newsong"];
        oneSong.movie = [rs stringForColumn:@"movie"];
        oneSong.pathid = [rs stringForColumn:@"pathid"];
        oneSong.bihua = [rs stringForColumn:@"bihua"];
        oneSong.addtime = [rs stringForColumn:@"addtime"];
        oneSong.spath = [rs stringForColumn:@"spath"];
        [dataList addObject:oneSong];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
    BBBadgeBarButtonItem *barButton = (BBBadgeBarButtonItem *)self.navigationItem.rightBarButtonItem;
    __weak __typeof(BBBadgeBarButtonItem*)weakBarButton=barButton;
    [CommandControler setYidianBadgeWidth:weakBarButton completed:^(BOOL completed, NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_previousRow >= 0 && _previousRow+1==indexPath.row) {
        newSongBottomCell *cell=[tableView dequeueReusableCellWithIdentifier:BOTTOMCELLIDENTIFY];
        if (!cell) {
            cell = [[newSongBottomCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BOTTOMCELLIDENTIFY];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"song_bt_bg"]];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        cell.oneSong=dataList[_previousRow];
        cell.oneSong.delegate=self;
        return cell;
    } else {
//        SongTopCell *cell=[[SongTopCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%@_%d",TOPCELLIDENTIFY,(int)indexPath.row]];
//        SongTopCell *cell = [tableView dequeueReusableCellWithIdentifier:TOPCELLIDENTIFY forIndexPath:indexPath];
        SongTopCell *cell= [[[NSBundle mainBundle] loadNibNamed:@"SongTopCell" owner:nil options:nil] firstObject];
        cell.numberStr.text =[NSString stringWithFormat:@"%02d",(int)indexPath.row+1];
        cell.numberStr.font=[UIFont fontWithName:@"DIN Condensed" size:22];
        cell.oneSong=dataList[indexPath.row];
        cell.buttonitem=self.navigationItem.rightBarButtonItem;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor clearColor];
        if (cell.opened) {
            cell.sanjiaoxing.hidden=NO;
        } else {
            cell.sanjiaoxing.hidden=YES;
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    return nil;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SongTopCell *cell=(SongTopCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:[SongTopCell class]]) return;
    if (_previousRow >= 0) {
        NSIndexPath *preIndexPath=[NSIndexPath indexPathForRow:_previousRow inSection:0];
        SongTopCell *preCell=(SongTopCell*)[tableView cellForRowAtIndexPath:preIndexPath];
        if (indexPath.row == _previousRow) {
            cell.sanjiaoxing.hidden=!(cell.opened=!cell.opened);
            [dataList removeObjectAtIndex:indexPath.row +1];
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row +1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            _previousRow = -1;
        }  else if (indexPath.row < _previousRow) {
            cell.sanjiaoxing.hidden=!(cell.opened=!cell.opened);
            preCell.sanjiaoxing.hidden=!(preCell.opened=!preCell.opened);
            [dataList removeObjectAtIndex:_previousRow+1];
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            _previousRow = indexPath.row;
            [dataList insertObject:@"增加的" atIndex:indexPath.row+1];
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        } else {
            cell.sanjiaoxing.hidden=!(cell.opened=!cell.opened);
            preCell.sanjiaoxing.hidden=!(preCell.opened=!preCell.opened);
            NSInteger oler=_previousRow;
            _previousRow = indexPath.row;
            [dataList insertObject:@"增加的" atIndex:indexPath.row+1];
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [dataList removeObjectAtIndex:oler+1];
            _previousRow -=1;
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oler+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    } else {
        cell.sanjiaoxing.hidden=!(cell.opened=!cell.opened);
        _previousRow = indexPath.row;
        [dataList insertObject:@"增加的" atIndex:_previousRow+1];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return dataList.count;
}


-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - SongBottom delegate
- (void)addSongToCollection:(Song *)oneSong result:(KMessageStyle)result {
    if(_previousRow<=-1) return;
        switch (result) {
            case KMessageSuccess: {
                NSIndexPath *indexPath=[NSIndexPath indexPathForItem:_previousRow inSection:0];
                SongTopCell *cell=(SongTopCell*)[self.tableView cellForRowAtIndexPath:indexPath];
                cell.opened=!cell.opened;
                if (cell.opened) {
                    cell.sanjiaoxing.hidden=NO;
                } else {
                    cell.sanjiaoxing.hidden=YES;
                }
                [dataList removeObjectAtIndex:_previousRow+1];
                [self.tableView  deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                _previousRow=-1;
                [HuToast showToastWithMessage:@"成功收藏"  WithTimeDismiss:nil messageType:KMessageSuccess];
                break;
            }
            case KMessageStyleError: {
                [HuToast showToastWithMessage:@"收藏出错了,请重发"  WithTimeDismiss:nil messageType:KMessageStyleError];
                
                break;
            }
            case KMessageWarning: {
                [HuToast showToastWithMessage:@"查询收藏出错了,请重发"  WithTimeDismiss:nil messageType:KMessageStyleError];
                break;
            }
            case KMessageStyleInfo: {
                NSIndexPath *indexPath=[NSIndexPath indexPathForItem:_previousRow inSection:0];
                SongTopCell *cell=(SongTopCell*)[self.tableView cellForRowAtIndexPath:indexPath];
                cell.opened=!cell.opened;
                if (cell.opened) {
                    cell.sanjiaoxing.hidden=NO;
                } else {
                    cell.sanjiaoxing.hidden=YES;
                }
                [dataList removeObjectAtIndex:_previousRow+1];
                [self.tableView  deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                _previousRow=-1;
                [HuToast showToastWithMessage:@"此歌已收藏"  WithTimeDismiss:nil messageType:KMessageStyleInfo];
                break;
            }
            case KMessageStyleDefault: {
                break;
            }
            default:
                break;
        }
    
}

- (void)dingGeFromCollection:(Song *)oneSong result:(KMessageStyle)result {
    //ding ge
    if(_previousRow<=-1) return;
    NSIndexPath *indexPath=[NSIndexPath indexPathForItem:_previousRow inSection:0];
    SongTopCell *cell=(SongTopCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.opened=!cell.opened;
    if (cell.opened) {
        cell.sanjiaoxing.hidden=NO;
    } else {
        cell.sanjiaoxing.hidden=YES;
    }
    [dataList removeObjectAtIndex:_previousRow+1];
    [self.tableView  deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    _previousRow=-1;
        [HuToast showToastWithMessage:@"顶歌成功" WithTimeDismiss:nil messageType:KMessageSuccess];
    //TODO::
    BBBadgeBarButtonItem *barButton = (BBBadgeBarButtonItem *)self.navigationItem.rightBarButtonItem;
    __weak __typeof(BBBadgeBarButtonItem*)weakBarButton=barButton;
    [CommandControler setYidianBadgeWidth:weakBarButton completed:^(BOOL completed, NSError *error) {
    }];
}

- (void)cutSongFromCollection:(Song *)oneSong result:(KMessageStyle)result {
    if(_previousRow<=-1) return;
    NSIndexPath *indexPath=[NSIndexPath indexPathForItem:_previousRow inSection:0];
    SongTopCell *cell=(SongTopCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.opened=!cell.opened;
    if (cell.opened) {
        cell.sanjiaoxing.hidden=NO;
    } else {
        cell.sanjiaoxing.hidden=YES;
    }
    [dataList removeObjectAtIndex:_previousRow+1];
    [self.tableView  deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    _previousRow=-1;
    [HuToast showToastWithMessage:@"切歌成功" WithTimeDismiss:nil messageType:KMessageSuccess];
    [self performSelector:@selector(updateYidanBadge) withObject:self afterDelay:0.5];
}

- (void)updateYidanBadge {
    BBBadgeBarButtonItem *barButton = (BBBadgeBarButtonItem *)self.navigationItem.rightBarButtonItem;
    __weak __typeof(BBBadgeBarButtonItem*)weakBarButton=barButton;
    [CommandControler setYidianBadgeWidth:weakBarButton completed:^(BOOL completed, NSError *error) {
        
    }];
}

#pragma mark -#########################################################


@end
