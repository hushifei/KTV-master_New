//
//  DownLoadFileTool.h
//  KTV
//
//  Created by admin on 15/10/12.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TxtDownloadModel.h"
@class DownLoadFileTool;
@protocol SFdownloadImportDelegate <NSObject>
- (void)startingDownload:(DownLoadFileTool*)downloadFileTool model:(TxtDownloadModel*)model;
- (void)finishedDownload:(DownLoadFileTool*)downloadFileTool model:(TxtDownloadModel*)model;
- (void)allFilesDownloaded:(DownLoadFileTool*)downloadFileTool model:(TxtDownloadModel*)model;
- (void)startingImportData:(DownLoadFileTool*)downloadFileTool model:(TxtDownloadModel*)model;
- (void)finishedImportData:(DownLoadFileTool*)downloadFileTool model:(TxtDownloadModel*)model;
- (void)allDataImported:(DownLoadFileTool*)downloadFileTool model:(TxtDownloadModel*)model;
@end


typedef NS_ENUM (NSUInteger,S_Actions) {
    S_Can_Donload =0,
    S_Can_ImportData,
    S_Network_Error
};
typedef void(^DownloadTxtFilesCompleted)(BOOL Completed,NSError *error);
@interface DownLoadFileTool : NSObject
@property(nonatomic,strong)NSArray *filePaths;
@property(nonatomic,readonly)DownloadTxtFilesCompleted completed;

+ (instancetype)instance;
- (void)downLoadTxtFile:(DownloadTxtFilesCompleted)completed;
- (void)downloadTxtFiles:(NSArray *)fileNames completionBlock:(void (^)(BOOL isOk))completionBlock;

- (void)remove_downloadedTxtFiles;
@end
