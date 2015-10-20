//
//  paiHangBottomCell.h
//  KTV
//
//  Created by admin on 15/10/20.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import "BottomCellActionsDelegate.h"
@interface paiHangBottomCell : UITableViewCell
@property(nonatomic,weak)Song *oneSong;
@property(nonatomic,weak)id<BottomCellActionsDelegate> delegate;

@end
