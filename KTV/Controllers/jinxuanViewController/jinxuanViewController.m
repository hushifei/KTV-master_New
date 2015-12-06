//
//  jinxuanViewController.m
//  KTV
//
//  Created by stevenhu on 15/4/25.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import "jinxuanViewController.h"
#import "jingXuanTableViewCell.h"
#define CELLIDENTIFY @"jingXuanTableViewCell"
#import "Typelist.h"
#import "SingersViewController.h"
#import "SingerAreaViewController.h"
#import "YiDianViewController.h"
#import "BBBadgeBarButtonItem.h"
#import "BokongView.h"
#import "SettingViewController.h"
#import "SoundViewController.h"
#import "NSString+Utility.h"
#import "CommandControler.h"
#import "DataManager.h"
@interface jinxuanViewController ()
{
    NSMutableArray *dataList;
    UIImage *tableBgImage;

}
@end

@implementation jinxuanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=NSLocalizedString(@"omnibus", nil);
    tableBgImage=[UIImage imageNamed:@"songsList_bg"];
    UIImageView *bgImageView=[[UIImageView alloc]initWithImage:tableBgImage];
    self.tableView.backgroundView=bgImageView;
    self.tableView.rowHeight=60.0f;
    UINib *nib=[UINib nibWithNibName:CELLIDENTIFY bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CELLIDENTIFY];
    [self initializeTableContent];
}

- (void)initializeTableContent {
    dataList=[[NSMutableArray alloc]init];
    NSString *sqlStr=@"select * from TypeTable where type='3'";
    FMResultSet *rs=[[DataManager instanceShare].db executeQuery:sqlStr];
    while ([rs next]) {
        Typelist *type=[[Typelist alloc]init];
        type.ztype = [rs stringForColumn:@"type"];
        type.ztypeid = [rs stringForColumn:@"typeid"];
        type.ztypename = [rs stringForColumn:@"typename"];
        [dataList addObject:type];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return dataList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    jingXuanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLIDENTIFY forIndexPath:indexPath];
    cell.backgroundColor=[UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
     Typelist *onetype=dataList[indexPath.row];
    cell.numberName.text=[NSString stringWithFormat:@"%02d",(int)indexPath.row+1];
    cell.numberName.font=[UIFont fontWithName:@"DIN Condensed" size:12];
    cell.typeName.text=onetype.ztypename;
    // Configure the cell...
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SingersViewController *vc=[[SingersViewController alloc]init];
    Typelist *onetype=dataList[indexPath.row];
    vc.area=onetype.ztype;
    [self.navigationController pushViewController:vc animated:YES];
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

@end
