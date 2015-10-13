//
//  DataMananager.h
//  KTV
//
//  Created by admin on 15/10/12.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
typedef void(^DataImportCompleted)(BOOL Completed);
@interface DataMananager : NSObject
@property (nonatomic,readonly)FMDatabase *db;
@property(nonatomic,readonly)DataImportCompleted completed;
+ (instancetype)instanceShare;
- (void)addIntoDataSourceWithFileNames:(NSArray*)fileNames completed:(DataImportCompleted)completed;
- (int)rowCountWithStatment:(NSString*)statment;
- (void)closeDB;
@end
