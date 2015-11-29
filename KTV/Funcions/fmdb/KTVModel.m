//
//  TxtDownloadModel.m
//  KTV
//
//  Created by admin on 15/11/27.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import "KTVModel.h"


@interface KTVModel () {
    NSUserDefaults *userDefaults;
}

@end
@implementation KTVModel

- (instancetype)initWithFileName:(NSString*)fileName {
    if (self=[super init]) {
    _fileName=fileName;
    userDefaults=[NSUserDefaults standardUserDefaults];
//    _downloadStatus=[userDefaults integerForKey:[NSString stringWithFormat:@"%@_downloadStatus",_fileName]];
//    _importDataStatus=[userDefaults integerForKey:[NSString stringWithFormat:@"%@_importDataStatus",_fileName]];
    _downloadStatus=TxtDownloadModel_original;
    _importDataStatus=TxtDownloadModel_original;
    _txtVersion=[userDefaults objectForKey:@"CURRENT_DOWNLOAD_VERSION"];
    _tableVersion=[userDefaults objectForKey:@"CURRENT_DATABASE_VERSION"];
    }
    return self;
}
//
//- (void)setDownloadStatus:(handelStatus)downloadStatus {
//    if (downloadStatus== _downloadStatus) return;
//    _downloadStatus=downloadStatus;
//    [userDefaults setInteger:downloadStatus forKey:[NSString stringWithFormat:@"%@_downloadStatus",_fileName]];
//    [userDefaults synchronize];
//}
//
//- (void)setImportDataStatus:(handelStatus)importDataStatus {
//    if (_importDataStatus== importDataStatus) return;
//    _importDataStatus=importDataStatus;
//    [userDefaults setInteger:_importDataStatus forKey:[NSString stringWithFormat:@"%@_downloadStatus",_fileName]];
//    [userDefaults synchronize];
//}

- (void)setTxtVersion:(NSString *)txtVersion {
    if (_txtVersion== txtVersion) return;
    _txtVersion=txtVersion;
    [userDefaults setObject:_txtVersion forKey:@"CURRENT_DOWNLOAD_VERSION"];
    [userDefaults synchronize];
}

- (void)setTableVersion:(NSString *)tableVersion {
    if (_tableVersion== tableVersion) return;
    _tableVersion=tableVersion;
    [userDefaults setObject:_tableVersion forKey:@"CURRENT_DATABASE_VERSION"];
    [userDefaults synchronize];
}

@end
