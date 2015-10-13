//
//  DownLoadFileTool.h
//  KTV
//
//  Created by admin on 15/10/12.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM (NSUInteger,S_Actions) {
    S_Can_Donload =0,
    S_Can_ImportData,
    S_Network_Error
};
typedef void(^DownloadTxtFilesCompleted)(BOOL Completed);
@interface DownLoadFileTool : NSObject
@property(nonatomic,strong)NSArray *filePaths;
@property(nonatomic,readonly)DownloadTxtFilesCompleted completed;

+ (instancetype)instance;
- (void)downLoadTxtFile:(DownloadTxtFilesCompleted)completed;
- (void)remove_downloadedTxtFiles;
@end
