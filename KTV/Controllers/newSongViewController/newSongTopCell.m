//
//  newSongTopCell.m
//  KTV
//
//  Created by stevenhu on 15/12/5.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import "newSongTopCell.h"
#import "UILabel+Animation.h"
#import "CommandControler.h"
#import "AppDelegate.h"
@implementation newSongTopCell

- (void)awakeFromNib {
    // Initialization code
}

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
        _numberStr.font=[UIFont fontWithName:@"DIN Condensed" size:20];
        _songName.font=[UIFont systemFontOfSize:17];
        _singerName.font=[UIFont systemFontOfSize:12];
    } else if (IS_IPHONE_6) {
        _numberStr.font=[UIFont fontWithName:@"DIN Condensed" size:18];
        _songName.font=[UIFont systemFontOfSize:15];
        _singerName.font=[UIFont systemFontOfSize:12];
    }else if (IS_IPHONE_5) {
        _numberStr.font=[UIFont fontWithName:@"DIN Condensed" size:15];
        _songName.font=[UIFont systemFontOfSize:12];
        _singerName.font=[UIFont systemFontOfSize:10];
    } else {
        _numberStr.font=[UIFont fontWithName:@"DIN Condensed" size:15];
        _songName.font=[UIFont systemFontOfSize:12];
        _singerName.font=[UIFont systemFontOfSize:10];
    }
    
    
    CGSize cellSize=self.contentView.frame.size;
    _numberStr.frame=CGRectMake(10,(cellSize.height-20)/2, 30, 30);
    [_numberStr sizeToFit];
    _flagImageViw.frame=CGRectMake(CGRectGetMaxX(_numberStr.frame)-2, CGRectGetMinY(_numberStr.frame)-8, 20, 14);

    _songName.frame=CGRectMake(CGRectGetMaxX(_flagImageViw.frame)+20, 8, 220, 20);
    
    _selecteBtn.frame=CGRectMake(cellSize.width-70, (cellSize.height-40)/2, 60, 35);
    _sanjiaoxing.frame=CGRectMake((cellSize.width-19)/2, cellSize.height-12, 19, 11);
    _sanjiaoxing.image=[UIImage imageNamed:@"brt"];
    if (IS_IPHONE_5) {
        _flagImageViw.frame=CGRectMake(CGRectGetMaxX(_numberStr.frame)-2, CGRectGetMinY(_numberStr.frame)-8, 16, 10);
        _songName.frame=CGRectMake(CGRectGetMaxX(_flagImageViw.frame)+15, 8, 220, 20);
        _selecteBtn.frame=CGRectMake(cellSize.width-60, (cellSize.height-30)/2, 50, 25);

    } else if (IS_IPHONE_4_OR_LESS) {
        _flagImageViw.frame=CGRectMake(CGRectGetMaxX(_numberStr.frame)-2, CGRectGetMinY(_numberStr.frame)-8, 16, 10);
        _songName.frame=CGRectMake(CGRectGetMaxX(_flagImageViw.frame)+15, 8, 220, 20);
        _selecteBtn.frame=CGRectMake(cellSize.width-60, (cellSize.height-30)/2, 50, 25);
    }
    [_songName sizeToFit];
    _laungeLabel.frame=CGRectMake(CGRectGetMinX(_songName.frame), CGRectGetMaxY(_songName.frame)+5, 40, 20);
    
    
    CGSize singerSize=[_singerName.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil].size;
    _laungeLabel.text=[self.oneSong getLuangeString];
    _singerName.frame=CGRectMake(CGRectGetMinX(_selecteBtn.frame)-singerSize.width-20, CGRectGetMaxY(_songName.frame)+5, 200, 20);
//    _singerName.text=@"hu shi fei fjkla";
     [_singerName sizeToFit];
    _laungeLabel.font=_singerName.font;
    _laungeLabel.textColor=_singerName.textColor;
    [_laungeLabel sizeToFit];

//    _sanjiaoxing.hidden=YES;
    _line.frame=CGRectMake(0, cellSize.height-1, cellSize.width, 1);
    [_selecteBtn setTitle:NSLocalizedString(@"select", nil) forState:UIControlStateNormal];
    [_selecteBtn setBackgroundImage:[UIImage imageNamed:@"diange_icon"] forState:UIControlStateNormal];
}


- (void)initViewContent {
    
    _numberStr=[[UILabel alloc]initWithFrame:CGRectZero];
    [_numberStr setTextColor:[UIColor groupTableViewBackgroundColor]];
    _flagImageViw=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"New"]];
    _songName=[[UILabel alloc]initWithFrame:CGRectZero];
    [_songName setTextColor:[UIColor groupTableViewBackgroundColor]];
    
    _laungeLabel=[[UILabel alloc]initWithFrame:CGRectZero];

    _singerName=[[UILabel alloc]initWithFrame:CGRectZero];
    [_singerName setTextColor:[UIColor groupTableViewBackgroundColor]];
    _selecteBtn=[[UIButton alloc]initWithFrame:CGRectZero];
    
    [_selecteBtn addTarget:self action:@selector(addSong:) forControlEvents:UIControlEventTouchUpInside];
    _line=[[UILabel alloc]initWithFrame:CGRectZero];
    _line.backgroundColor=[UIColor colorWithRed:120/255.0 green:37/255.0 blue:53/255.0 alpha:1.0];
    _sanjiaoxing=[[UIImageView alloc]initWithFrame:CGRectZero];

    [self.contentView addSubview:_numberStr];
    [self.contentView addSubview:_flagImageViw];
    [self.contentView addSubview:_songName];
    [self.contentView addSubview:_laungeLabel];
    [self.contentView addSubview:_selecteBtn];
     [self.contentView addSubview:_singerName];
    [self.contentView addSubview:_sanjiaoxing];
    [self.contentView addSubview:_line];

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)addSong:(id)sender {
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
    self.singerName.text=[oneSong.singer copy];
//    self.laungeName.text=[oneSong.language copy];
    _oneSong=oneSong;
}
@end
