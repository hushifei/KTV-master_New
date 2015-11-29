//
//  DownLoadFileTool.h
//  KTV
//
//  Created by admin on 15/10/12.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTVModel.h"
#import "FMDB.h"
@class DataManager;
@protocol DataManagerDelegate <NSObject>
@optional
// download
- (void)startingDownload:(DataManager*)downloadFileTool model:(KTVModel*)model;
- (void)failDownload:(DataManager*)downloadFileTool model:(KTVModel*)model;
- (void)finishedDownload:(DataManager*)downloadFileTool model:(KTVModel*)model;
- (void)tasksWillDownloading:(DataManager*)downloadFileTool;
- (void)tasksDownloaded:(DataManager*)downloadFileTool;

// import
- (void)startingImportData:(DataManager*)downloadFileTool model:(KTVModel*)model;
- (void)failImportData:(DataManager*)downloadFileTool model:(KTVModel*)model;
- (void)finishedImportData:(DataManager*)downloadFileTool model:(KTVModel*)model;
- (void)tasksWillImportData:(DataManager*)downloadFileTool;
- (void)tasksDataImported:(DataManager*)downloadFileTool;

@end

typedef NS_ENUM (NSUInteger,S_Actions) {
    S_Can_Donload =0,
    S_Can_ImportData,
    S_Network_Error
};
typedef void(^DownloadTxtFilesCompleted)(BOOL Completed,NSError *error);
@interface DataManager : NSObject
@property(nonatomic,strong)NSArray *filePaths;
@property(nonatomic,weak)id<DataManagerDelegate>delegate;
@property (nonatomic,readonly)FMDatabase *db;

+ (instancetype)instanceShare;

//download
- (void)downloadTxtFiles:(NSArray <KTVModel*>*)downloadModels delegate:(id<DataManagerDelegate>)delegate completionBlock:(void (^)(BOOL isOk,NSError *error))completionBlock;


//import
- (void)addIntoDataSourceWithModels:(NSArray<KTVModel*>*)models delegate:(id<DataManagerDelegate>)delegate;

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

@end



