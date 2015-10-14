//
//  SearchResultCell.m
//  KTV
//
//  Created by admin on 15/10/14.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import "SearchResultCell.h"
#import "WebImage.h"
#import "Singer.h"
#define COMMANDURLHEADER_PIC @"http://192.168.43.1:8080/puze?cmd=0x02&filename="
@interface SearchResultCell() {
    UIImageView *header;
    UILabel *titleLabel;
}
@end
@implementation SearchResultCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier ]) {
        header=[[UIImageView alloc]initWithFrame:CGRectZero];
        titleLabel=[[UILabel alloc]initWithFrame:CGRectZero];
        titleLabel.font=[UIFont systemFontOfSize:14];
        titleLabel.textColor=[UIColor groupTableViewBackgroundColor];
        [self addSubview:header];
        [self addSubview:titleLabel];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGFloat height=rect.size.height-20;
    CGFloat y=(rect.size.height-height)/2;
    CGFloat x=rect.origin.x+20;
    CGRect headerRect=CGRectMake(x,y,height,height);
    header.frame=headerRect;
    header.layer.cornerRadius=8;
    header.clipsToBounds=YES;
    CGFloat titleWidth=rect.size.width-CGRectGetMaxX(header.frame)-80;
    CGFloat titleX=CGRectGetMaxX(header.frame)+40;
    titleLabel.frame=CGRectMake(titleX, y,titleWidth,height);
    [super drawRect:rect];
}

- (void)config:(SRC_Type)type_flag withSinger:(nullable Singer*)singer {
    if (type_flag==SRC_Singer && singer) {
        NSString *urlStr=[[COMMANDURLHEADER_PIC stringByAppendingString:singer.singer]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [header sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"Default_Header"]];
    } else {
        header.image=[UIImage imageNamed:@"music_icon"];
    }
}

@end
