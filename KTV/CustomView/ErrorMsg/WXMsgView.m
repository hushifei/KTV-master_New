//
//  WXMsgView.m
//  WXVoiceSDKDemo
//
//  Created by 宫亚东 on 13-12-26.
//  Copyright (c) 2013年 Tencent Research. All rights reserved.
//

#import "WXMsgView.h"

@implementation WXMsgView

@synthesize msgLabel = _msgLabel;
- (void)dealloc
{
    self.msgLabel = nil;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        iv.image = [UIImage imageNamed:@"error.png"];
        iv.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [self addSubview:iv];
        
        self.msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, frame.size.height/2+35, 280, 50)];
        self.msgLabel.numberOfLines = 0;
        self.msgLabel.textAlignment = NSTextAlignmentCenter;
        self.msgLabel.textColor = [UIColor whiteColor];
        self.msgLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.msgLabel];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self removeFromSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
