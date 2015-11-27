//
//  TxtDownloadModel.m
//  KTV
//
//  Created by admin on 15/11/27.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import "TxtDownloadModel.h"


@interface TxtDownloadModel () {
    NSUserDefaults *userDefaults;
}

@end
@implementation TxtDownloadModel

- (instancetype)initWithFileName:(NSString*)fileName {
    if (self=[super init]) {
        _fileName=fileName;
        userDefaults=[NSUserDefaults standardUserDefaults];
        _downloadStatus=[userDefaults integerForKey:fileName];
    }
    return self;
}

- (void)setDownloadStatus:(status)downloadStatus {
    if (downloadStatus== _downloadStatus) return;
    _downloadStatus=downloadStatus;
    [userDefaults setInteger:downloadStatus forKey:_fileName];
    [userDefaults synchronize];
}

@end
