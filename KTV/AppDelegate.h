//
//  AppDelegate.h
//  KTV
//
//  Created by stevenhu on 15/4/17.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTabBarViewController.h"
typedef NS_ENUM(NSUInteger,ViewType) {
    Show_HUD = 0,
    Show_Alert
};

@interface AppDelegate : UIResponder <UIApplicationDelegate,UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BaseTabBarViewController *tabVC;

- (void)showMessageTitle:(NSString*)title message:(NSString*)message showType:(ViewType)type;
@end

/*
 --- 已点切歌放到导航栏
*/


