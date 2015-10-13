//
//  BaseTableViewController.m
//  KTV
//
//  Created by stevenhu on 15/10/11.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import "BaseTableViewController.h"
#import "YiDianButton.h"  
#import "YiDianViewController.h"
#import "BBBadgeBarButtonItem.h"
@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    offset=[NSNumber numberWithUnsignedInteger:0];
    pageLimint=PAGELIMINT;
    UIView *backView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.tableView.tableFooterView=backView;
    self.tableView.showsHorizontalScrollIndicator=NO;
    self.tableView.showsVerticalScrollIndicator=NO;
    dataList=[[NSMutableArray alloc]init];
    [self initNavigationItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initNavigationItem {
    //navigation item
    YiDianButton *rightbtn=[YiDianButton buttonWithType:UIButtonTypeRoundedRect];
    rightbtn.titleLabel.font=[UIFont systemFontOfSize:10];
    [rightbtn addTarget:self action:@selector(clicked_yidian:) forControlEvents:UIControlEventTouchUpInside];
    BBBadgeBarButtonItem *barButton=[[BBBadgeBarButtonItem alloc] initWithCustomUIButton:rightbtn];
    self.navigationItem.rightBarButtonItem=barButton;
}

- (void)clicked_yidian:(id)sender {
    NSLog(@"Bar Button Item Pressed");
    BBBadgeBarButtonItem *barButton = (BBBadgeBarButtonItem *)self.navigationItem.rightBarButtonItem;
    // If you don't want to remove the badge when it's zero just set
    barButton.shouldHideBadgeAtZero = YES;
    // Next time zero should still be displayed
    
    // You can customize the badge further (color, font, background), check BBBadgeBarButtonItem.h ;)
    YiDianViewController *yidianVC=[[YiDianViewController alloc]init];
    [self.navigationController pushViewController:yidianVC animated:YES];
}

- (void)loadMJRefreshingView {
    self.tableView.footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    __weak __typeof(self) weakSelf=self;
    self.tableView.header=[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    // 马上进入刷新状态
    [self.tableView.header beginRefreshing];
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

- (void)loadNewData {
    offset=[NSNumber numberWithUnsignedInteger:0];
    [dataList removeAllObjects];
    [self initializeTableContent];
    [self.tableView.header endRefreshing];
}

- (void)initializeTableContent {
    
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)dealloc {
    [dataList removeAllObjects];
}


@end
