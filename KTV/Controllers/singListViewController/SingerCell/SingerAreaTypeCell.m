//
//  SingerTypeCell.m
//  KTV
//
//  Created by stevenhu on 15/4/21.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//
#define COMMANDURLHEADER_PIC @"http://192.168.43.1:8080/puze?cmd=0x02&filename="
#import "Utility.h"
#import "SingerAreaTypeCell.h"
#import "UIImageView+WebCache.h"
@interface SingerAreaTypeCell () {
    NSOperationQueue *queue;
}

@end

@implementation SingerAreaTypeCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
//DeviceRankNoLikeIcon
- (void)downLoadImage:(NSString *)imageName {
    if (imageName && imageName.length>0) {
        NSString *urlStr=[[COMMANDURLHEADER_PIC stringByAppendingString:imageName]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        if ([Utility instanceShare].netWorkStatus) {
            [_headImageV sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"Default_Header"]];
        } else {
            _headImageV.image=[UIImage imageNamed:@"Default_Header"];
        }
    } else {
        _headImageV.image=[UIImage imageNamed:@"music_icon"];
    }
//    self.headImageV.image=[UIImage imageNamed:@"Default_Header"];
//    NSFileManager *manager=[NSFileManager defaultManager];
//    NSString* savePath_PicDir=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadDir/Images"];
//    if (![manager fileExistsAtPath:savePath_PicDir]) {
//        [manager createDirectoryAtPath:savePath_PicDir withIntermediateDirectories:YES attributes:nil error:nil];
//    }
//    
//    NSString*  savePath_picFull = [[savePath_PicDir stringByAppendingPathComponent:imageName]stringByAppendingPathExtension:@"jpeg"];
//    if ([manager fileExistsAtPath:savePath_picFull]) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.headImageV.image=[UIImage imageWithContentsOfFile:savePath_picFull];
//        });
//        return;
//
//    }
//    
//    if (imageName.length >0) {
//        NSString *urlStr=[[COMMANDURLHEADER_PIC stringByAppendingString:imageName]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//        NSURL *downloadURL=[NSURL URLWithString:urlStr];
//        NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
//        queue=[[NSOperationQueue alloc]init];
//        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
////             NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
////                NSLog(@"%@",[res allHeaderFields]);
//            if ([data length] > 0 && connectionError == nil) {
//               NSData *scaleData=UIImageJPEGRepresentation([UIImage imageWithData:data], 0.25);
//                [scaleData writeToFile:savePath_picFull atomically:YES];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    self.headImageV.image=[UIImage imageWithData:scaleData];
//                });
//            }else if ([data length] == 0 && connectionError == nil){
//                NSLog(@"Nothing was downloaded.");
//            }else if (connectionError != nil){
//                NSLog(@"Error happened = %@",connectionError);
//            }
//        }];
//    }
}
@end
