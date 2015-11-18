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
#import "BBBadgeBarButtonItem.h"
#import "Song.h"
#import "Singer.h"
#import "SFSelectView.h"
#import "SongListViewController.h"
#import "UIImage+Utility.h"
@interface SearchSongListViewController (){
    NSInteger _previousRow;
    UIView *promtView;
    SFSelectView *_leftView;
    
}
@property (nonatomic,strong)NSIndexPath *selectedIndexPath;
@property(nonatomic,strong)UISearchController *searchController;
@property(nonatomic,strong)ResultTableViewController *resultVC;


@end

@implementation SearchSongListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeTableContent];
}

- (void)initializeTableContent {
    UIImageView *bgImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"songsList_bg"]];
    self.tableView.backgroundView=bgImageView;
    self.tableView.showsHorizontalScrollIndicator=NO;
    self.tableView.showsVerticalScrollIndicator=NO;
    _previousRow = -1;
    _dataList = [[NSMutableArray alloc] init];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight=50;
    _resultVC=[[ResultTableViewController alloc]init];
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
    _resultVC.searchSongListVC=self;
    [self createDefaultView];
}


//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
////    [self.searchController.searchBar performSelectorOnMainThread:@selector(becomeFirstResponder) withObject:self waitUntilDone:NO];
//}

- (void)createDefaultView {
//    promtView=[[UIView alloc]initWithFrame:CGRectMake(self.view.center.x-300/2, 10, 300, 150)];
//    UILabel *labelStr=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 200)];
//    labelStr.numberOfLines=0;
//    labelStr.textColor=[UIColor groupTableViewBackgroundColor];
//    labelStr.font=[UIFont systemFontOfSize:15];
//    labelStr.text=NSLocalizedString(@"searchcomment_searchVC", ni);
//    [labelStr sizeToFit];
//    [promtView addSubview:labelStr];
//    [self.view addSubview:promtView];
    
    //modify searchbar
//    _leftView= [[SFSelectView alloc]initWithItems:@[NSLocalizedString(@"all", ni),NSLocalizedString(@"songs", ni),NSLocalizedString(@"singers", ni)]];
    _leftView.delegate = _resultVC;
//    UITextField *textField;
//    for (UIView *view in [self.searchController.searchBar subviews])
//    {
//        for (UIView *subView in view.subviews) {
//            if ([subView isKindOfClass:[UITextField class]])
//            {
//                textField = (UITextField *)subView;
//            }
//        }
//    }
//    textField.clearButtonMode = UITextFieldViewModeNever;
//    textField.leftViewMode = UITextFieldViewModeAlways;
//    textField.leftView = _leftView;

}

- (void)setDataList:(NSMutableArray *)dataList {
    [self.tableView reloadData];
}

- (void)showPromtView:(BOOL)isShow {
    promtView.hidden=isShow;
}

- (void)clickSinger:(Singer*)singer {
    //    [self dismissViewControllerAnimated:NO completion:^{
    SongListViewController *songVC=[[SongListViewController alloc]init];
    songVC.singerName=singer.singer;
    songVC.needLoadData=YES;
    [self.navigationController pushViewController:songVC animated:YES];
    //    }];
}

- (void)clickSong:(Song *)song {
    //    [self.navigationController popToRootViewControllerAnimated:YES];
    //    [self dismissViewControllerAnimated:NO completion:^{
    SongListViewController *songVC=[[SongListViewController alloc]init];
    songVC.needLoadData=NO;
    [songVC setDataList:song];
    [self.navigationController pushViewController:songVC animated:YES];
    //    }];
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

//-(UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}
//
//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}
- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
