//
//  SearchResultCell.h
//  KTV
//
//  Created by admin on 15/10/14.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Singer;
@interface SearchResultCell : UITableViewCell

@property(nonatomic,strong)UIImageView *header;
@property(nonatomic,strong)UILabel *titleLabel;
- (void)configWithObject:(Singer*)object;
@end
