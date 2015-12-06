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
#import "Utility.h"
#import "AppDelegate.h"
#import "DataManager.h"
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
    [self initNavigationItem];
    [self initializeTableContent];
    UINib *nib=[UINib nibWithNibName:TOPCELLIDENTIFY bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:TOPCELLIDENTIFY];
    [self.tableView registerClass:[YiDianBottomCell class] forCellReuseIdentifier:BOTTOMCELLIDENTIFY];
    UIView *backView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.tableView.tableFooterView=backView;
    self.tableView.showsHorizontalScrollIndicator=NO;
    self.tableView.showsVerticalScrollIndicator=NO;
    UIImageView *bgImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"songsList_bg"]];
    self.tableView.backgroundView=bgImageView;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight=60.0f;
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
                NSString *sqlStr= [NSString stringWithFormat:@"select * from SongTable where number='%@'",number];
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
    YiDianTopViewCell *cell=(YiDianTopViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:[YiDianTopViewCell class]]) return;
    if (_previousRow >= 0) {
        NSIndexPath *preIndexPath=[NSIndexPath indexPathForRow:_previousRow inSection:0];
        YiDianTopViewCell *preCell=(YiDianTopViewCell*)[tableView cellForRowAtIndexPath:preIndexPath];
        if (indexPath.row == _previousRow) {
            cell.sanjiaoxing.hidden=!(cell.opened=!cell.opened);
            [_dataSrc removeObjectAtIndex:indexPath.row +1];
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row +1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            _previousRow = -1;
        }  else if (indexPath.row < _previousRow) {
            cell.sanjiaoxing.hidden=!(cell.opened=!cell.opened);
            preCell.sanjiaoxing.hidden=!(preCell.opened=!preCell.opened);
            [_dataSrc removeObjectAtIndex:_previousRow+1];
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            _previousRow = indexPath.row;
            [_dataSrc insertObject:@"增加的" atIndex:indexPath.row+1];
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        } else {
            cell.sanjiaoxing.hidden=!(cell.opened=!cell.opened);
            preCell.sanjiaoxing.hidden=!(preCell.opened=!preCell.opened);
            NSInteger oler=_previousRow;
            _previousRow = indexPath.row;
            [_dataSrc insertObject:@"增加的" atIndex:indexPath.row+1];
            [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
            [_dataSrc removeObjectAtIndex:oler+1];
            _previousRow -=1;
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oler+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    } else {
        cell.sanjiaoxing.hidden=!(cell.opened=!cell.opened);
        _previousRow = indexPath.row;
        [_dataSrc insertObject:@"增加的" atIndex:_previousRow+1];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_previousRow+1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_previousRow >= 0 && _previousRow+1==indexPath.row) {
        YiDianBottomCell *cell=[tableView dequeueReusableCellWithIdentifier:BOTTOMCELLIDENTIFY];
        cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"song_bt_bg"]];
        cell.orderID=[[_yidianArray[_previousRow]allKeys]firstObject];
        cell.delegate=self;
        cell.oneSong=_dataSrc[_previousRow];
        cell.oneSong.delegate=self;
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
    if(_previousRow<=-1) return;
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
    if(_previousRow<=-1) return;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [HuToast showToastWithMessage:@"顶歌成功" WithTimeDismiss:nil messageType:KMessageSuccess];
    });
//    [self initializeTableContent];
    //update yidian badge
    [self performSelector:@selector(initializeTableContent) withObject:nil afterDelay:1];
}

- (void)cutSongFromCollection:(Song *)oneSong result:(KMessageStyle)result {
    if(_previousRow<=-1) return;
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
    [HuToast showToastWithMessage:@"切歌成功" WithTimeDismiss:nil messageType:KMessageSuccess];
}

- (void)cutSongWithResult:(KMessageStyle)result {

    dispatch_async(dispatch_get_main_queue(), ^{
        switch (result) {
            case KMessageSuccess:
                [HuToast showToastWithMessage:@"切歌成功"  WithTimeDismiss:nil messageType:KMessageSuccess];
                [_dataSrc removeAllObjects];
                [_yidianArray removeAllObjects];
                [self.tableView reloadData];
                [self initializeTableContent];
                break;
            case KMessageStyleError:
                [HuToast showToastWithMessage:@"切歌失败"  WithTimeDismiss:nil messageType:KMessageStyleError];
                
            default:
                break;
        }
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
//    [_dataSrc removeObjectAtIndex:_previousRow+1];
    [_dataSrc removeAllObjects];
    [self.tableView reloadData];
//    [self initializeTableContent];
    [self performSelector:@selector(initializeTableContent) withObject:nil afterDelay:1];
}

#pragma mark -#########################################################
//-(UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}
//
//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}

@end
