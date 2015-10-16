//
//  AppDelegate.m
//  KTV
//
//  Created by stevenhu on 15/4/17.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseTabBarViewController.h"
#import "Utility.h"
#import "SDWebImageManager.h"
#import "MBProgressHUD.h"
#import "DownLoadFileTool.h"
@interface AppDelegate () {
    MBProgressHUD *HUD;
    Utility *utilityTool;
    BOOL checkLoadDataDone;
    BOOL idel;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    utilityTool=[Utility instanceShare];
    idel=YES;
    checkLoadDataDone=NO;
    [utilityTool addObserver:self forKeyPath:@"netWorkStatus" options:NSKeyValueObservingOptionNew context:nil];
    BaseTabBarViewController *_tabVC=[[BaseTabBarViewController alloc]init];
    UIImage *imagebottom=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"nav_bottom_bg" ofType:@"png"]];
    [_tabVC.tabBar setBackgroundImage:imagebottom];
    self.window.rootViewController=_tabVC;
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[SDWebImageManager sharedManager].imageCache clearMemory];
    [[SDWebImageManager sharedManager].imageCache clearDisk];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"netWorkStatus"]) {
        if ([[change valueForKey:NSKeyValueChangeNewKey]boolValue] && idel) {
            idel=NO;
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (!checkLoadDataDone)  [self initData];
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)initData {
    HUD = [[MBProgressHUD alloc] initWithView:self.window];
    [self.window.rootViewController.view addSubview:HUD];
    HUD.labelText =NSLocalizedString(@"hud_text_init", nil);
    HUD.detailsLabelText =NSLocalizedString(@"hud_detail_wait", nil);
    HUD.square = YES;
    HUD.dimBackground=YES;
    HUD.detailsLabelColor=[UIColor greenColor];
    [[DownLoadFileTool instance]downLoadTxtFile:^(BOOL Completed,NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hide:YES];
            if (Completed) {
                NSLog(@"download file And import data done!");
                
            } else {
                NSLog(@"download file OR import data Error!");
            }
            idel=YES;
            checkLoadDataDone=YES;
        });
    }];
    [HUD show:YES];
}

- (void)dealloc {
    [utilityTool removeObserver:self forKeyPath:@"netWorkStatus" context:nil];
}

@end
