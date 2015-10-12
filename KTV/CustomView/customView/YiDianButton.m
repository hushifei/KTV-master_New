//
//  YiDianButton.m
//  KTV
//
//  Created by stevenhu on 15/10/11.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import "YiDianButton.h"

@implementation YiDianButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        self.frame=CGRectMake(0, 0, 40, 40);
        [self setTitle:NSLocalizedString(@"selected", nil) forState:UIControlStateNormal];
        UIImage *image=[UIImage imageNamed:@"yidian"];
        [self setImage:image  forState:UIControlStateNormal];
        self.titleLabel.font=[UIFont systemFontOfSize:10];
        self.titleEdgeInsets=UIEdgeInsetsMake(5, -35, -20, 0);
    }
    return self;
}
@end
