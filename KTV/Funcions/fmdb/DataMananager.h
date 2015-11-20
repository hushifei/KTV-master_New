//
//  DataMananager.h
//  KTV
//
//  Created by admin on 15/10/12.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
//typedef NS_ENUM(NSUInteger,DBType) {
//    Work_DB=0,
//    Demo_DB=1
//};

typedef void(^DataImportCompleted)(BOOL Completed);
@interface DataMananager : NSObject
@property (nonatomic,readonly)FMDatabase *db;
@property(nonatomic,readonly)DataImportCompleted completed;
+ (instancetype)instanceShare;
- (void)addIntoDataSourceWithFileNames:(NSArray*)fileNames completed:(DataImportCompleted)completed;
- (int)rowCountWithStatment:(NSString*)statment;
// 判断是否存在表
- (BOOL)isTableOK:(NSString *)tableName;
// 获得表的数据条数
- (int)getTableItemCount:(NSString *)tableName;
// 清除表-清数据
- (BOOL)eraseTable:(NSString *)tableName;
- (BOOL)openDB;
- (BOOL)closeDB;
- (BOOL)databaseAlready;
- (void)setDatabaseAlready:(BOOL)already;
@end
