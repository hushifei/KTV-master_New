//
//  ViewController.m
//  KTV
//
//  Created by stevenhu on 15/4/17.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//
#import "DownLoadFileTool.h"
#import "MainViewController.h"
#import "huSearchBar.h"
#import "SettingViewController.h"
#import "SearchSongListViewController.h"
#import "ScanCodeViewController.h"
#import "SingerAreaViewController.h"
#import "jinxuanViewController.h"
#import "paiHangViewController.h"
#import "newSongViewController.h"
#import "CollectionViewController.h"
#import "SoundViewController.h"
#import "Utility.h"
#import "BokongView.h"
#import "MBProgressHUD.h"
#import "HuToast.h"
#import "BaseNavigationController.h"
@interface MainViewController ()<UISearchBarDelegate,ScanCodeDelegate> {
    UIButton *geshouBtn;
    UIButton *paihangBtn;
    UIButton *jinxuanBtn;
    UIButton *newSongBtn;
    UIButton *shoucanBtn;
    UIButton *conHostBtn;
    UIBarButtonItem *kege;
    UIBarButtonItem *bokong;
    MBProgressHUD *HUD;
    HuToast *myToast;
    NSURLConnection *connection;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    myToast=[[HuToast alloc]init];
    self.automaticallyAdjustsScrollViewInsets=YES;
    [self createContextUI];
//    [self copyFile];
    [self performSelector:@selector(initData) withObject:nil afterDelay:6];
}

- (void)initData {
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText =NSLocalizedString(@"hud_text_init", nil);
    HUD.detailsLabelText =NSLocalizedString(@"hud_detail_wait", nil);
    HUD.square = YES;
    HUD.dimBackground=YES;
    HUD.detailsLabelColor=[UIColor greenColor];
    [[DownLoadFileTool instance]downLoadTxtFile:^(BOOL Completed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hide:YES];
            if (Completed) {
                NSLog(@"download file And import data done!");
                
            } else {
                NSLog(@"download file OR import data Error!");
            }
        });
    }];
    [HUD show:YES];
}

- (void)copyFile {
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSString *sourcePath=[[NSBundle mainBundle]pathForResource:@"KTV-master.zip" ofType:nil];
    if ([fileManager fileExistsAtPath:sourcePath]) {
        NSString *distancePath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"KTV_Master.zip"];
        [fileManager copyItemAtPath:sourcePath toPath:distancePath error:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clicked_setting:(id)sender {
    SettingViewController *setVC=[[SettingViewController alloc]init];
    [self.navigationController pushViewController:setVC animated:YES];
}

-(void)click_geshou:(id)sender {
    SingerAreaViewController *vc=[[SingerAreaViewController alloc]init];
    //    UINavigationController *naVC=[[UINavigationController alloc]initWithRootViewController:vc];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clicked_paihangBtn:(id)sender {
    paiHangViewController *vc=[[paiHangViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)click_jinxuanBtn:(id)sender {
    jinxuanViewController *vc=[[jinxuanViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)click_newSong:(id)sender {
    newSongViewController *vc=[[newSongViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)click_shoucang:(id)sender {
    CollectionViewController *vc=[[CollectionViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)connect_Host:(id)sender {
    ScanCodeViewController *scanVC=[[ScanCodeViewController alloc]init];
    [self presentViewController:scanVC animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canResignFirstResponder {
    return YES;
}

//navigationbar

- (void)createContextUI{
    //main view
    //bg
    UIImageView *bgImageView;
    //    if (self.navigationController!=nil) {
    //        CGRect rect=self.view.frame;
    //        rect.size.height-=self.navigationController.navigationBar.bounds.size.height;
    //        bgImageView=[[UIImageView alloc]initWithFrame:rect];
    //    } else {
    bgImageView=[[UIImageView alloc]initWithFrame:self.view.frame];
    //    }
    bgImageView.image=[UIImage imageNamed:@"mainVC_bg"];
    self.view =bgImageView;
    bgImageView.center=self.view.center;
    bgImageView.userInteractionEnabled=YES;
    //heard
    
    UIImageView *headView=[[UIImageView alloc]initWithFrame:CGRectMake(SCREENSIZE.width/2-HEADVIEW_WH/2, HEADVIEW_TOPMARGIN, HEADVIEW_WH, HEADVIEW_WH)];
    
    [headView setImage:[UIImage imageNamed:@"touxiang"]];
    [bgImageView addSubview:headView];
    CABasicAnimation *rotation=[CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotation.toValue=[NSNumber numberWithFloat:M_PI * 2.0 ];
    rotation.duration=10;
    //    rotation.autoreverses=YES;
    rotation.repeatCount=MAXFLOAT;
    rotation.removedOnCompletion=NO;
    rotation.fillMode=kCAFillModeForwards;
    [headView.layer addAnimation:rotation forKey:@"rotation"];
    
    //searchbar
    huSearchBar *searchBar=[[huSearchBar alloc]initWithFrame:CGRectMake(SEARCHMARGIN_LRT,SEARCHMARGIN_TOPMARGIN,SCREENSIZE.width-(SEARCHMARGIN_LRT*2), SEARCH_H)];
    searchBar.placeholder=NSLocalizedString(@"searchhinttext", nil);
    searchBar.delegate=self;
    [self.view addSubview:searchBar];
    
    /**
     *  /
     *
     *  topBGView
     */
    
    UIView *topBGView=[[UIView alloc]initWithFrame:CGRectMake(searchBar.frame.origin.x, TOPBGView_TOPMARGIN, searchBar.bounds.size.width, TOPBGView_H)];
    [self.view addSubview:topBGView];
    //    topBGView.backgroundColor=[UIColor whiteColor];
    //geshouBtn
    geshouBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    geshouBtn.frame=CGRectMake(searchBar.frame.origin.x+SEARCHMARGIN_LRT, 0, BUTTON_WH, BUTTON_WH);
    [geshouBtn setImage:[UIImage imageNamed:@"geshou"] forState:UIControlStateNormal];
    [geshouBtn addTarget:self action:@selector(click_geshou:) forControlEvents:UIControlEventTouchUpInside];
    [topBGView addSubview:geshouBtn];
    
    UILabel *geshouLabel=[[UILabel alloc]initWithFrame:CGRectMake(geshouBtn.frame.origin.x, CGRectGetMaxY(geshouBtn.frame)+2, geshouBtn.bounds.size.width, 22)];
    geshouLabel.text=NSLocalizedString(@"singers", nil);
    geshouLabel.textAlignment=NSTextAlignmentCenter;
    geshouLabel.font=[UIFont systemFontOfSize:14.0f];
    //    [geshouLabel sizeThatFits:CGSizeZero];
    //    [geshouLabel sizeToFit];
    [geshouLabel setTextColor:[UIColor groupTableViewBackgroundColor]];
    [topBGView addSubview:geshouLabel];
    
    //paihangBtn
    paihangBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    paihangBtn.frame=CGRectMake(CGRectGetMaxX(geshouBtn.frame)+SEARCHMARGIN_LRT*2, 0, BUTTON_WH, BUTTON_WH);
    [paihangBtn setImage:[UIImage imageNamed:@"paihangbang"] forState:UIControlStateNormal];
    [paihangBtn addTarget:self action:@selector(clicked_paihangBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topBGView addSubview:paihangBtn];
    
    UILabel *paihangLabel=[[UILabel alloc]initWithFrame:CGRectMake(paihangBtn.frame.origin.x,geshouLabel.frame.origin.y, geshouBtn.bounds.size.width, 22)];
    paihangLabel.text=NSLocalizedString(@"hotest", nil);
    paihangLabel.textAlignment=NSTextAlignmentCenter;
    paihangLabel.font=[UIFont systemFontOfSize:14.0f];
    [paihangLabel setTextColor:[UIColor groupTableViewBackgroundColor]];
    [topBGView addSubview:paihangLabel];
    
    //jinxuanBtn
    jinxuanBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    jinxuanBtn.frame=CGRectMake(CGRectGetMaxX(paihangBtn.frame)+SEARCHMARGIN_LRT*2, 0, BUTTON_WH, BUTTON_WH);
    [jinxuanBtn setImage:[UIImage imageNamed:@"jinxuanji"] forState:UIControlStateNormal];
    [jinxuanBtn addTarget:self action:@selector(click_jinxuanBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topBGView addSubview:jinxuanBtn];
    
    UILabel *jinxuanLabel=[[UILabel alloc]initWithFrame:CGRectMake(jinxuanBtn.frame.origin.x,geshouLabel.frame.origin.y, geshouBtn.bounds.size.width, 22)];
    jinxuanLabel.text=NSLocalizedString(@"omnibus", nil);
    jinxuanLabel.textAlignment=NSTextAlignmentCenter;
    jinxuanLabel.font=[UIFont systemFontOfSize:14.0f];
    [jinxuanLabel setTextColor:[UIColor groupTableViewBackgroundColor]];
    [topBGView addSubview:jinxuanLabel];
    
    /**
     *  /
     *
     *  bottomBGView
     */
    
    
    UIView *bottomBGView=[[UIView alloc]initWithFrame:CGRectMake(SEARCHMARGIN_LRT, BOTTOMBGView_TOPMARGIN, searchBar.bounds.size.width, topBGView.bounds.size.height)];
    [self.view addSubview:bottomBGView];
    //    bottomBGView.backgroundColor=[UIColor whiteColor];
    
    //changchanBtn
    newSongBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    newSongBtn.frame=CGRectMake(searchBar.frame.origin.x+SEARCHMARGIN_LRT, 0, BUTTON_WH, BUTTON_WH);
    [newSongBtn setImage:[UIImage imageNamed:@"changchan"] forState:UIControlStateNormal];
    [newSongBtn addTarget:self action:@selector(click_newSong:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBGView addSubview:newSongBtn];
    
    UILabel *newSongLabel=[[UILabel alloc]initWithFrame:CGRectZero];
    newSongLabel.text=NSLocalizedString(@"newsong", nil);
    newSongLabel.textAlignment=NSTextAlignmentCenter;
    newSongLabel.font=[UIFont systemFontOfSize:14.0f];
    [newSongLabel setTextColor:[UIColor groupTableViewBackgroundColor]];
    CGSize newSongLabelSize=[Utility  sizeWithString:newSongLabel.text font:newSongLabel.font];
    newSongLabel.frame=CGRectMake(newSongBtn.frame.origin.x+(newSongBtn.bounds.size.width-newSongLabelSize.width)/2,CGRectGetMaxY(newSongBtn.frame)+2, newSongLabelSize.width, newSongLabelSize.height);
    [bottomBGView addSubview:newSongLabel];
    
    //shoucanBtn
    shoucanBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    shoucanBtn.frame=CGRectMake(CGRectGetMaxX(newSongBtn.frame)+SEARCHMARGIN_LRT*2, 0, BUTTON_WH, BUTTON_WH);
    [shoucanBtn setImage:[UIImage imageNamed:@"shoucan"] forState:UIControlStateNormal];
    [shoucanBtn addTarget:self action:@selector(click_shoucang:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBGView addSubview:shoucanBtn];
    
    UILabel *shoucanLabel=[[UILabel alloc]initWithFrame:CGRectZero];
    shoucanLabel.text=NSLocalizedString(@"house", nil);
    shoucanLabel.textAlignment=NSTextAlignmentCenter;
    shoucanLabel.font=[UIFont systemFontOfSize:14.0f];
    CGSize shoucanLabelSize=[Utility sizeWithString:shoucanLabel.text font:shoucanLabel.font];
    shoucanLabel.frame=CGRectMake(shoucanBtn.frame.origin.x+(shoucanBtn.bounds.size.width-shoucanLabelSize.width)/2, CGRectGetMaxY(shoucanBtn.frame)+2, shoucanLabelSize.width, shoucanLabelSize.height);
    [shoucanLabel setTextColor:[UIColor groupTableViewBackgroundColor]];
    [bottomBGView addSubview:shoucanLabel];
    
    //conHostBtn
    conHostBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    conHostBtn.frame=CGRectMake(CGRectGetMaxX(shoucanBtn.frame)+SEARCHMARGIN_LRT*2, 0, BUTTON_WH, BUTTON_WH);
    [conHostBtn setImage:[UIImage imageNamed:@"conhost"] forState:UIControlStateNormal];
    [bottomBGView addSubview:conHostBtn];
    
    
    UILabel *conHostLabel=[[UILabel alloc]initWithFrame:CGRectZero];
    [conHostLabel setTextColor:[UIColor groupTableViewBackgroundColor]];
    conHostLabel.font=[UIFont systemFontOfSize:14.0f];
    conHostLabel.text=NSLocalizedString(@"connecthost", nil);
    CGSize conHostLabelSize=[Utility sizeWithString:conHostLabel.text font:conHostLabel.font];
    conHostLabel.frame=CGRectMake(conHostBtn.frame.origin.x+(conHostBtn.bounds.size.width-conHostLabelSize.width)/2, CGRectGetMaxY(conHostBtn.frame)+2, conHostLabelSize.width, conHostLabelSize.height);
    conHostLabel.textAlignment=NSTextAlignmentCenter;
    [conHostBtn addTarget:self action:@selector(connect_Host:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBGView addSubview:conHostLabel];
}

#pragma mark- ScanCodeDelegate
- (void)didFinishedScanCode:(NSError *)error withString:(NSString *)string {
    NSArray *scanArray=[string componentsSeparatedByString:@","];
    if (scanArray && [scanArray count]==2) {
        NSString *wifiName=scanArray[0];
        NSString *wifiPassWord=scanArray[1];
        UIAlertController *alVC=[UIAlertController alertControllerWithTitle:NSLocalizedString(@"connectnetwork", nil) message:NSLocalizedString(@"connectNetContent", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action=[UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alVC addAction:action];
    } else {
        UIAlertController *alVC=[UIAlertController alertControllerWithTitle:NSLocalizedString(@"connectnetwork", nil) message:NSLocalizedString(@"connectNetContent", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action=[UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alVC addAction:action];
        
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    SearchSongListViewController *vc=[[SearchSongListViewController alloc]initWithStyle:UITableViewStylePlain];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    BaseNavigationController *navc=[[BaseNavigationController alloc]initWithRootViewController:vc];
    [self.navigationController presentViewController: navc animated:YES completion: nil];
    return YES;
}

@end
