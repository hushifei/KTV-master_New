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
#import "AppDelegate.h"
#import "CommandControler.h"
#import "DataMananager.h"
#define DBPATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"DB.sqlite"]
#define DOCUMENTPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
NSString * const YiDian_Update_DidChangeNotification=@"YiDian_Update_DidChangeNotification";
@interface Utility() {
    NSString* savePath_TxtDir;
    int hasCount;
    NSTimer *networkTimer;
    BOOL netWorkStatus;
}
@property(nonatomic,strong)NSURLSession *shareSession;
@end
static Utility *shareInstance=nil;
@implementation Utility
+ (instancetype)instanceShare {
    static  dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!shareInstance) {
            [DataMananager instanceShare];
            shareInstance=[[self alloc]init];
        }
    });
    return shareInstance;
}

- (instancetype)init {
    static  dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self checkIphoneDevice];
        _shareSession=[NSURLSession sharedSession];
        _serverIPAddress=[[NSUserDefaults standardUserDefaults]objectForKey:@"SERVER_IP_ADDRESS"];
//        if (_serverIPAddress==nil) {
//            [self setServerIPAddress:@"192.168.43.1"];
//
//        }
//        if (![_serverIPAddress isIpAddress])    {
//           _serverIPAddress=@"192.168.43.1";
//            //提示扫🐎；
//        }
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

- (void)setServerIPAddress:(NSString *)serverIPAddress {
    if (networkTimer) {
        [self stopToMonitorNetworkConnection];
    }
    [[NSUserDefaults standardUserDefaults]setObject:serverIPAddress forKey:@"SERVER_IP_ADDRESS"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    _serverIPAddress=serverIPAddress;
    [self starToMonitorNetowrkConnection];
}

+ (NSString*)shouZiFu:(NSString*)string {
    return  [[Utility chineseToPinYin:string]substringToIndex:1];
}

- (void)starToMonitorNetowrkConnection {
    networkTimer=[NSTimer scheduledTimerWithTimeInterval:netWorkTimeInterval target:shareInstance selector:@selector(checkNetworkStatus:) userInfo:nil repeats:YES];
}

- (void)stopToMonitorNetworkConnection {
    [networkTimer invalidate];
    networkTimer=nil;
}


- (void)checkNetworkStatusImmediately:(void(^)(BOOL isConnected,NSError *error))block {
    if (!block) return;
    if (![self.serverIPAddress isIpAddress])  {
        NSDictionary* errorMessage = [NSDictionary dictionaryWithObject:@"IP Address Error" forKey:NSLocalizedDescriptionKey];
        return block(NO,[NSError errorWithDomain:@"IP Address Error" code:999 userInfo:errorMessage]);
    }
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:8080/puze/",self.serverIPAddress]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:3];
    NSURLSessionDataTask *dataTask =[shareInstance.shareSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse*)response;
        NSInteger statuscode=httpResponse.statusCode;
        if (statuscode ==200 && error ==nil ) {
            block(YES,nil);
        } else {
            if (self.serverIPAddress && self.serverIPAddress.length>0) {
                
            }
            
            NSDictionary* errorMessage = [NSDictionary dictionaryWithObject:@"NetWork Error" forKey:NSLocalizedDescriptionKey];
            block(NO,[NSError errorWithDomain:@"SEND_COMMAND" code:999 userInfo:errorMessage]);
        }
    }];
    [dataTask resume];
}




- (void)checkNetworkStatus:(NSTimer*)oneTimer {
    if (![_serverIPAddress isIpAddress]) {
        [self setValue:[NSNumber numberWithBool:NO] forKey:@"netWorkStatus"];
        NSLog(@"server ip address is null");
        return;
    }
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:8080/puze/",self.serverIPAddress]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:2];
    NSURLSessionDataTask *dataTask = [_shareSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
         BOOL networkOk=NO;
        if ([self httpsStatuCode:response] ==200 && error==nil) {
            networkOk=YES;
            [self updateYiDianStatus];
        } else {
            networkOk=NO;
            NSLog(@"network connection error");
        }
        
        [self setValue:[NSNumber numberWithBool:networkOk] forKey:@"netWorkStatus"];
        
    }];
    [dataTask resume];
}

- (void)updateYiDianStatus {
    CommandControler *cmdC=[[CommandControler alloc]init];
    [cmdC sendCmd_get_yiDianList:^(BOOL completed, NSArray *list) {
        if (completed && list.count > 0) {
            [[NSNotificationCenter defaultCenter]postNotificationName:YiDian_Update_DidChangeNotification object:@{@"count":[NSNumber numberWithUnsignedInteger:list.count]}];
        }
    }];
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

+ (AppDelegate *)readAppDelegate {
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
    
}

- (void)dealloc {
    [networkTimer invalidate];
    networkTimer=nil;
}
@end

