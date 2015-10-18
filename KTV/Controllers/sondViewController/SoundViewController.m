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
        
//    // keyboard
//    sendInput=[[UITextField alloc]init];
//    CGRect sendRect=CGRectMake(0, 0, 200, 40);
//    sendRect.origin.x=4;
//    sendRect.origin.y=3;
//    sendRect.size.width-=8;
//    sendRect.size.height-=6;
//    sendInput.frame=sendRect;
//    sendInput.layer.borderWidth=1;
//    sendInput.backgroundColor=[UIColor whiteColor];
//    sendInput.layer.borderColor=[UIColor groupTableViewBackgroundColor].CGColor;
//    sendInput.placeholder=@"发送内容";
//    sendInput.tintColor=[UIColor whiteColor];
//    sendInput.layer.cornerRadius=8;
//    UIBarButtonItem *sendInputItem=[[UIBarButtonItem alloc]initWithCustomView:sendInput];
//    UIBarButtonItem *flex0=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:(UIBarButtonSystemItemFlexibleSpace) target:nil action:nil];
//    
//    switchBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
//    switchBtn.frame=CGRectMake(0, 0, 40, 40);
//    [switchBtn setTitle:@"切换" forState:UIControlStateNormal];
//    [switchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    UIBarButtonItem *switchItem=[[UIBarButtonItem alloc]initWithCustomView:switchBtn];
//    
//    sendBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
//    sendBtn.frame=CGRectMake(0, 0, 40, 40);
//    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
//    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    UIBarButtonItem *sendItem=[[UIBarButtonItem alloc]initWithCustomView:sendBtn];
//    self.toolbarItems=@[flex0,sendInputItem,flex0,switchItem,flex0,sendItem];
//    
//    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
