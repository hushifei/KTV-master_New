//
//  WXErrorMsg.m
//  WXVoiceSDKDemo
//
//  Created by 宫亚东 on 13-12-26.
//  Copyright (c) 2013年 Tencent Research. All rights reserved.
//

#import "WXErrorMsg.h"
#import "WXMsgView.h"
#import "WXImageSearch.h"
@implementation WXErrorMsg

+ (void)showErrorMsg:(NSString *)errorMsg onView:(UIView *)view{
    WXMsgView *msgView = [[WXMsgView alloc] initWithFrame:view.bounds];
    msgView.msgLabel.text = errorMsg;
    [view addSubview:msgView];
}


+ (void)showErrorCode:(NSInteger)errorCode onView:(UIView *)view{
    WXMsgView *msgView = [[WXMsgView alloc] initWithFrame:view.bounds];
    NSString *str;
    switch (errorCode) {
        case WXImgErrorOfNotImage:
            str = @"没有图片";
            break;
        case WXErrorOfNoNetWork:
            str = @"没有网络";
            break;
        case WXErrorOfAppIDError:
            str = @"APPID问题";
            break;
        case WXErrorOfQuotaExhaust:
            str = @"使用次数超限";
            break;
        case WXErrorOfTimeOut:
            str = @"超时";
            break;
        default:
            str = [NSString stringWithFormat:@"错误码%ld",(long)errorCode];
            break;
    }
    
    msgView.msgLabel.text = str;
    [view addSubview:msgView];
}

@end
