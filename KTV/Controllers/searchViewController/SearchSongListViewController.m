//
//  songListViewController.m
//  zzKTV
//
//  Created by mCloud on 15/3/30.
//  Copyright (c) 2015年 StevenHu. All rights reserved.
//

#import "SearchSongListViewController.h"
#import "ResultTableViewController.h"
#import "Utility.h"
#import "PinYinForObjc.h"
#define TOPCELLIDENTIFY @"SearchTableCell"
#import "SearchTableCell.h"
#define BOTTOMCELLIDENTIFY @"SongBottomCell"
#import "SongBottomCell.h"
#import "YiDianViewController.h"
#import "BBBadgeBarButtonItem.h"
#import "Song.h"
#import "NSManagedObject+helper.h"
#import "SFSelectView.h"
#import "SongResultTableViewController.h"
#import "UIImage+Utility.h"
@interface SearchSongListViewController ()<searchSongDelegate>{
    NSInteger _previousRow;
    UIView *promtView;
    SFSelectView *_leftView;
    
}
@property (nonatomic,strong)NSMutableArray *dataList;
@property (nonatomic,strong)NSIndexPath *selectedIndexPath;
@property(nonatomic,strong)UISearchController *searchController;
@property(nonatomic,strong)ResultTableViewController *resultVC;


@end

@implementation SearchSongListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem=nil;
    [self initializeTableContent];
}

- (void)initializeTableContent {
    UIImageView *bgImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"songsList_bg"]];
    self.tableView.backgroundView=bgImageView;
    self.definesPresentationContext = YES;
    self.tableView.showsHorizontalScrollIndicator=NO;
    self.tableView.showsVerticalScrollIndicator=NO;
    UINib *nib=[UINib nibWithNibName:@"SearchTableCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:TOPCELLIDENTIFY];
    _previousRow = -1;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight=50;
    _resultVC=[[ResultTableViewController alloc]init];
    _resultVC.delegate=self;
    self.searchController=[[UISearchController alloc]initWithSearchResultsController:_resultVC];
    self.searchController.searchResultsUpdater=_resultVC;
    self.searchController.searchBar.delegate=_resultVC;
    [self.searchController.searchBar sizeToFit];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.searchController.hidesNavigationBarDuringPresentation=NO;
    self.automaticallyAdjustsScrollViewInsets=YES;
    self.navigationItem.titleView=self.searchController.searchBar;
    self.searchController.searchBar.placeholder=NSLocalizedString(@"searchhinttext_searchVC", nil);
    self.searchController.searchBar.backgroundImage=[UIImage imageWithColor:[UIColor clearColor]];
    [self createDefaultView];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.searchController.searchBar performSelectorOnMainThread:@selector(becomeFirstResponder) withObject:self waitUntilDone:NO];
    [super viewDidAppear:animated];
}

- (void)createDefaultView {
    promtView=[[UIView alloc]initWithFrame:CGRectMake(self.view.center.x-300/2, 10, 300, 150)];
    UILabel *labelStr=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 200)];
    labelStr.numberOfLines=0;
    labelStr.textColor=[UIColor groupTableViewBackgroundColor];
    labelStr.font=[UIFont systemFontOfSize:15];
    labelStr.text=NSLocalizedString(@"searchcomment_searchVC", ni);
    [labelStr sizeToFit];
    [promtView addSubview:labelStr];
    [self.view addSubview:promtView];
    
    //modify searchbar
    _leftView= [[SFSelectView alloc]initWithItems:@[NSLocalizedString(@"all", ni),NSLocalizedString(@"songs", ni),NSLocalizedString(@"singers", ni)]];
    _leftView.delegate = _resultVC;
    UITextField *textField;
    for (UIView *view in [self.searchController.searchBar subviews])
    {
        for (UIView *subView in view.subviews) {
            if ([subView isKindOfClass:[UITextField class]])
            {
                textField = (UITextField *)subView;
            }
        }
        
    }
    textField.clearButtonMode = UITextFieldViewModeNever;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = _leftView;

}

- (void)showPromtView:(BOOL)isShow {
    promtView.hidden=isShow;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
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


// Fake adding element
- (IBAction)addItemToListButtonPressed {
    BBBadgeBarButtonItem *barButton = (BBBadgeBarButtonItem *)self.navigationItem.leftBarButtonItem;
    barButton.badgeValue = [NSString stringWithFormat:@"%d", [barButton.badgeValue intValue] + 1];
}

- (void)searchDone {
    NSLog(@"search Done");
    promtView.hidden=NO;
}

- (void)searching {
    promtView.hidden=YES;
}

- (void)clickSingerWithSingerName:(NSString*)singerName {
    [self dismissViewControllerAnimated:NO completion:^{
        SongResultTableViewController *songVC=[[SongResultTableViewController alloc]init];
        songVC.singerName=singerName;
        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:songVC];
        [self presentViewController:nav animated:YES completion:nil];
        NSLog(@"111");
    }];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canResignFirstResponder {
    return YES;
}

//-(UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}
//
//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}
@end
