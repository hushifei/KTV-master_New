//
//  TxtDownloadModel.h
//  KTV
//
//  Created by admin on 15/11/27.
//  Copyright © 2015年 stevenhu. All rights reserved.
//
#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger,handelStatus) {
    TxtDownloadModel_original = 0 ,
    TxtDownloadModel_starting,
    TxtDownloadModel_failed,
    TxtDownloadModel_finished
};


@interface KTVModel : NSObject
@property(nonatomic,copy)NSString *fileName;
@property(nonatomic,assign)handelStatus downloadStatus;
@property(nonatomic,copy)NSString *txtVersion;
@property(nonatomic,copy)NSString *tableVersion;

@property(nonatomic,assign)handelStatus importDataStatus;


- (instancetype)initWithFileName:(NSString*)fileName;
@end
