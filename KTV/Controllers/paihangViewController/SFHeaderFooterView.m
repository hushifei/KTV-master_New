//
//  SFHeaderFooterView.m
//  KTV
//
//  Created by admin on 15/10/20.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import "SFHeaderFooterView.h"
#define SESSIONHEIGHT 46.0f

@interface SFHeaderFooterView () {
    Song *song;
}

@end

@implementation SFHeaderFooterView


- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier song:(Song *)onSong {
    if (self=[self initWithReuseIdentifier:reuseIdentifier]) {
        if (onSong) {
            song=onSong;
        }
        [self initViewContent];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _hotestImageView.frame=CGRectMake(10,(SESSIONHEIGHT-1-30)/2, 30, 30);
    _numberLinelabel.frame=_hotestImageView.bounds;
    
}

- (void)initViewContent {
    _hotestImageView=[UIImageView new];
    [self addSubview:_hotestImageView];

    _numberLinelabel=[UILabel new];
    _numberLinelabel.font=[UIFont fontWithName:@"DIN Condensed" size:18];
    _numberLinelabel.textColor = [UIColor whiteColor];
    [_numberLinelabel setFont:[UIFont systemFontOfSize:14]];
    _numberLinelabel.textAlignment = NSTextAlignmentCenter;
    [_hotestImageView addSubview:_numberLinelabel];
    
    _songlabel=[UILabel new];
    _songlabel.textColor = [UIColor groupTableViewBackgroundColor];
    [_songlabel setFont:[UIFont systemFontOfSize:14]];
    [_songlabel sizeToFit];
    _songlabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_songlabel];

    _singerlabel=[UILabel new];
    [_singerlabel setFont:[UIFont italicSystemFontOfSize:13]];
    _singerlabel.textColor = [UIColor grayColor];
    _singerlabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_singerlabel];

    
    _lineView=[UIView new];
   _lineView.backgroundColor = [UIColor colorWithRed:0.50196081399917603 green:0.0 blue:0.25098040699958801 alpha:1.0f];
    [self addSubview:_lineView];

    
    _selectBtn=[UIButton new];
    [_selectBtn setImage:[UIImage imageNamed:@"diange_icon"] forState:UIControlStateNormal];
    [_selectBtn setTitle:NSLocalizedString(@"select", nil) forState:UIControlStateNormal];
    _selectBtn.titleLabel.font=[UIFont systemFontOfSize:12];
    [_selectBtn addTarget:self action:@selector(addSongToHost:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_selectBtn];
     
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
//    CGFloat btnWidth=self.view.bounds.size.width;
//    button.frame = CGRectMake(0, 0, btnWidth,SESSIONHEIGHT-1);
//    [button addTarget:self action:@selector(showChild:) forControlEvents:UIControlEventTouchUpInside];
//    button.tag = 200 + section;
    
//    UIImageView *hotestImageView=[[UIImageView alloc]initWithFrame:CGRectMake(10,(SESSIONHEIGHT-1-30)/2, 30, 30)];
//    hotestImageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"paihang_flag%d",(int)(section+7)%7]];
//    [button addSubview:hotestImageView];
//    
//    UILabel *numberlabel=[[UILabel alloc] initWithFrame:hotestImageView.bounds];
//    numberlabel.text =[NSString stringWithFormat:@"%02d",(int)section+1];
//    numberlabel.font=[UIFont fontWithName:@"DIN Condensed" size:18];
//    numberlabel.textColor = [UIColor whiteColor];
//    [numberlabel setFont:[UIFont systemFontOfSize:14]];
//    numberlabel.textAlignment = NSTextAlignmentCenter;
//    [hotestImageView addSubview:numberlabel];
//    
//    
//    UILabel *songlabel=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(numberlabel.frame)+40,5,button.bounds.size.width-CGRectGetMaxX(numberlabel.frame)-20, 20)];
//    songlabel.text =oneSong.songname;
//    songlabel.textColor = [UIColor groupTableViewBackgroundColor];
//    [songlabel setFont:[UIFont systemFontOfSize:14]];
//    [songlabel sizeToFit];
//    songlabel.textAlignment = NSTextAlignmentCenter;
//    [button addSubview:songlabel];
//    
//    
//    UILabel *singerlabel=[[UILabel alloc] initWithFrame:CGRectMake(songlabel.frame.origin.x+30,CGRectGetMaxY(songlabel.frame)+5,100, 20)];
//    singerlabel.text =oneSong.singer;
//    [singerlabel setFont:[UIFont italicSystemFontOfSize:13]];
//    singerlabel.textColor = [UIColor grayColor];
//    singerlabel.textAlignment = NSTextAlignmentCenter;
//    [button addSubview:singerlabel];
//    
//    
//    UILabel *labelLine = [[UILabel alloc] initWithFrame:CGRectMake(0, SESSIONHEIGHT-1, btnWidth, 1)];
//    labelLine.backgroundColor = [UIColor colorWithRed:0.50196081399917603 green:0.0 blue:0.25098040699958801 alpha:1.0f];
//    [button addSubview:labelLine];
//    
//    UIImageView *selectedBtnBg=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-80, (SESSIONHEIGHT-30)/2, 50, 22)];
//    UIButton *selectedBtn=[[UIButton alloc]initWithFrame:selectedBtnBg.bounds];
//    selectedBtnBg.image=[UIImage imageNamed:@"diange_icon"];
//    //    [selectedBtn setImage:[UIImage imageNamed:@"diange_icon"] forState:UIControlStateNormal];
//    [selectedBtn setTitle:NSLocalizedString(@"select", nil) forState:UIControlStateNormal];
//    selectedBtn.titleLabel.font=[UIFont systemFontOfSize:12];
//    selectedBtn.tag=section;
//    [selectedBtn addTarget:selectedBtn action:@selector(addSongToHost:) forControlEvents:UIControlEventTouchUpInside];
//    selectedBtnBg.userInteractionEnabled=YES;
//    [selectedBtnBg addSubview:selectedBtn];
//    [button addSubview:selectedBtnBg];
//    UIImageView *iamgeView=[[UIImageView alloc]init];
//    iamgeView.frame=CGRectMake(numberlabel.center.x, SESSIONHEIGHT-9, 20, 9);
//    if (section == ClickButtonCount) {
//        UIImage *image=[UIImage imageNamed:@"brt"];
//        iamgeView.image=image;
//        iamgeView.hidden=NO;
//        labelLine.hidden=YES;
//    } else {
//        iamgeView.hidden=YES;
//        labelLine.hidden=NO;
//        //        UIImage *image=[UIImage imageNamed:@"downAccessory"];
//        //        iamgeView.image=image;
//    }
//    [button addSubview:iamgeView];
}
@end