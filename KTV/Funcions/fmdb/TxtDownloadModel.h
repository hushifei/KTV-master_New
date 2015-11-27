//
//  TxtDownloadModel.h
//  KTV
//
//  Created by admin on 15/11/27.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger,status) {
    pauze =0,
    downloading,
    failed,
    finished
};


@interface TxtDownloadModel : NSObject
@property(nonatomic,copy)NSString *fileName;
@property(nonatomic,assign)status downloadStatus;

- (instancetype)initWithFileName:(NSString*)fileName;
@end
