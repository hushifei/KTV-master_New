//
//  ViewController.m
//  KTV
//
//  Created by stevenhu on 15/4/17.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//
#import "MainViewController.h"
#import "huSearchBar.h"
#import "SettingViewController.h"
#import "SearchSongListViewController.h"

#import "SingerAreaViewController.h"
#import "jinxuanViewController.h"
#import "paiHangViewController.h"
#import "newSongViewController.h"
#import "CollectionViewController.h"
#import "SoundViewController.h"
#import "Utility.h"
#import "BaseNavigationController.h"

#import "NewPaiHangViewController.h"
#import "NSString+Utility.h"
#import "MBProgressHUD.h"
#import "DataManager.h"
#import "HuToast.h"

#import "TempViewController.h"
#import "AppDelegate.h"
#import "APLMainTableViewController.h"

@interface MainViewController ()<UISearchBarDelegate,DataManagerDelegate> {
    MBProgressHUD *HUD;
    UIButton *geshouBtn;
    UIButton *paihangBtn;
    UIButton *jinxuanBtn;
    UIButton *newSongBtn;
    UIButton *shoucanBtn;
    UIButton *conHostBtn;
    UIBarButtonItem *kege;
    UIBarButtonItem *bokong;
    UIView *bottomBGView;
    UIButton *promptConnectBtn;
    BOOL onGoingInitData;
    NSMutableArray *models;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets=YES;
    [self createContextUI];
//    if (DEBUG) {
//        [self copyFile];
//    }
    
    NSArray *downloadTxtFiles=@[@"songlist.txt",@"singlist.txt",@"typelist.txt",@"orderdata.txt"];
    models=[NSMutableArray new];
    for (NSString *fileName in downloadTxtFiles) {
        KTVModel *oneModel=[[KTVModel alloc]initWithFileName:fileName];
        [models addObject:oneModel];
    }
    [self  showConnectionHostMessage:NO];
    [Utility instanceShare].serverIPAddress=@"192.168.43.1";
    [[Utility instanceShare] starToMonitorNetowrkConnection];
    
    [[Utility instanceShare] addObserver:self forKeyPath:@"netWorkStatus" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    

    
//    [self initData];
    
}



- (void)copyFile {
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSString *sourcePath=[[NSBundle mainBundle]pathForResource:@"KTV-master.zip" ofType:nil];
    if ([fileManager fileExistsAtPath:sourcePath]) {
        NSString *distancePath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"KTV_Master.zip"];
        [fileManager copyItemAtPath:sourcePath toPath:distancePath error:nil];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (onGoingInitData || ![Utility instanceShare].netWorkStatus)  return;
    onGoingInitData=YES;
    [self initData];
}

- (void)initData {
    if ([Utility instanceShare].netWorkStatus) {
            [[DataManager instanceShare]downloadTxtFiles:models delegate:self completionBlock:^(BOOL isOk, NSError *error) {
                if (error) {
                    NSLog(@"%@",error.description);
                    return ;
                }
                NSBlockOperation *operation=[NSBlockOperation blockOperationWithBlock:^{
                    [[DataManager instanceShare]addIntoDataSourceWithModels:models delegate:self];
                    NSLog(@"data import done ok!");
                }];
                [operation start];
            }];
        
    }
    //    po [[self view] recursiveDescription]
    //@[@"songlist.txt",@"singlist.txt",@"typelist.txt",@"orderdata.txt"]

}

- (void)startingDownload:(DataManager*)downloadFileTool model:(KTVModel*)model {
    NSLog(@"%s %@",__PRETTY_FUNCTION__,model.fileName);
}

- (void)failDownload:(DataManager *)downloadFileTool model:(KTVModel *)model {
    NSLog(@"%s %@",__PRETTY_FUNCTION__,model.fileName);

}
- (void)finishedDownload:(DataManager*)downloadFileTool model:(KTVModel*)model {
    NSLog(@"%s %@",__PRETTY_FUNCTION__,model.fileName);
}
- (void)tasksWillDownloading:(DataManager *)downloadFileTool {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (!HUD) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.labelText=NSLocalizedString(@"hud_text_init",nil);
        HUD.detailsLabelText =NSLocalizedString(@"hud_detail_wait",nil);
        HUD.detailsLabelColor=[UIColor greenColor];
    }
      [HUD show:YES];
}

- (void)tasksDownloaded:(DataManager *)downloadFileTool {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSArray *retryDownloadModels=[models filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"downloadStatus != 3"]]; // !=TxtDownloadModel_finished
    if (retryDownloadModels.count <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //
        });
    } else {
        [models enumerateObjectsUsingBlock:^(KTVModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"%d",obj.downloadStatus);
        }];
    }
    NSLog(@"\n txt  done ok!");
    if (HUD.hidden==NO) {
        HUD.hidden=YES;
        [HUD removeFromSuperview];
        HUD=nil;
    };


}


- (void)startingImportData:(DataManager*)downloadFileTool model:(KTVModel*)model {
    NSLog(@"%s %@",__PRETTY_FUNCTION__,model.fileName);

}


- (void)failImportData:(DataManager*)downloadFileTool model:(KTVModel*)model {
    NSLog(@"%s %@",__PRETTY_FUNCTION__,model.fileName);

}

- (void)finishedImportData:(DataManager*)downloadFileTool model:(KTVModel*)model {
    NSLog(@"%s %@",__PRETTY_FUNCTION__,model.fileName);

}

- (void)tasksWillImportData:(DataManager*)downloadFileTool {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (!HUD) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
    }
    HUD.labelText=NSLocalizedString(@"Import Data",@"导入数据");
    HUD.detailsLabelText =NSLocalizedString(@"please Watting",@"请稍后...");
    HUD.detailsLabelColor=[UIColor greenColor];
    [HUD show:YES];


}

- (void)tasksDataImported:(DataManager*)downloadFileTool {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    HUD.hidden=YES;
    [HUD removeFromSuperview];
    HUD=nil;
    onGoingInitData=NO;
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden=NO;
    [super viewWillAppear:animated] ;
    
}


- (void)showConnectionHostMessage:(BOOL)show {
    CGSize size=self.view.bounds.size;
    if (promptConnectBtn==nil) {
        promptConnectBtn=[[UIButton alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(self.view.frame),size.width-40,40)];
        promptConnectBtn.backgroundColor=[UIColor brownColor];
        [promptConnectBtn setTitle:@"请连接包厢" forState:UIControlStateNormal];
        promptConnectBtn.hidden=YES;
        [self.view addSubview:promptConnectBtn];
    }
    if (show) {
        [UIView animateWithDuration:1.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            promptConnectBtn.hidden=NO;
            promptConnectBtn.frame= CGRectMake(20, CGRectGetMaxY(bottomBGView.frame)+15,size.width-40,40);
        } completion:nil];
    } else {
        
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            promptConnectBtn.hidden=YES;
            promptConnectBtn.frame= CGRectMake(20, CGRectGetMaxY(self.view.frame),size.width-40,40);
        } completion:nil];
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
//    NewPaiHangViewController *vc=[[NewPaiHangViewController alloc]init];
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
    TempViewController *scanVC=[[TempViewController alloc]init];
    scanVC.completed=^(TempViewController *tempViewController,NSString* result) {
        NSString *returnResult=[result copy];
        [tempViewController.navigationController popViewControllerAnimated:YES];
        [self handScanResult:returnResult];

    };
    [self.navigationController pushViewController:scanVC animated:YES];
//    [self presentViewController:scanVC animated:YES completion:nil];
}


- (void)handScanResult:(NSString*)result {
    
    if ([result hasPrefix:@"wifi: ;T:WPA2;S:"] && [[result substringFromIndex:[@"wifi: ;T:WPA2;S:" length]] componentsSeparatedByString:@";"].count ==2){
        NSArray *scanArray=[[result substringFromIndex:[@"wifi: ;T:WPA2;S:" length]] componentsSeparatedByString:@";"];
        NSString *wifiName=scanArray[0];
        NSString *wifiPassWord=[[scanArray[1] componentsSeparatedByString:@":"]lastObject];
        UIAlertController *alVC=[UIAlertController alertControllerWithTitle:NSLocalizedString(@"connectnetwork", nil) message:NSLocalizedString(@"connectNetContent", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alVC dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *confirmaction=[UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [Utility instanceShare].serverIPAddress=@"192.168.43.1";
            [alVC dismissViewControllerAnimated:YES completion:nil];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
//
        [alVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text=[NSString stringWithFormat:@ "%@ : %@",NSLocalizedString(@"username", nil),wifiName];
            textField.enabled=NO;
        }];
        [alVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text=[NSString stringWithFormat: @"%@ : %@",NSLocalizedString(@"password", nil),wifiPassWord];
            textField.enabled=NO;
        }];
        
        [alVC addAction:cancelAction];
        [alVC addAction:confirmaction];

        [self presentViewController:alVC animated:YES completion:nil];
        
    } else if ([result hasPrefix:@"wifi: ;eth0:"] && [[result substringFromIndex:[@"wifi: ;eth0:" length]]isIpAddress]) {
        //192.168.0.90
        if (![[Utility instanceShare].serverIPAddress isEqualToString:[result substringFromIndex:[@"wifi: ;eth0:" length]]]) {
//            NSLog(@"%@",[result substringFromIndex:[@"wifi: ;eth0:" length]]);
            [Utility instanceShare].serverIPAddress=[result substringFromIndex:[@"wifi: ;eth0:" length]];
        }
        
        [HuToast showToastWithMessage:@"扫描成功" WithTimeDismiss:nil messageType:KMessageSuccess];
    } else {
        UIAlertController *alVC=[UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"scancodeerror", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action=[UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alVC dismissViewControllerAnimated:YES completion:nil];
        }];
        [alVC addAction:action];
        [self presentViewController:alVC animated:YES completion:nil];
        
    }
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
    
    
    bottomBGView=[[UIView alloc]initWithFrame:CGRectMake(SEARCHMARGIN_LRT, BOTTOMBGView_TOPMARGIN, searchBar.bounds.size.width, topBGView.bounds.size.height)];
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

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
//    SearchSongListViewController *vc=[[SearchSongListViewController alloc]initWithStyle:UITableViewStylePlain];
    APLMainTableViewController *vc=[[APLMainTableViewController alloc]initWithStyle:UITableViewStylePlain];
//    SearchViewController *vc=[[SearchViewController alloc]init];
//    [self.navigationController pushViewController:vc animated:YES];
//    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    BaseNavigationController *navc=[[BaseNavigationController alloc]initWithRootViewController:vc];
//
//    [self.navigationController presentViewController: navc animated:YES completion: nil];
//    [self.navigationController pushViewController:navc animated:YES];
    BaseNavigationController *nav= (BaseNavigationController*)((AppDelegate*)[UIApplication sharedApplication].delegate).tabVC.selectedViewController;
    [nav pushViewController:vc animated:YES];
    

    return YES;
}




@end
