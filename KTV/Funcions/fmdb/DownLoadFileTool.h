//
//  DownLoadFileTool.h
//  KTV
//
//  Created by admin on 15/10/12.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^DownloadTxtFilesCompleted)(BOOL Completed);
@interface DownLoadFileTool : NSObject
@property(nonatomic,strong)NSArray *filePaths;
@property(nonatomic,readonly)DownloadTxtFilesCompleted completed;
- (void)downLoadTxtFile:(DownloadTxtFilesCompleted)completed;
- (void)remove_downloadedTxtFiles;
//获取数据版本
- (void)isNeedToUpdate_Database_version:(void(^)(BOOL canUpdate))update;
@end
