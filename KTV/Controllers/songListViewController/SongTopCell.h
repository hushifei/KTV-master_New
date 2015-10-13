//
//  SongTopCell.h
//  KTV
//
//  Created by stevenhu on 15/4/24.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
@interface SongTopCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *numberStr;
@property (weak, nonatomic) IBOutlet UILabel *songName;
@property (nonatomic,assign)BOOL opened;
@property (weak,nonatomic)UIBarButtonItem *buttonitem;
@property (weak, nonatomic) IBOutlet UIImageView *sanjiaoxing;
@property(nonatomic,weak)Song *oneSong;
@property (weak, nonatomic) IBOutlet UIButton *selecteBtn;

- (IBAction)addSong:(id)sender;
@end
