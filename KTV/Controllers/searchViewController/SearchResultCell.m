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
#import "Song.h"
#define COMMANDURLHEADER_PIC @"http://192.168.43.1:8080/puze?cmd=0x02&filename="
@interface SearchResultCell() {

}
@end
@implementation SearchResultCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier ]) {
        _header=[[UIImageView alloc]initWithFrame:CGRectZero];
        _titleLabel=[[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.font=[UIFont systemFontOfSize:14];
        _titleLabel.textColor=[UIColor groupTableViewBackgroundColor];
        [self addSubview:_header];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGFloat height=rect.size.height-20;
    CGFloat y=(rect.size.height-height)/2;
    CGFloat x=rect.origin.x+20;
    CGRect headerRect=CGRectMake(x,y,height,height);
    _header.frame=headerRect;
    _header.layer.cornerRadius=8;
    _header.clipsToBounds=YES;
    CGFloat titleWidth=rect.size.width-CGRectGetMaxX(_header.frame)-80;
    CGFloat titleX=CGRectGetMaxX(_header.frame)+40;
    _titleLabel.frame=CGRectMake(titleX, y,titleWidth,height);
    [super drawRect:rect];
}

- (void)configWithObject:(nonnull id)object {
    if (object==nil) return;
    if ([object isKindOfClass:[Singer class]]) {
        Singer *oneSinger=(Singer*)object;
        dispatch_sync(dispatch_get_main_queue(), ^{
            _titleLabel.text=oneSinger.singer;
        });
        NSString *urlStr=[[COMMANDURLHEADER_PIC stringByAppendingString:oneSinger.singer]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        if ([Utility instanceShare].netWorkStatus) {
            [_header sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"Default_Header"]];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                _header.image=[UIImage imageNamed:@"Default_Header"];
            });
        }
    } else if ([object isKindOfClass:[Song class]]){
        dispatch_sync(dispatch_get_main_queue(), ^{
            _header.image=[UIImage imageNamed:@"music_icon"];
            _titleLabel.text=[(Song*)object songname];
        });
        
    }
    
}

@end
