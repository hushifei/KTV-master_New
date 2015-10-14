//
//  SearchResultCell.h
//  KTV
//
//  Created by admin on 15/10/14.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Singer;
typedef NS_ENUM(NSUInteger,SRC_Type) {
    SRC_Singer,
    SRC_Song
};
@interface SearchResultCell : UITableViewCell
- (void)config:(SRC_Type)type_flag withSinger:(nullable Singer*)singer;
@end
