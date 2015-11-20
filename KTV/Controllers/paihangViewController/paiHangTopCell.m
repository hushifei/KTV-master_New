//
//  paiHangViewCell.m
//  KTV
//
//  Created by stevenhu on 15/4/26.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import "paiHangTopCell.h"
#import "UILabel+Animation.h"
#import "CommandControler.h"
#import "AppDelegate.h"
@implementation paiHangTopCell

- (void)awakeFromNib {
    [_songName sizeToFit];
   [_singer sizeToFit];
        _opened=NO;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (IBAction)addSong:(id)sender {
    if ([Utility instanceShare].netWorkStatus) {
        if (self.buttonitem && self.oneSong.number.length > 0) {
            CommandControler *cmd=[[CommandControler alloc]init];
            [cmd sendCmd_Diange:_oneSong.number completed:^(BOOL completed, NSError *error) {
                if (completed) {
                    [self.numberStr shakeAndFlyAnimationToView:self.buttonitem];
                }
            }];
        }
    } else {
        [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
    }
}

- (void)setOneSong:(Song *)oneSong {
    self.songName.text=[oneSong.songname copy];
    self.singer.text=[oneSong.singer copy];
    _oneSong=oneSong;
}
@end
