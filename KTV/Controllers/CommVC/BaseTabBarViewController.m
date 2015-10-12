//
//  BaseTabBarViewController.m
//  KTV
//
//  Created by stevenhu on 15/10/11.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import "BaseTabBarViewController.h"
#import "UINavigationBar+customBar.h"
#import "MainViewController.h"
#import "SoundViewController.h"
#import "SettingViewController.h"
#import "BokongView.h"
#import "UIImage+Utility.h"
#import "BaseNavigationController.h"


@interface BaseTabBarViewController ()

@end

@implementation BaseTabBarViewController

- (void)viewDidLoad {
    

    
    MainViewController *mainVC=[[MainViewController alloc]init];
    mainVC.title=NSLocalizedString(@"mainvctitle", nil);
    BaseNavigationController *navC1=[[BaseNavigationController alloc]initWithRootViewController:mainVC];
    
    SoundViewController *soundVC=[[SoundViewController alloc]init];
    soundVC.title=NSLocalizedString(@"controller", nil);
    
    BaseNavigationController *navC2=[[BaseNavigationController alloc]initWithRootViewController:soundVC];
    
    
    SettingViewController *setVC=[[SettingViewController alloc]init];
    setVC.title=NSLocalizedString(@"setting", nil);
    
    BaseNavigationController *navC3=[[BaseNavigationController alloc]initWithRootViewController:setVC];
    self.viewControllers=@[navC1,navC2,navC3];
    
    
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor whiteColor], NSForegroundColorAttributeName,
                                                       nil] forState:UIControlStateNormal];
    UIColor *titleHighlightedColor = [UIColor orangeColor];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       titleHighlightedColor, NSForegroundColorAttributeName,
                                                       nil] forState:UIControlStateSelected];
    
    //设置图片
    navC1.tabBarItem.image = [[UIImage imageNamed:@"kege"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navC1.tabBarItem.selectedImage=[[UIImage imageNamed:@"kege_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    navC2.tabBarItem.image = [[UIImage imageNamed:@"shenkong"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navC2.tabBarItem.selectedImage = [[UIImage imageNamed:@"shenkong_seleted"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    navC3.tabBarItem.image = [[UIImage imageNamed:@"setting"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navC3.tabBarItem.selectedImage = [[UIImage imageNamed:@"setting_selected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
