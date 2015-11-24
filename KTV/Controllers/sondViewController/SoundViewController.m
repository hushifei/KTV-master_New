//
//  SoundViewController.m
//  KTV
//
//  Created by stevenhu on 15/5/2.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import "SoundViewController.h"
#import "CommandControler.h"
#import "YiDianViewController.h"
#import "Utility.h"
@interface SoundViewController ()<UITextFieldDelegate>{
    UITextField *sendInput;
    soundView *mySoundView;
    
}
@property (nonatomic,assign) NSUInteger curve;
@property (nonatomic,assign) CGFloat time;
@end

@implementation SoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ( nil != self.navigationController ) {
        CGRect rect=self.view.frame;
        rect.size.height-=self.navigationController.navigationBar.bounds.size.height;
        mySoundView=[[soundView alloc]initWithFrame:rect];
    } else {
        mySoundView=[[soundView alloc]initWithFrame:self.view.frame];

    }
    mySoundView.delegate=self;
    [self.view addSubview:mySoundView];
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

- (void)exitShengKongView {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
