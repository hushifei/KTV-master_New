//
//  newSongTopCell.h
//  KTV
//
//  Created by stevenhu on 15/12/5.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
@interface newSongTopCell : UITableViewCell
@property (strong, nonatomic) UILabel *numberStr;
@property (strong, nonatomic) UIImageView *flagImageViw;

@property (strong, nonatomic) UILabel *songName;
@property (strong, nonatomic) UIImageView *sanjiaoxing;
@property (strong, nonatomic) UILabel *singerName;
@property (strong,nonatomic)  UILabel *laungeLabel;
@property (strong, nonatomic) UIButton *selecteBtn;
@property (strong, nonatomic) UILabel *line;

@property (nonatomic,assign)BOOL opened;
@property (weak,nonatomic)UIBarButtonItem *buttonitem;
@property(nonatomic,weak)Song *oneSong;

- (void)addSong:(id)sender;
@end
