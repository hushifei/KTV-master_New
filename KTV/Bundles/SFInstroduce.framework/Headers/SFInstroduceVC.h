//
//  SFInstroduce.h
//  SFInstroduce
//
//  Created by stevenhu on 15/11/19.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import <UIKit/UIKit.h>
//! Project version number for SFInstroduce.
FOUNDATION_EXPORT double SFInstroduceVersionNumber;

//! Project version string for SFInstroduce.
FOUNDATION_EXPORT const unsigned char SFInstroduceVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SFInstroduce/PublicHeader.h>


@interface SFInstroduceVC : UIViewController

@property (nonatomic,strong) NSArray *images;



/*
 *  初始化
 */

+(instancetype)createSFIntroduceVCEnterBlock:(void(^)())enterBlock;


/*
 *  是否应该显示版本新特性界面
 */
+(BOOL)canShowNewFeature;




@end
