//
//  ViewController.m
//  Table
//
//  Created by ywx272253 on 15/4/24.
//  Copyright (c) 2015年 com.huawei.hwcloud. All rights reserved.
//

#import "SongListViewController.h"
#define TOPCELLIDENTIFY @"newSongListTopCell"
#import "newSongListTopCell.h"
#define BOTTOMCELLIDENTIFY @"SongBottomCell"
#import "SongBottomCell.h"
#import "YiDianViewController.h"
#import "Song.h"
#import "BBBadgeBarButtonItem.h"
#import "SettingViewController.h"
#import "BokongView.h"
#import "SoundViewController.h"
#import "MBProgressHUD.h"
#import "CommandControler.h"
#import "NSString+Utility.h"
#import "DataManager.h"
@interface SongListViewController ()<SongDelegate>
{
    NSInteger _previousRow;
    HuToast *myToast;
    NSInteger offset;
    Song *searchSong;
}
@end

@implementation SongListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _previousRow = -1;
    myToast=[[HuToast alloc]init];
    self.title=NSLocalizedString(@"songs", nil);
    [self.tableView registerClass:[newSongListTopCell class] forCellReuseIdentifier:TOPCELLIDENTIFY];

//    UINib *nib=[UINib nibWithNibName:TOPCELLIDENTIFY bundle:nil];
//    [self.tableView registerNib:nib forCellReuseIdentifier:TOPCELLIDENTIFY];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    UIImageView *bgImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"songsList_bg"]];
    self.tableView.backgroundView=bgImageView;
    self.tableView.rowHeight=50;
    if (self.needLoadData) {
        [self initializeTableContent];
    } else {
        if (searchSong) {
            [dataList addObject:searchSong];
            [self.tableView reloadData];
            self.needLoadData=YES;
        }
    }
}

-(void)setDataList:(Song*)oneSong {
    if (![oneSong isKindOfClass:[Song class]] || oneSong==nil) return;
    searchSong=oneSong;
}

- (void)viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
    BBBadgeBarButtonItem *barButton = (BBBadgeBarButtonItem *)self.navigationItem.rightBarButtonItem;
    __weak __typeof(BBBadgeBarButtonItem*)weakBarButton=barButton;
    [CommandControler setYidianBadgeWidth:weakBarButton completed:^(BOOL completed, NSError *error) {
        
    }];
}

- (void)updateYidanBadge {
    BBBadgeBarButtonItem *barButton = (BBBadgeBarButtonItem *)self.navigationItem.rightBarButtonItem;
    __weak __typeof(BBBadgeBarButtonItem*)weakBarButton=barButton;
    [CommandControler setYidianBadgeWidth:weakBarButton completed:^(BOOL completed, NSError *error) {
        
    }];
}

- (void)initializeTableContent {
    NSString *sqlStr= [NSString stringWithFormat:@"select * from SongTable where singer='%@' order by singer",_singerName];
    FMResultSet *rs=[[DataManager instanceShare].db executeQuery:sqlStr];
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
        NSLog(@"%@",oneSong.songname);
        [dataList addObject:oneSong];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)setTableViewBackGroundImage:(UIImage*)image {
    UIImageView *bgImageView=[[UIImageView alloc]initWithImage:image];
    self.tableView.backgroundView=bgImageView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    newSongListTopCell *cell=(newSongListTopCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:[newSongListTopCell class]]) return;
    if (_previousRow >= 0) {
        NSIndexPath *preIndexPath=[NSIndexPath indexPathForRow:_previousRow inSection:0];
        newSongListTopCell *preCell=(newSongListTopCell*)[tableView cellForRowAtIndexPath:preIndexPath];
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"insert is %ld=%ld:",_previousRow+1,indexPath.row);
    if (_previousRow >= 0 && _previousRow+1==indexPath.row) {
        SongBottomCell *cell=[tableView dequeueReusableCellWithIdentifier:BOTTOMCELLIDENTIFY];
        if (!cell) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:BOTTOMCELLIDENTIFY owner:self options:nil];
            cell = [nib objectAtIndex:0];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"song_bt_bg"]];
            cell.oneSong=dataList[_previousRow];
            cell.oneSong.delegate=self;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        return cell;
    } else {
        newSongListTopCell *cell = [tableView dequeueReusableCellWithIdentifier:TOPCELLIDENTIFY forIndexPath:indexPath];
//        newSongListTopCell *cell= [[[NSBundle mainBundle] loadNibNamed:@"newSongListTopCell" owner:nil options:nil] firstObject];
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

        return cell;
        
    }
    return nil;
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
            newSongListTopCell *cell=(newSongListTopCell*)[self.tableView cellForRowAtIndexPath:indexPath];
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
            newSongListTopCell *cell=(newSongListTopCell*)[self.tableView cellForRowAtIndexPath:indexPath];
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
    newSongListTopCell *cell=(newSongListTopCell*)[self.tableView cellForRowAtIndexPath:indexPath];
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
    //update yidian badge
    [self performSelector:@selector(updateYidanBadge) withObject:nil afterDelay:0.5];
}

- (void)cutSongFromCollection:(Song *)oneSong result:(KMessageStyle)result {
    if(_previousRow<=-1) return;
    NSIndexPath *indexPath=[NSIndexPath indexPathForItem:_previousRow inSection:0];
    newSongListTopCell *cell=(newSongListTopCell*)[self.tableView cellForRowAtIndexPath:indexPath];
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
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
//    if (searchSong) {
//        return NO;
//    }
//    return YES;
    return NO;
}

#pragma mark -#########################################################

@end
