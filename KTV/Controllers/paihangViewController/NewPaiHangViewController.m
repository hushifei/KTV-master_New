//
//  NewPaiHangViewController.m
//  KTV
//
//  Created by admin on 15/10/19.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import "NewPaiHangViewController.h"
#import "Song.h"
#import "DataMananager.h"
#import "BBBadgeBarButtonItem.h"
#import "CommandControler.h"
#import "Utility.h"
#import "AppDelegate.h"
#define SESSIONHEIGHT 46.0f
@interface NewPaiHangViewController ()<SongDelegate> {
    NSInteger ClickButtonCount;
}
@end

@implementation NewPaiHangViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=NSLocalizedString(@"hotest", nil);
    ClickButtonCount=-1;
    [self initTableView];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout=UIRectEdgeNone;
}

- (void)initTableView {
//    self.tableView=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    float y=[UIApplication sharedApplication].statusBarFrame.size.height+self.navigationController.navigationBar.bounds.size.height;
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,y, self.view.bounds.size.width, self.view.bounds.size.height-y) style:UITableViewStyleGrouped];
    self.tableView.showsHorizontalScrollIndicator=NO;
    self.tableView.showsVerticalScrollIndicator=NO;
     self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    UIImageView *bgImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"geshou_area_bg"]];
     self.tableView.backgroundView=bgImageView;
     self.tableView.sectionFooterHeight = 0;
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
         [self initializeTableContent];
     });
}

- (void)initializeTableContent {
    NSString *song_sqlStr= [NSString stringWithFormat:@"select * from SongTable,OrderTable where SongTable.number=OrderTable.number"];
    FMResultSet *song_rs=[[DataMananager instanceShare].db executeQuery:song_sqlStr];
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


#pragma mark--UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"idntifier";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"song_bt_bg"]];
        CGSize cellSize=cell.bounds.size;
        UIButton *collectionBtn=[[UIButton alloc]initWithFrame:CGRectMake((cellSize.width/2-80)/2,0, 80, cellSize.height)];
        [collectionBtn setImage:[UIImage imageNamed:@"collection_bt"] forState:UIControlStateNormal];
        [collectionBtn setTitle:NSLocalizedString(@"collect", nil) forState:UIControlStateNormal];
        [collectionBtn setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];
        collectionBtn.titleLabel.font=[UIFont systemFontOfSize:12];

        UIButton *priorityBtn=[[UIButton alloc]initWithFrame:CGRectMake((cellSize.width/2-80)/2+cellSize.width/2,0, 80, cellSize.height)];
        [priorityBtn setImage:[UIImage imageNamed:@"priority_bt"] forState:UIControlStateNormal];
        [priorityBtn setTitle:NSLocalizedString(@"top", nil) forState:UIControlStateNormal];
        priorityBtn.titleLabel.font=[UIFont systemFontOfSize:12];
        [priorityBtn setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];

        [collectionBtn addTarget:self action:@selector(collection_clicked:) forControlEvents:UIControlEventTouchUpInside];
        [priorityBtn addTarget:self action:@selector(priority_clicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        [cell addSubview:collectionBtn];
        [cell addSubview:priorityBtn];

    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    Song *oneSong=dataList[section];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    CGFloat btnWidth=self.view.bounds.size.width;
    button.frame = CGRectMake(0, 0, btnWidth,SESSIONHEIGHT-1);
    [button addTarget:self action:@selector(showChild:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = 200 + section;
    
    UIImageView *hotestImageView=[[UIImageView alloc]initWithFrame:CGRectMake(10,(SESSIONHEIGHT-1-30)/2, 30, 30)];
    hotestImageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"paihang_flag%d",(int)(section+7)%7]];
    [button addSubview:hotestImageView];
    
    UILabel *numberlabel=[[UILabel alloc] initWithFrame:hotestImageView.bounds];
    numberlabel.text =[NSString stringWithFormat:@"%02d",(int)section+1];
    numberlabel.font=[UIFont fontWithName:@"DIN Condensed" size:18];
    numberlabel.textColor = [UIColor whiteColor];
    [numberlabel setFont:[UIFont systemFontOfSize:14]];
    numberlabel.textAlignment = NSTextAlignmentCenter;
    [hotestImageView addSubview:numberlabel];

    
    UILabel *songlabel=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(numberlabel.frame)+40,5,button.bounds.size.width-CGRectGetMaxX(numberlabel.frame)-20, 20)];
    songlabel.text =oneSong.songname;
    songlabel.textColor = [UIColor groupTableViewBackgroundColor];
    [songlabel setFont:[UIFont systemFontOfSize:14]];
    [songlabel sizeToFit];
    songlabel.textAlignment = NSTextAlignmentCenter;
    [button addSubview:songlabel];
    
    
    UILabel *singerlabel=[[UILabel alloc] initWithFrame:CGRectMake(songlabel.frame.origin.x+30,CGRectGetMaxY(songlabel.frame)+5,100, 20)];
    singerlabel.text =oneSong.singer;
    [singerlabel setFont:[UIFont italicSystemFontOfSize:13]];
    singerlabel.textColor = [UIColor grayColor];
    singerlabel.textAlignment = NSTextAlignmentCenter;
    [button addSubview:singerlabel];
    
    
    UILabel *labelLine = [[UILabel alloc] initWithFrame:CGRectMake(0, SESSIONHEIGHT-1, btnWidth, 1)];
    labelLine.backgroundColor = [UIColor colorWithRed:0.50196081399917603 green:0.0 blue:0.25098040699958801 alpha:1.0f];
    [button addSubview:labelLine];
    
    UIButton *selectedBtn=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-60, (SESSIONHEIGHT-22)/2, 50, 22)];
    [selectedBtn setBackgroundImage:[UIImage imageNamed:@"diange_icon"] forState:UIControlStateNormal];
//    [selectedBtn setImage:[UIImage imageNamed:@"diange_icon"] forState:UIControlStateNormal];
    [selectedBtn setTitle:NSLocalizedString(@"select", nil) forState:UIControlStateNormal];
    selectedBtn.titleLabel.font=[UIFont systemFontOfSize:12];
    selectedBtn.tag=section;
    [selectedBtn addTarget:self action:@selector(addSongToHost:) forControlEvents:UIControlEventTouchUpInside];
    [button addSubview:selectedBtn];

    UIImageView *iamgeView=[[UIImageView alloc]init];
    iamgeView.frame=CGRectMake(numberlabel.center.x, SESSIONHEIGHT-8, 16, 8);
    if (section == ClickButtonCount) {
        UIImage *image=[UIImage imageNamed:@"brt"];
        iamgeView.image=image;
        iamgeView.hidden=NO;
        labelLine.hidden=YES;
    } else {
        iamgeView.hidden=YES;
        labelLine.hidden=NO;
    }
    [button addSubview:iamgeView];
    
    return button;
}


#pragma mark - UITabelViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SESSIONHEIGHT;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == ClickButtonCount) {
        return 1;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SESSIONHEIGHT;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section  {
    return 0.0f;
}

-(void)showChild:(UIButton *)sender
{
    if (ClickButtonCount + 200 == sender.tag) {
        ClickButtonCount = -1;
    } else {
        ClickButtonCount = sender.tag - 200;
    }
    [self.tableView reloadData];
}


- (void)collection_clicked:(id)sender {
    if (ClickButtonCount > -1) {
        Song *oneSong=dataList[ClickButtonCount];
        __weak typeof(self) weakSelf=self;
        oneSong.delegate=weakSelf;
        [oneSong insertSongToCollectionTable:^(BOOL complete) {
            
        }];
    }
}

- (void)priority_clicked:(id)sender {
    if (ClickButtonCount > -1) {
        Song *oneSong=dataList[ClickButtonCount];
        __weak typeof(self) weakSelf=self;
        oneSong.delegate=weakSelf;
        [oneSong diangeToTop:^(BOOL complete) {
            
        }];
    }
}

- (void)addSongToHost:(id)sender {
    if ([Utility instanceShare].netWorkStatus) {
        UIButton *currentBtn=(UIButton*)sender;
        Song *oneSong=dataList[currentBtn.tag];
        __weak typeof(self) weakSelf=self;
        oneSong.delegate=weakSelf;
        if (oneSong.number.length > 0) {
            CommandControler *cmd=[[CommandControler alloc]init];
            [cmd sendCmd_Diange:oneSong.number completed:^(BOOL completed, NSError *error) {
                if (completed) {
                    //                    [self.numberStr shakeAndFlyAnimationToView:self.buttonitem];
                }
            }];
        }
    } else {
        [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
    }
}

#pragma mark - SongBottom delegate
- (void)addSongToCollection:(Song *)oneSong result:(KMessageStyle)result {
    ClickButtonCount=-1;
    [self.tableView reloadData];
    switch (result) {
        case KMessageSuccess: {
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
    ClickButtonCount=-1;
    [self.tableView reloadData];
    [HuToast showToastWithMessage:@"顶歌成功" WithTimeDismiss:nil messageType:KMessageSuccess];
    [self performSelector:@selector(updateYidanBadge) withObject:self afterDelay:0.5];
}


- (void)updateYidanBadge {
    BBBadgeBarButtonItem *barButton = (BBBadgeBarButtonItem *)self.navigationItem.rightBarButtonItem;
    __weak __typeof(BBBadgeBarButtonItem*)weakBarButton=barButton;
    [CommandControler setYidianBadgeWidth:weakBarButton completed:^(BOOL completed, NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
