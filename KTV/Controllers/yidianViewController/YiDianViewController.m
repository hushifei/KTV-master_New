//
//  YiDianViewController.m
//  KTV
//
//  Created by stevenhu on 15/4/26.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import "YiDianViewController.h"
#define TOPCELLIDENTIFY @"YiDianTopViewCell"
#import "YiDianTopViewCell.h"
#import "YiDianBottomCell.h"
#define BOTTOMCELLIDENTIFY @"YiDianBottomCell"
#import "CommandControler.h"
#import "NSString+Utility.h"
#import "DataMananager.h"
#import "Utility.h"
#import "AppDelegate.h"
@interface YiDianViewController ()<SongDelegate,yiDianDelegate>
{
    NSInteger _previousRow;
    HuToast *myToast;
    CommandControler *cmd;
}
@property (nonatomic, strong) NSMutableArray *dataSrc;
@property (nonatomic,strong) NSMutableArray *yidianArray;

@end

@implementation YiDianViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=NSLocalizedString(@"selected", nil);
    _previousRow = -1;
    myToast=[[HuToast alloc]init];
    cmd=[[CommandControler alloc]init];
    [self initializeTableContent];
    UINib *nib=[UINib nibWithNibName:TOPCELLIDENTIFY bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:TOPCELLIDENTIFY];
    UIView *backView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.tableView.tableFooterView=backView;
    self.tableView.showsHorizontalScrollIndicator=NO;
    self.tableView.showsVerticalScrollIndicator=NO;
    UIImageView *bgImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"songsList_bg"]];
    self.tableView.backgroundView=bgImageView;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight=UITableViewAutomaticDimension;
}

- (void)initNavigationItem {
    //navigation item
    UIButton *rightbtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    rightbtn.titleLabel.font=[UIFont systemFontOfSize:10];
    [rightbtn setTitle:@"切歌" forState:UIControlStateNormal];
    [rightbtn setImage:[UIImage imageNamed:@"cutsong_bt"] forState:UIControlStateNormal];
    [rightbtn addTarget:self action:@selector(clicked_nextSong:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:rightbtn];
}

- (void)clicked_nextSong:(id)sender {
    if ([Utility instanceShare].netWorkStatus) {
        __weak typeof(self) weakSelf=self;
        [cmd sendCmd_switchSong:^(BOOL completed, NSError *error) {
            if (completed) {
                [weakSelf cutSongWithResult:KMessageSuccess];
            } else {
                [weakSelf cutSongWithResult:KMessageStyleError];
            }
        }];
    } else {
        [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
    }
}

- (void)initializeTableContent {
    [self initNavigationItem];
    _previousRow = -1;
    _dataSrc=[[NSMutableArray alloc]init];
    _yidianArray=[[NSMutableArray alloc]init];
    [cmd sendCmd_get_yiDianList:^(BOOL completed, NSArray *list) {
        if (!completed || list.count==0) return;
        for (NSString *oneYidianStr in list) {
            NSArray *oneYidianInfo=[oneYidianStr componentsSeparatedByString:@";"];
            if (oneYidianInfo.count==2) {
                NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:oneYidianInfo[1],oneYidianInfo[0], nil];
                [_yidianArray addObject:dict];
            }
        }
        
        for (NSDictionary *dict in _yidianArray) {
            for (NSString *number in dict.allValues) {
                // in
                NSString *sqlStr= [NSString stringWithFormat:@"select * from SongTable where number='%@'",[number encodeBase64]];
                FMResultSet *rs=[[DataMananager instanceShare].db executeQuery:sqlStr];
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
                    [_dataSrc addObject:oneSong];
                }
            }
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.dataSrc.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) return;
    YiDianTopViewCell *cell=(YiDianTopViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.opened=!cell.opened;
    if (cell.opened) {
        cell.sanjiaoxing.hidden=NO;
    } else {
        cell.sanjiaoxing.hidden=YES;
    }
    if (_previousRow >= 0) {
        NSIndexPath *preIndexPath=[NSIndexPath indexPathForRow:_previousRow inSection:0];
        YiDianTopViewCell *preCell=(YiDianTopViewCell*)[tableView cellForRowAtIndexPath:preIndexPath];
        
        if (indexPath.row == _previousRow + 1) {
        }
        else if (indexPath.row == _previousRow) {
            
            [self.dataSrc removeObjectAtIndex:_previousRow+1];
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
            
            [self.dataSrc removeObjectAtIndex:_previousRow+1];
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            _previousRow = indexPath.row;
            [self.dataSrc insertObject:@"增加的" atIndex:indexPath.row+1];
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
            [self.dataSrc insertObject:@"增加的" atIndex:indexPath.row+1];
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [self.dataSrc removeObjectAtIndex:oler+1];
            _previousRow -=1;
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oler+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    } else {
        _previousRow = indexPath.row;
        [self.dataSrc insertObject:@"增加的" atIndex:_previousRow+1];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_previousRow >= 0 && _previousRow+1==indexPath.row) {
        YiDianBottomCell *cell=[tableView dequeueReusableCellWithIdentifier:BOTTOMCELLIDENTIFY];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:BOTTOMCELLIDENTIFY owner:nil options:nil]firstObject];
            cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"song_bt_bg"]];
        }
        cell.orderID=[[_yidianArray[_previousRow]allKeys]firstObject];
        cell.delegate=self;
        cell.oneSong.delegate=self;
        cell.oneSong=_dataSrc[_previousRow];
        
        return cell;
    } else {
        YiDianTopViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TOPCELLIDENTIFY forIndexPath:indexPath];
        cell.oneSong=self.dataSrc[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row==0) {
            [cell setPlayStatusToHide:NO];
        } else {
            [cell setPlayStatusToHide:YES];
        }
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
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

#pragma mark - SongBottom delegate
- (void)addSongToCollection:(Song *)oneSong result:(KMessageStyle)result {
    //    [myToast dissmiss];
    switch (result) {
        case KMessageSuccess: {
            NSIndexPath *indexPath=[NSIndexPath indexPathForItem:_previousRow inSection:0];
            YiDianTopViewCell *cell=(YiDianTopViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.opened=!cell.opened;
            if (cell.opened) {
                cell.sanjiaoxing.hidden=NO;
            } else {
                cell.sanjiaoxing.hidden=YES;
            }
            [_dataSrc removeObjectAtIndex:_previousRow+1];
            [self.tableView  deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            _previousRow=-1;
            //            [myToast setToastWithMessage:@"成功收藏"  WithTimeDismiss:nil messageType:KMessageSuccess];
            break;
        }
        case KMessageStyleError: {
            //            [myToast setToastWithMessage:@"收藏出错了,请重发"  WithTimeDismiss:nil messageType:KMessageStyleError];
            
            break;
        }
        case KMessageWarning: {
            //            [myToast setToastWithMessage:@"查询收藏出错了,请重发"  WithTimeDismiss:nil messageType:KMessageStyleError];
            
            break;
        }
        case KMessageStyleInfo: {
            NSIndexPath *indexPath=[NSIndexPath indexPathForItem:_previousRow inSection:0];
            YiDianTopViewCell *cell=(YiDianTopViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.opened=!cell.opened;
            if (cell.opened) {
                cell.sanjiaoxing.hidden=NO;
            } else {
                cell.sanjiaoxing.hidden=YES;
            }
            [_dataSrc removeObjectAtIndex:_previousRow+1];
            [self.tableView  deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            _previousRow=-1;
            //            [myToast setToastWithMessage:@"此歌已收藏"  WithTimeDismiss:nil messageType:KMessageStyleInfo];
            
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
    //    [myToast dissmiss];
    NSIndexPath *indexPath=[NSIndexPath indexPathForItem:_previousRow inSection:0];
    YiDianTopViewCell *cell=(YiDianTopViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.opened=!cell.opened;
    if (cell.opened) {
        cell.sanjiaoxing.hidden=NO;
    } else {
        cell.sanjiaoxing.hidden=YES;
    }
    [_dataSrc removeAllObjects];
    [_yidianArray removeAllObjects];
    //    [self.tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initializeTableContent];
        //        [myToast setToastWithMessage:@"顶歌成功" WithTimeDismiss:nil messageType:KMessageSuccess];
        
    });
    //    [_dataSrc removeObjectAtIndex:_previousRow+1];
    //    [self.tableView  deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    //    _previousRow=-1;
    //TODO::
}

- (void)cutSongWithResult:(KMessageStyle)result {

    dispatch_async(dispatch_get_main_queue(), ^{
        switch (result) {
            case KMessageSuccess:
                [HuToast showToastWithMessage:@"切歌收藏"  WithTimeDismiss:nil messageType:KMessageSuccess];
                break;
            case KMessageStyleError:
                [HuToast showToastWithMessage:@"切歌失败"  WithTimeDismiss:nil messageType:KMessageStyleError];
                
            default:
                break;
        }
        [self initializeTableContent];
    });
}

- (void)removeFromYidian:(Song *)oneSong result:(KMessageStyle)result {
    NSIndexPath *indexPath=[NSIndexPath indexPathForItem:_previousRow inSection:0];
    YiDianTopViewCell *cell=(YiDianTopViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.opened=!cell.opened;
    if (cell.opened) {
        cell.sanjiaoxing.hidden=NO;
    } else {
        cell.sanjiaoxing.hidden=YES;
    }
    [_dataSrc removeObjectAtIndex:_previousRow+1];
    //    [self performSelector:@selector(initializeTableContent) withObject:nil afterDelay:1];
    [self initializeTableContent];
}

#pragma mark -#########################################################
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
