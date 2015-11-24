//
//  SearchResultCell.h
//  KTV
//
//  Created by admin on 15/10/14.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SearchResultCell : UITableViewCell
@property(nonatomic,strong)UIImageView * _Nullable  header;
@property(nonatomic,strong)UILabel * _Nullable titleLabel;
- (void)configWithObject:(nonnull id)object;
@end
