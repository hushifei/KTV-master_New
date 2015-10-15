//
//  ViewController.h
//  Table
//
//  Created by ywx272253 on 15/4/24.
//  Copyright (c) 2015年 com.huawei.hwcloud. All rights reserved.
//

#import "BaseTableViewController.h"
@class Song;
@interface SongListViewController : BaseTableViewController
@property(nonatomic,copy)NSString *singerName;
@property(nonatomic,assign)BOOL needLoadData;


-(void)setDataList:(Song*)oneSong;
@end

