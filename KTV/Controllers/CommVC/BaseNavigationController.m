//
//  BaseNavigationController.m
//  KTV
//
//  Created by admin on 15/10/12.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import "BaseNavigationController.h"

@implementation BaseNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self=[super initWithRootViewController:rootViewController]) {
        UIImage *imagetop=[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"song_bt_bg" ofType:@"png"]]stretchableImageWithLeftCapWidth:0 topCapHeight:30];
        
        NSDictionary * navBarTitleTextAttributes =@{ NSForegroundColorAttributeName : [UIColor whiteColor]};
        [[UINavigationBar appearance] setTitleTextAttributes:navBarTitleTextAttributes];
        [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
        [self.navigationBar setBackgroundImage:imagetop forBarMetrics:UIBarMetricsDefault];

    }
    return self;
}
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
