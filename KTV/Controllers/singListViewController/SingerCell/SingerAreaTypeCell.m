//
//  SingerTypeCell.m
//  KTV
//
//  Created by stevenhu on 15/4/21.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//
#import "SingerAreaTypeCell.h"
@interface SingerAreaTypeCell () {
    NSOperationQueue *queue;
}

@end

@implementation SingerAreaTypeCell

- (void)awakeFromNib {
    _headImageV.layer.cornerRadius=10;
    _headImageV.clipsToBounds=YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
//DeviceRankNoLikeIcon

@end
