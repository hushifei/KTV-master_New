//
//  SingerViewController.m
//  KTV
//
//  Created by stevenhu on 15/4/19.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//
#import "SingerAreaViewController.h"
#import "SingsTableViewCell.h"
#define CELLIDENTIFY @"SingsTableViewCell"
#import "Typelist.h"
#import "SingersViewController.h"
#import "newSongViewController.h"
#import "YiDianViewController.h"
#import "BBBadgeBarButtonItem.h"
#import "BokongView.h"
#import "SettingViewController.h"
#import "SoundViewController.h"
#import "MBProgressHUD.h"
#import "NSString+Utility.h"
#import "DataManager.h"
#import "CommandControler.h"
@interface SingerAreaViewController ()<UITableViewDataSource,UITableViewDelegate> {
}

@end

@implementation SingerAreaViewController
    - (void)viewDidLoad {
    [super viewDidLoad];
        self.title=NSLocalizedString(@"singers_area", nil);
    UINib *nib=[UINib nibWithNibName:@"SingsTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CELLIDENTIFY];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
        self.tableView.separatorColor=[UIColor colorWithRed:100 green:27 blue:55 alpha:1];
    UIImageView *bgImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"songsList_bg"]];
    self.tableView.backgroundView=bgImageView;
    self.tableView.rowHeight=80.0f;
    [self initializeTableContent];

}

- (void)initializeTableContent {
    NSString *sqlStr= @"select * from TypeTable where typeid='4'";
    FMResultSet *rs=[[DataManager instanceShare].db executeQuery:sqlStr];
    while ([rs next]) {
        Typelist *oneType=[[Typelist alloc]init];
        oneType.ztype = [rs stringForColumn:@"type"];
        oneType.ztypeid = [rs stringForColumn:@"typeid"];
        oneType.ztypename = [rs stringForColumn:@"typename"];
//        NSLog(@"oneSong:%@,%@,%@",oneType.ztype,oneType.ztypeid,oneType.ztypename);
        if ([oneType.ztypename isEqualToString:@"全部"]) continue;
        [dataList addObject:oneType];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  dataList.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLIDENTIFY forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Typelist *onetype=dataList[indexPath.row];
    cell.SingerLabel.text=onetype.ztypename;
//    [cell.headImageV setImage:[UIImage imageNamed:@"kge_head"]];
    cell.SingerLabel.textColor=[UIColor groupTableViewBackgroundColor];
    cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"geshou_area_cell_bg"]];
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        SingersViewController *vc=[[SingersViewController alloc]init];
        Typelist *onetype=dataList[indexPath.row];
        vc.area=onetype.ztype;
        [self.navigationController pushViewController:vc animated:YES];
}
@end
