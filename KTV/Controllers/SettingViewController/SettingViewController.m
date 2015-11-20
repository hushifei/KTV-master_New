//
//  SettingViewController.m
//  KTV
//
//  Created by stevenhu on 15/4/29.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import "SettingViewController.h"
#import "BBBadgeBarButtonItem.h"
#import "Utility.h"
#import "YiDianViewController.h"
#import "MBProgressHUD.h"
#import "AboutViewController.h"
#import "CommandControler.h"
#import "HuToast.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
@interface SettingViewController () {
    CommandControler *cmd;
    HuToast *myToast;
}
@property (nonatomic, strong) NSMutableArray *dataSrc;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *backView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.tableView.tableFooterView=backView;
    self.tableView.showsHorizontalScrollIndicator=NO;
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.backgroundColor=[UIColor groupTableViewBackgroundColor];
    self.tableView.layer.backgroundColor=[UIColor whiteColor].CGColor;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight=60.0f;
    //    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"geshou_area_bg"]];
    
    self.tableView.scrollEnabled=NO;
    UIImage *image=[UIImage imageNamed:@"songsList_bg"];
    self.tableView.backgroundColor=[UIColor colorWithPatternImage:[image stretchableImageWithLeftCapWidth:100 topCapHeight:100 ]];
    
    
    //    self.dataSrc = [[NSMutableArray alloc] initWithObjects:NSLocalizedString(@"restartHost", nil),NSLocalizedString(@"shutdownHost", nil), NSLocalizedString(@"clearCachedata", nil),NSLocalizedString(@"about", nil), nil];
    self.dataSrc = [[NSMutableArray alloc] initWithObjects:NSLocalizedString(@"restartHost", nil),NSLocalizedString(@"shutdownHost", nil), NSLocalizedString(@"clearCachedata", nil),nil];
    
    cmd=[[CommandControler alloc]init];
    myToast=[[HuToast alloc]init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavigationItem {
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    static NSString *cellIdentify=@"cellIdentify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
        cell.selectionStyle=UITableViewCellSelectionStyleDefault;
        cell.backgroundColor=[UIColor groupTableViewBackgroundColor];
    }
    
    switch (indexPath.row) {
        case 0:
        case 1:
        case 2:
            cell.textLabel.text=self.dataSrc[indexPath.row];
            break;
        case 3: {
            cell.textLabel.text=self.dataSrc[indexPath.row];
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        default:
            break;
    }
    cell.backgroundColor=[UIColor clearColor];
    cell.textLabel.textColor=[UIColor whiteColor];
    [cell.textLabel sizeToFit];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            [cmd sendCmd_restartDevice:^(BOOL completed, NSError *error) {
                if (completed) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [HuToast showToastWithMessage:NSLocalizedString(@"restartsuccess", nil) WithTimeDismiss:nil messageType:KMessageSuccess];
                    });
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [HuToast showToastWithMessage:NSLocalizedString(@"restartfailure", nil)  WithTimeDismiss:nil messageType:KMessageStyleError];
                    });
                }
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }];
            break;
        }
        case 1: {
            [cmd sendCmd_shutdownDevice:^(BOOL completed, NSError *error) {
                if (completed) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [HuToast showToastWithMessage:NSLocalizedString(@"shutdownsuccess", nil)  WithTimeDismiss:nil messageType:KMessageSuccess];
                    });
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [HuToast showToastWithMessage:NSLocalizedString(@"shutdownfailure", nil)  WithTimeDismiss:nil messageType:KMessageStyleError];
                    });
                    
                }
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }];
            break;
        }
        case 2: {
            //clear tmp file and so on;
            [[SDWebImageManager sharedManager].imageCache clearMemory];
            [[SDWebImageManager sharedManager].imageCache clearDisk];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [HuToast showToastWithMessage:NSLocalizedString(@"clearcachedatasuccess", nil)  WithTimeDismiss:nil messageType:KMessageSuccess];
            break;
        }
        case 3: {
            AboutViewController *vc=[[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
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
