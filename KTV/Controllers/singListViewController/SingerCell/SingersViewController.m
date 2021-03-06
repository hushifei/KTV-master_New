//
//  SingsViewController.m
//  KTV
//
//  Created by stevenhu on 15/4/21.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import "SingersViewController.h"
#import "SingerAreaTypeCell.h"
#import "SongListViewController.h"
#import "Singer.h"
#define CELLIDENTIFY @"SingerAreaTypeCell"
#import "YiDianViewController.h"
#import "BBBadgeBarButtonItem.h"
#import "BokongView.h"
#import "SettingViewController.h"
#import "SoundViewController.h"
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "NSString+Utility.h"
#import "DataManager.h"
#import "CommandControler.h"
#import "UIImageView+WebCache.h"

#define SINGER_PIC_URL @"http://192.168.43.1:8080/puze?cmd=0x02&filename="

@interface SingersViewController ()
@property(nonatomic,strong)NSArray *indexArray;
@end

@implementation SingersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=NSLocalizedString(@"singers", nil);
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    UINib *nib=[UINib nibWithNibName:@"SingerAreaTypeCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CELLIDENTIFY];
    UIImageView *bgImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"songsList_bg"]];
   totalRowCount= [[DataManager instanceShare]rowCountWithStatment:[NSString stringWithFormat:@"select count(*) from SingerTable where area='%@'",_area]];
    [self loadMJRefreshingView];
    
    self.tableView.backgroundView=bgImageView;
    MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.labelText=@"快速加载...";
    [hud showAnimated:YES whileExecutingBlock:^{
        [self initializeTableContent];
    } completionBlock:^{
        [hud removeFromSuperview];
    }];
}

- (void)initializeTableContent {
    //DESC 降序
    NSString *sqlStr= [NSString stringWithFormat:@"select * from SingerTable where area='%@' order by singer limit %d OFFSET %@",_area,pageLimint,offset];
    FMResultSet *rs=[[DataManager instanceShare].db executeQuery:sqlStr];
    while ([rs next]) {
        Singer *oneSinger=[[Singer alloc]init];
        oneSinger.area = [rs stringForColumn:@"area"];
        oneSinger.pingyin = [rs stringForColumn:@"pingyin"];
        oneSinger.s_bi_hua = [rs stringForColumn:@"s_bi_hua"];
        oneSinger.singer = [rs stringForColumn:@"singer"];
//        NSLog(@"%@",oneSinger.singer);
        [dataList addObject:oneSinger];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)loadMoreData {
    // 1.添加数据,拿到当前的上拉刷新控件，结束刷新状态
    if (dataList.count < totalRowCount) {
        offset=[NSNumber numberWithUnsignedInteger:dataList.count];
        [self initializeTableContent];
        [self.tableView.footer endRefreshing];
    } else {
        [self.tableView.footer endRefreshingWithNoMoreData];
    }
}

- (void)viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
    BBBadgeBarButtonItem *barButton = (BBBadgeBarButtonItem *)self.navigationItem.rightBarButtonItem;
    __weak __typeof(BBBadgeBarButtonItem*)weakBarButton=barButton;
    [CommandControler setYidianBadgeWidth:weakBarButton completed:^(BOOL completed, NSError *error) {
        
    }];}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SingerAreaTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLIDENTIFY forIndexPath:indexPath];
    Singer *oneSinger=dataList[indexPath.row];
    cell.SingerLabel.text=oneSinger.singer;
    cell.SingerLabel.textColor=[UIColor groupTableViewBackgroundColor];
    cell.SingerLabel.font=[UIFont systemFontOfSize:14];
    cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"geshou_area_cell_bg"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *urlStr=[[SINGER_PIC_URL stringByAppendingString:oneSinger.singer]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [cell.headImageV sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"Default_Header"]];
//   UIImage *a= [UIImage imageNamed:@"DefaultHeader.jpg"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SongListViewController *vc=[[SongListViewController alloc]init];
    Singer *oneSinger=dataList[indexPath.row];
    vc.singerName=oneSinger.singer;
    vc.needLoadData=YES;
   [self.navigationController pushViewController:vc animated:YES];
}
@end
