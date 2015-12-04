//
//  XZMCoreNewFeatureVC.h
//  XZMCoreNewFeatureDemo
//
//  Created by stevenhu on 15/11/26.
//  Copyright © 2015年 stevenhu .new. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#define KScreenW [UIScreen mainScreen].bounds.size.width
#define KScreenH [UIScreen mainScreen].bounds.size.height

@interface XZMCoreNewFeatureVC : UIViewController

/** 进入首页按钮 */
@property (nonatomic,weak) UIButton *enterButton;
/** 进入首页演示按钮 */
@property (nonatomic,weak) UIButton *demoEnterButton;

/** 创建普通滚动图片新特性界面
 *  @param imageNames 图片名数组
 *  @param enterBlock 进入主页面的回调
 *  @param configurationBlock 配置回调
 */
+ (instancetype)newFeatureVCWithImageNames:(NSArray *)imageNames enterBlock:(void(^)())enterBlock configuration:(void (^)(UIButton *enterButton,UIButton *demoButton))configurationBlock;


/** 创建视频新特性界面
 *  @param URL 视频路径
 *  @param enterBlock 进入主页面的回调
 *  @param configurationBlock 配置回调
 */
+ (instancetype)newFeatureVCWithPlayerURL:(NSURL *)URL enterBlock:(void(^)())enterBlock configuration:(void (^)(AVPlayerLayer *playerLayer))configurationBlock;

/*
 *  是否应该显示版本新特性界面
 */
+ (BOOL)canShowNewFeature;

@end