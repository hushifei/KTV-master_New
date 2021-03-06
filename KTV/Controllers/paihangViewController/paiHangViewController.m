//
//  paiHangViewController.m
//  KTV
//
//  Created by stevenhu on 15/4/25.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import "paiHangViewController.h"
//#import "newSongListTopCell.h"
#import "newSongListTopCell.h"
#import "paiHangBottomCell.h"
#define CELLIDENTIFY @"newSongListTopCell"
#define BOTTOMCELLIDENTIFY @"paiHangBottomCell"
#import "YiDianViewController.h"
#import "BBBadgeBarButtonItem.h"
#import "Utility.h"
#import "SoundViewController.h"
#import "MBProgressHUD.h"
#import "Order.h"
#import "Song.h"
#import "NSString+Utility.h"
#import "DataManager.h"
#import "CommandControler.h"
@interface paiHangViewController ()<SongDelegate>
{
    NSInteger _previousRow;
    NSMutableArray *numbers;
}

@end

@implementation paiHangViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=NSLocalizedString(@"hotest", nil);
    _previousRow = -1;
    [self.tableView registerClass:[newSongListTopCell class] forCellReuseIdentifier:CELLIDENTIFY];

//    UINib *nib=[UINib nibWithNibName:CELLIDENTIFY bundle:nil];
//    [self.tableView registerNib:nib forCellReuseIdentifier:CELLIDENTIFY];
    UIView *backView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.tableView.tableFooterView=backView;
    self.tableView.showsHorizontalScrollIndicator=NO;
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    UIImageView *bgImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"geshou_area_bg"]];
    self.tableView.backgroundView=bgImageView;
    self.tableView.rowHeight=50;
    [self initializeTableContent];

}

- (void)initializeTableContent {
        NSString *song_sqlStr= [NSString stringWithFormat:@"select * from SongTable,OrderTable where SongTable.number=OrderTable.number"];
        FMResultSet *song_rs=[[DataManager instanceShare].db executeQuery:song_sqlStr];
        while ([song_rs next]) {
            Song *oneSong=[[Song alloc]init];
            oneSong.addtime = [song_rs stringForColumn:@"addtime"];
            oneSong.bihua = [song_rs stringForColumn:@"bihua"];
            oneSong.channel = [song_rs stringForColumn:@"channel"];
            oneSong.language = [song_rs stringForColumn:@"language"];
            oneSong.movie = [song_rs stringForColumn:@"movie"];
            oneSong.newsong = [song_rs stringForColumn:@"newsong"];
            oneSong.number = [song_rs stringForColumn:@"number"];
            oneSong.pathid = [song_rs stringForColumn:@"pathid"];
            oneSong.sex = [song_rs stringForColumn:@"sex"];
            oneSong.singer = [song_rs stringForColumn:@"singer"];
            oneSong.singer1 = [song_rs stringForColumn:@"singer1"];
            oneSong.songname = [song_rs stringForColumn:@"songname"];
            oneSong.songpiy = [song_rs stringForColumn:@"songpiy"];
            oneSong.spath = [song_rs stringForColumn:@"spath"];
            oneSong.stype = [song_rs stringForColumn:@"stype"];
            oneSong.volume = [song_rs stringForColumn:@"volume"];
            oneSong.word = [song_rs stringForColumn:@"word"];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"insert is %ld=%ld:",_previousRow+1,indexPath.row);
    if (_previousRow >= 0 && _previousRow+1==indexPath.row) {
        paiHangBottomCell *cell=(paiHangBottomCell*)[tableView dequeueReusableCellWithIdentifier:BOTTOMCELLIDENTIFY];
        if (!cell) {
            cell = [[paiHangBottomCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BOTTOMCELLIDENTIFY];
            cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"song_bt_bg"]];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        cell.oneSong=dataList[_previousRow];
        cell.oneSong.delegate=self;

        return cell;
    } else {
        newSongListTopCell *cell = (newSongListTopCell*)[tableView dequeueReusableCellWithIdentifier:CELLIDENTIFY forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.numberStr.text =[NSString stringWithFormat:@"%02d",(int)indexPath.row+1];
        cell.buttonitem=self.navigationItem.rightBarButtonItem;
        cell.backgroundColor=[UIColor clearColor];
        cell.oneSong=dataList[indexPath.row];
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
    newSongListTopCell *cell=(newSongListTopCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:[newSongListTopCell class]])  {
        return;
    };
    cell.opened=!cell.opened;
    if (cell.opened) {
        cell.sanjiaoxing.hidden=NO;
    } else {
        cell.sanjiaoxing.hidden=YES;
    }
    if (_previousRow >= 0) {
        NSIndexPath *preIndexPath=[NSIndexPath indexPathForRow:_previousRow inSection:0];
        newSongListTopCell *preCell=(newSongListTopCell*)[tableView cellForRowAtIndexPath:preIndexPath];
        if (indexPath.row == _previousRow + 1) {
//            NSLog(@"fff");
        }
        else if (indexPath.row == _previousRow) {
            [dataList removeObjectAtIndex:_previousRow+1];
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            _previousRow = -1;
        }
        else if (indexPath.row < _previousRow) {
            preCell.opened=!preCell.opened;
            if (preCell.opened) {
                preCell.sanjiaoxing.hidden=NO;
            } else {
                preCell.sanjiaoxing.hidden=YES;
            }
            [dataList removeObjectAtIndex:_previousRow+1];
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            _previousRow = indexPath.row;
            [dataList insertObject:@"增加的" atIndex:indexPath.row+1];
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        }
        else {
            preCell.opened=!preCell.opened;
            if (preCell.opened) {
                preCell.sanjiaoxing.hidden=NO;
            } else {
                preCell.sanjiaoxing.hidden=YES;
            }
            NSInteger oler=_previousRow;
            _previousRow = indexPath.row;
            [dataList insertObject:@"增加的" atIndex:indexPath.row+1];
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [dataList removeObjectAtIndex:oler+1];
            _previousRow -=1;
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oler+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    } else {
        _previousRow = indexPath.row;
        [dataList insertObject:@"增加的" atIndex:_previousRow+1];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    }
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
                [HuToast showToastWithMessage:NSLocalizedString(@"collectionsuccess", nil)  WithTimeDismiss:nil messageType:KMessageSuccess];
                break;
            }
            case KMessageStyleError: {
                [HuToast showToastWithMessage:NSLocalizedString(@"collectionerror", nil)  WithTimeDismiss:nil messageType:KMessageStyleError];
                
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
                [HuToast showToastWithMessage:NSLocalizedString(@"collectioninfo", nil)  WithTimeDismiss:nil messageType:KMessageStyleInfo];
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
        [self performSelector:@selector(updateYidanBadge) withObject:self afterDelay:0.5];
}

- (void)updateYidanBadge {
    BBBadgeBarButtonItem *barButton = (BBBadgeBarButtonItem *)self.navigationItem.rightBarButtonItem;
    __weak __typeof(BBBadgeBarButtonItem*)weakBarButton=barButton;
    [CommandControler setYidianBadgeWidth:weakBarButton completed:^(BOOL completed, NSError *error) {
        
    }];
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
    [self performSelector:@selector(updateYidanBadge) withObject:self afterDelay:0.5];
}
@end
