//
//  CommandControler.h
//  KTV
//
//  Created by stevenhu on 15/6/3.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "BBBadgeBarButtonItem.h"
@interface CommandControler : NSObject
typedef void(^sendCompleted)(BOOL completed,NSError *error);
typedef void(^yiDianCompleted)(BOOL completed,NSArray *list);


- (void)clearCacheData;

- (void)sendCmd_FUWU:(sendCompleted)completed;//服务
//气氛(1,喝彩 2，倒彩 3，明亮 4，柔和 5 动感 6 开关)
- (void)sendCmd_qiFen:(int)value completed:(sendCompleted)completed;
//祝福文字
- (void)sendCmd_zhuFuWithWord:(NSString*)value  completed:(sendCompleted)completed;
//祝福（图片）(最大512*512)数据流
- (void)sendCmd_zhuFuWithPicture:(UIImage*)image  completed:(sendCompleted)completed;
//静音/放音
- (void)sendCmd_mute_unmute:(sendCompleted)completed;
//音量(-+)
- (void)sendCmd_soundAdjust:(NSNumber*)value completed:(sendCompleted)completed;
//调音(1麦克风 2 音乐 3 功放 4音调 ) & value
- (void)sendCmd_yingDiaoAdjustToObject:(int)who value:(NSNumber*)value  completed:(sendCompleted)completed;
//切歌
- (void)sendCmd_switchSong:(sendCompleted)completed;
//重唱
- (void)sendCmd_rePlay:(sendCompleted)completed;
//暂停/播放
- (void)sendCmd_stopPlay:(sendCompleted)completed;
//原唱/伴唱
- (void)sendCmd_yuanChang_pangChang:(sendCompleted)completed;
//获取已点歌单
- (void)sendCmd_get_yiDianList:(yiDianCompleted)completed;
//删除已点
- (void)sendCmd_remove_yidian:(NSString*)value completed:(sendCompleted)completed;
//已点打乱
- (void)sendCmd_yiDianDaluang:(sendCompleted)completed;
//已点移到顶
- (void)sendCmd_moveSongToTop:(NSString*)order completed:(sendCompleted)completed;
//已点还原
- (void)sendCmd_yiDianResume:(sendCompleted)completed;
//点歌
- (void)sendCmd_Diange:(NSString*)number completed:(sendCompleted)completed;
//点歌(顶)
- (void)sendCmd_DiangeToTop:(NSString*)number completed:(sendCompleted)completed;
//推送视频(音频)
- (void)sendCmd_pushVideoAudio:(NSData*)data completed:(sendCompleted)completed;
//推送图片
- (void)sendCmd_pushPicture:(UIImage*)image completed:(sendCompleted)completed;
// 重开
- (void)sendCmd_restartDevice:(sendCompleted)completed;
// 关机
- (void)sendCmd_shutdownDevice:(sendCompleted)completed;

// badge
+ (void)setYidianBadgeWidth:(BBBadgeBarButtonItem*)item completed:(sendCompleted)completed;


@end
