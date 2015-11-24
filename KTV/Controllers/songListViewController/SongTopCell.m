//
//  SongTopCell.m
//  KTV
//
//  Created by stevenhu on 15/4/24.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import "SongTopCell.h"
#import "UILabel+Animation.h"
#import "CommandControler.h"
#import "AppDelegate.h"
@implementation SongTopCell

- (void)awakeFromNib {
    _opened=NO;
    [self.selecteBtn setTitle:NSLocalizedString(@"select", nil) forState:UIControlStateNormal];
    //    [self.selecteBtn setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];    
    // Configure the view for the selected state
}


- (IBAction)addSong:(id)sender {
    //没有检查是否添加成功
    if ([Utility instanceShare].netWorkStatus) {
        if (self.buttonitem && self.oneSong.number.length > 0) {
            CommandControler *cmd=[[CommandControler alloc]init];
            [cmd sendCmd_Diange:self.oneSong.number completed:^(BOOL completed, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.numberStr shakeAndFlyAnimationToView:self.buttonitem];
                });
            }];
        }
    } else {
        [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
    }
}

- (void)setOneSong:(Song *)oneSong {
    self.songName.text=[oneSong.songname copy];
    _oneSong=oneSong;
}

@end
