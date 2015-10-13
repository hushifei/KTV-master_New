//
//  BaseTableViewController.h
//  KTV
//
//  Created by stevenhu on 15/10/11.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"
#define PAGELIMINT 50
@interface BaseTableViewController : UITableViewController {
    NSNumber *offset;
    int pageLimint;
    int totalRowCount;
    NSMutableArray *dataList;
}
- (void)loadMJRefreshingView;
- (void)loadMoreData;
- (void)loadNewData;
- (void)initializeTableContent;
@end
