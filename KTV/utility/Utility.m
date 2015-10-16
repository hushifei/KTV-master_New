//
//  Utility.m
//  ZZKTV
//
//  Created by stevenhu on 15-3-22.
//  Copyright (c) 2015年 zz. All rights reserved.
//
//fmdb
#import "Utility.h"
#import "NSString+Utility.h"
#import "FMDB.h"
#define DBPATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"DB.sqlite"]

#define COMM_URLStr @"http://192.168.43.1:8080/puze/?cmd=0x01&filename="
#define DOCUMENTPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
@interface Utility() {
    NSString* savePath_TxtDir;
    int hasCount;
    NSTimer *networkTimer;
    NSURLSession *shareSession;
    BOOL netWorkStatus;
}
@end
static Utility *shareInstance=nil;
@implementation Utility
+ (instancetype)instanceShare {
    static  dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!shareInstance) {
            shareInstance=[[self alloc]init];
        }
    });
    return shareInstance;
}

- (instancetype)init {
    static  dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self checkIphoneDevice];
        shareSession=[NSURLSession sharedSession];
        networkTimer=[NSTimer scheduledTimerWithTimeInterval:8 target:shareInstance selector:@selector(checkNetworkStatus) userInfo:nil repeats:YES];
       shareInstance= [super init];
    });
    return shareInstance;
}

- (void)checkIphoneDevice {
    if (IS_IPHONE_4_OR_LESS) {
        _myIphoneModel= isiPhone4s;
    } else if (IS_IPHONE_5) {
        _myIphoneModel =isiphone5s;
    } else if (IS_IPHONE_6) {
        _myIphoneModel =isiphone6;
    } else if (IS_IPHONE_6P) {
        _myIphoneModel =isiphone6p;
    } else {
        _myIphoneModel= unkownPhone;
    }
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone  {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance=[super allocWithZone:zone];
    });
    return shareInstance;
}


+ (float)user_iosVersion {
    return [[UIDevice currentDevice].systemVersion floatValue];
}

+ (NSString *)chineseToPinYin:(NSString *)string {
    NSMutableString *muString=[string mutableCopy];
    CFStringTransform((CFMutableStringRef)muString, NULL, kCFStringTransformToLatin, NO);
    CFStringTransform((CFMutableStringRef)muString, NULL, kCFStringTransformStripDiacritics, NO);
    return [muString copy];
}

+ (BOOL)isIncludeChineseInString:(NSString*)str {
    for (int i=0; i<str.length; i++) {
        unichar ch = [str characterAtIndex:i];
        if (0x4e00 < ch  && ch < 0x9fff) {
            return true;
        }
    }
    return false;
}

+ (NSString*)shouZiFu:(NSString*)string {
    return  [[Utility chineseToPinYin:string]substringToIndex:1];
}

- (void)networkStatus:(void(^)(BOOL isSecucess))block {
    NSURL *url=[NSURL URLWithString:@"http://192.168.43.1:8080/puze/"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:2];
    NSURLSessionDataTask *dataTask =[shareSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse*)response;
        NSInteger statuscode=httpResponse.statusCode;
        if (error==nil) {
            if (statuscode ==200 ) {
                [self setValue:[NSNumber numberWithBool:YES] forKey:@"netWorkStatus"];
            } else {
                [self setValue:[NSNumber numberWithBool:NO] forKey:@"netWorkStatus"];
            }
        } else {
            [self setValue:[NSNumber numberWithBool:NO] forKey:@"netWorkStatus"];
        }
        if (block) {
            block(self.netWorkStatus);
        }
    }];
    [dataTask resume];
}

- (void)checkNetworkStatus {
    NSURL *url=[NSURL URLWithString:@"http://192.168.43.1:8080/puze/"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:2];
    NSURLSessionDataTask *dataTask = [shareSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error==nil) {
            if ([self httpsStatuCode:response] ==200 ) {
                [self setValue:[NSNumber numberWithBool:YES] forKey:@"netWorkStatus"];
            } else {
                [self setValue:[NSNumber numberWithBool:NO] forKey:@"netWorkStatus"];
                NSLog(@"network connection error");
            }
        } else {
            [self setValue:[NSNumber numberWithBool:NO] forKey:@"netWorkStatus"];
            NSLog(@"network connection error");
        }
//        
//        static int a=0;
//        if (a>=4) {
//            [self setValue:[NSNumber numberWithBool:YES] forKey:@"netWorkStatus"];
//        }
//        a++;
    }];
    [dataTask resume];
}

- (BOOL)netWorkStatus {
    return netWorkStatus;
}

// 定义成方法方便多个label调用 增加代码的复用性
+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(320, 8000)//限制最大的宽度和高度
                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin//采用换行模式
                                    attributes:@{NSFontAttributeName: font}//传人的字体字典
                                       context:nil];
    
    return rect.size;
}

+ (BOOL)isChineseLanguge {
    if ([[[NSLocale preferredLanguages]objectAtIndex:0] isEqualToString:@"zh-Hans"]) {
        return YES;
    }
    return NO;
}

- (NSInteger)httpsStatuCode:(NSURLResponse*)response {
    NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse*)response;
   return httpResponse.statusCode;
}

- (void)dealloc {
    [networkTimer invalidate];
    networkTimer=nil;
}
@end

