//
//  WXErrorMsg.h
//  WXVoiceSDKDemo
//
//  Created by 宫亚东 on 13-12-26.
//  Copyright (c) 2013年 Tencent Research. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface WXErrorMsg : NSObject

+ (void)showErrorMsg:(NSString *)errorMsg onView:(UIView *)view;
+ (void)showErrorCode:(NSInteger)errorCode onView:(UIView *)view;

@end
