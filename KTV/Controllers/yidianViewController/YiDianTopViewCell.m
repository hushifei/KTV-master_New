//
//  YiDianTopViewCell.m
//  KTV
//
//  Created by stevenhu on 15/5/2.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import "YiDianTopViewCell.h"
@interface YiDianTopViewCell() {
    UILabel *play;
}
@end
@implementation YiDianTopViewCell

- (void)awakeFromNib {
    // Initialization code
    CGRect rect=_singer.frame;
    rect.origin.x=CGRectGetMinX(rect)-50;
    rect.size.height=20.0f;
    rect.origin.y=self.bounds.size.height-20.0f;
    play=[[UILabel alloc]initWithFrame:rect];
    play.text=NSLocalizedString(@"playing", nil);
    play.textColor=[UIColor blueColor];
    [self addSubview:play];
    [play sizeToFit];
    play.hidden=YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setOneSong:(Song *)oneSong {
//    NSLog(@"%@",oneSong.number);
    self.songName.text=[oneSong.songname copy];
    self.singer.text=[oneSong.singer copy];
    _oneSong=oneSong;
}

-(void)setPlayStatusToHide:(BOOL)status {
    play.hidden=status;
}

@end
