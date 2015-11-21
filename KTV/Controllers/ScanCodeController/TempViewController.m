
//
//  TempViewController.m
//  QRCode_Demo
//
//  Created by 沈红榜 on 15/11/17.
//  Copyright © 2015年 沈红榜. All rights reserved.
//

#import "TempViewController.h"
#import "Utility.h"
#import "NSString+Utility.h"
#import "SHBQRView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"
@interface TempViewController ()<SHBQRViewDelegate>

@end

@implementation TempViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title=@"连接包厢";
    self.tabBarController.tabBar.hidden=YES;
    SHBQRView *qrView = [[SHBQRView alloc] initWithFrame:self.view.bounds];
    qrView.delegate = self;
    [self.view addSubview:qrView];
}

- (void)qrView:(SHBQRView *)view ScanResult:(NSString *)result {
    AudioServicesPlayAlertSoundWithCompletion(1107,nil);
    if (_completed) {
        _completed(self,result);
    }
}

- (void)cancelQrView:(SHBQRView *)view {
    [self dismissViewControllerAnimated:YES completion:nil];
}
//
//- (void)viewDidAppear:(BOOL)animated {
//    [self.navigationController popViewControllerAnimated:NO];
//    [super viewDidAppear:animated];
//}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
