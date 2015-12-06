//
//  SearchSongResultCell.h
//  KTV
//
//  Created by stevenhu on 15/12/5.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Song;
@interface SearchSongResultCell : UITableViewCell
@property (strong, nonatomic) UIImageView *header;

@property (strong, nonatomic) UILabel *songName;
@property (strong, nonatomic) UILabel *singerName;
@property (strong,nonatomic)  UILabel *laungeLabel;

@property (nonatomic,assign)BOOL opened;
@property (weak,nonatomic)UIBarButtonItem *buttonitem;
@property(nonatomic,weak)Song *oneSong;

- (void)configWithObject:(Song*)object;
@end
