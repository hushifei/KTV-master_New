//
//  SearchViewController.m
//  KTV
//
//  Created by stevenhu on 15/11/18.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()
@property(nonatomic,strong)UITableView *searchTableView;
@property(nonatomic,strong)UITextField *searchBar;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self createUI];
    // Do any additional setup after loading the view.
}

- (void)createUI {
    if (_searchBar==nil) {
        _searchBar=[[UITextField alloc]initWithFrame:CGRectMake(0, 44, 300, 40)];
        _searchBar.text=@"111";
        [self.view addSubview:_searchBar];
    }
}


- (void)initNavigationItem {
    //navigation item
    _searchBar=[[UITextField alloc]initWithFrame:CGRectMake(0, 0, 300, 40)];
    _searchBar.backgroundColor=[UIColor whiteColor];
    _searchBar.text=@"111";
    self.navigationItem.titleView=_searchBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
