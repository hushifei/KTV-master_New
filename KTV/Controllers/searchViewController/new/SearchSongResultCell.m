//
//  SearchSongResultCell.m
//  KTV
//
//  Created by stevenhu on 15/12/5.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import "SearchSongResultCell.h"
#import "UILabel+Animation.h"
#import "CommandControler.h"
#import "AppDelegate.h"
#import "Song.h"

@implementation SearchSongResultCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _opened=NO;
        [self initViewContent];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (IS_IPHONE_6P) {
        _songName.font=[UIFont systemFontOfSize:17];
        _singerName.font=[UIFont systemFontOfSize:12];
    } else if (IS_IPHONE_6) {
        _songName.font=[UIFont systemFontOfSize:15];
        _singerName.font=[UIFont systemFontOfSize:12];
    }else if (IS_IPHONE_5) {
        _songName.font=[UIFont systemFontOfSize:12];
        _singerName.font=[UIFont systemFontOfSize:10];
    } else {
        _songName.font=[UIFont systemFontOfSize:12];
        _singerName.font=[UIFont systemFontOfSize:10];
    }
    
    
    CGSize cellSize=self.contentView.frame.size;
    CGFloat height=cellSize.height-10;
    CGFloat y=(cellSize.height-height)/2;
    CGFloat x=20;
    CGRect headerRect=CGRectMake(x,y,height,height);
    _header.frame=headerRect;
    _header.layer.cornerRadius=8;
    _header.clipsToBounds=YES;
    
    _songName.frame=CGRectMake(CGRectGetMaxX(_header.frame)+20, 8, 220, 20);
    if (IS_IPHONE_5) {
        _songName.frame=CGRectMake(CGRectGetMaxX(_header.frame)+15, 8, 220, 20);
        
    } else if (IS_IPHONE_4_OR_LESS) {
        _songName.frame=CGRectMake(CGRectGetMaxX(_header.frame)+15, 8, 220, 20);
    }
    [_songName sizeToFit];
    _laungeLabel.frame=CGRectMake(CGRectGetMinX(_songName.frame), CGRectGetMaxY(_songName.frame)+5, 40, 20);
    
    
    CGSize singerSize=[_singerName.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil].size;
    _laungeLabel.text=[self.oneSong getLuangeString];
    _singerName.frame=CGRectMake(cellSize.width-singerSize.width-20, CGRectGetMaxY(_songName.frame)+5, 200, 20);
    [_singerName sizeToFit];
    _laungeLabel.font=_singerName.font;
    _laungeLabel.textColor=_singerName.textColor;
    [_laungeLabel sizeToFit];
}


- (void)initViewContent {
    
    _header=[[UIImageView alloc]initWithFrame:CGRectZero];
    
    _songName=[[UILabel alloc]initWithFrame:CGRectZero];
    [_songName setTextColor:[UIColor groupTableViewBackgroundColor]];
    
    _laungeLabel=[[UILabel alloc]initWithFrame:CGRectZero];
    
    _singerName=[[UILabel alloc]initWithFrame:CGRectZero];
    [_singerName setTextColor:[UIColor groupTableViewBackgroundColor]];
    [self.contentView addSubview:_header];
    [self.contentView addSubview:_songName];
    [self.contentView addSubview:_laungeLabel];
    [self.contentView addSubview:_singerName];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state

}

- (void)setOneSong:(Song *)oneSong {
    self.songName.text=[oneSong.songname copy];
    self.singerName.text=[oneSong.singer copy];
    self.laungeLabel.text=[oneSong.language copy];
    _oneSong=oneSong;
}

- (void)configWithObject:(id)object {
    if ([object isKindOfClass:[Song class]]){
        dispatch_sync(dispatch_get_main_queue(), ^{
            _header.image=[UIImage imageNamed:@"music_icon"];
        });
        
    }
    
}

@end
