//
//  AppDelegate.m
//  KTV
//
//  Created by stevenhu on 15/4/17.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import "AppDelegate.h"
#import "Utility.h"
#import "SDWebImageManager.h"
#import "MBProgressHUD.h"
@interface AppDelegate () {
    MBProgressHUD *HUD;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window = window;
    [self enter];
    return YES;
}


-(void)enter{
    _tabVC=[[BaseTabBarViewController alloc]init];
    UIImage *imagebottom=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"nav_bottom_bg" ofType:@"png"]];
    [_tabVC.tabBar setBackgroundImage:imagebottom];
    self.window.rootViewController=_tabVC;
    [self.window makeKeyAndVisible];
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


//networkError connectnetwork
- (void)showMessageTitle:(NSString*)title message:(NSString*)message showType:(ViewType)type {
    NSString *localTitle=NSLocalizedString(title, nil);
    NSString *localMessage=NSLocalizedString(message, nil);
    if (type==Show_HUD) {
        HUD = [[MBProgressHUD alloc] initWithView:self.window];
        [self.window.rootViewController.view addSubview:HUD];
        HUD.labelText =localTitle;
        HUD.detailsLabelText =localMessage;
        HUD.square = YES;
        HUD.dimBackground=YES;
        [HUD showAnimated:YES whileExecutingBlock:^{
            sleep(3);
        } completionBlock:^{
            [HUD hide:YES];
        }];
    } else {
        UIAlertController *alVC=[UIAlertController alertControllerWithTitle:localTitle message:localMessage preferredStyle:UIAlertControllerStyleAlert];
        alVC.view.backgroundColor=[UIColor clearColor];
        
        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alVC dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *confirmaction=[UIAlertAction actionWithTitle:NSLocalizedString(@"jumpSetting", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            [alVC dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alVC addAction:cancelAction];
        [alVC addAction:confirmaction];
        
        [[self topMostController] presentViewController:alVC animated:YES completion:nil];
    }
}

- (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

#pragma mark - UIStateRestoration

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    return YES;
}


/*
- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}


-(UIViewController *)getCurrentRootViewController {
    UIViewController *result;
    UIWindow *topWindow=[UIApplication sharedApplication].keyWindow;
    if (topWindow.windowLevel!=UIWindowLevelNormal) {
            NSArray *windows=[[UIApplication sharedApplication]windows];
            for (topWindow in windows) {
                if (topWindow.windowLevel==UIWindowLevelNormal) {
                    break;
                }
            }
        }
        UIView *rootView=[[topWindow subviews]firstObject];
        id nextResponder=[rootView nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            result=nextResponder;
        } else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController!=nil) {
            result=topWindow.rootViewController;
        } else {
            NSAssert(NO, @"ShareKit: Could not find a root view controller.  You can assign one manually by calling [[SHK currentHelper] setRootViewController:YOURROOTVIEWCONTROLLER].");
        }
    return result;
}

- (void)dealloc {
    [utilityTool removeObserver:self forKeyPath:@"netWorkStatus" context:nil];
    [utilityTool stopToMonitorNetworkConnection];
}

//
//作者：里脊串 授权本站转载。
//
//项目刚启动的时候 我们一般为了快速开发 会在使用字符串的时候直接选择硬编码到代码中 比如
//
//1
//self.lblTime.text = @"1分钟前";
//但是之后 如果有国际化的需求的话 我们又会改成这样
//
//1
//self.lblTime.text = NSLocalizedString(@"one_min_ago", @"1分钟前");
//不过随着代码越来越多 不免有疏漏 所以有时我们要去搜索一些漏网之鱼 这里分享一个快捷的方法
//
//打开”Find Navigator”
//切换搜索模式到 “Find > Regular Expression”
//输入@"[^"]*[\u4E00-\u9FA5]+[^"\n]*?" (swift请去掉”@” 输入@"[^"]*[\u4E00-\u9FA5]+[^"\n]*?" 就好了)
//                                                                          看看效果
//
//                                                                          blob.png
//
//                                                                          啊哦 发现了几个漏网之鱼 :)
//
//                                                                          如果你跟我一样嫌NSLocalizedString的comment碍事 也可以用正则替换掉
//
//                                                                          Find NSLocalizedString\((@"[^\)]*?")\s*,\s*@"[^\)]*"\s*\)
//                                                                          Replace With NSLocalizedString\($1, nil\)
*/

@end
