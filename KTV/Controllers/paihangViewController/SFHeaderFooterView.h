//
//  SFHeaderFooterView.h
//  KTV
//
//  Created by admin on 15/10/20.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
@interface SFHeaderFooterView : UITableViewHeaderFooterView
@property(nonatomic,assign)NSInteger *sesstion;
@property(nonatomic,strong)UIImageView *hotestImageView;
@property(nonatomic,strong)UILabel *numberLinelabel;
@property(nonatomic,strong)UILabel *songlabel;
@property(nonatomic,strong)UILabel *singerlabel;
@property(nonatomic,strong)UIView *lineView;
@property(nonatomic,strong)UIButton *selectBtn;
-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier song:(Song*)onSong;
@end
