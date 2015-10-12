//
//  Utility.m
//  ZZKTV
//
//  Created by stevenhu on 15-3-22.
//  Copyright (c) 2015年 zz. All rights reserved.
//
//fmdb
#import "Utility.h"
#import "CommandControler.h"
#import "BBBadgeBarButtonItem.h"
#import "NSString+Utility.h"
#import <SystemConfiguration/SystemConfiguration.h>
#define tmpDBPATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"tmpDB.sqlite"]
#define DBPATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"DB.sqlite"]

#define COMM_URLStr @"http://192.168.43.1:8080/puze/?cmd=0x01&filename="
#define DOCUMENTPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
static  int limit=1000;
NSString *const HReachabilityChangedNotification=@"HReachabilityChangedNotification";
@interface Utility() {
    NSMutableArray *needImportFilefullPaths;
    NSString* savePath_TxtDir;
    int hasCount;
    NSTimer *networkTimer;
    NSURLSession *shareSession;
    BOOL netWorkStatus;
}
-(void)reachabilityChanged:(NSNotification*)note;
@property (nonatomic, copy)NSString *modelName;
@property (nonatomic, copy)NSString *dbFileName;
@property (nonatomic,readwrite)FMDatabase *db;
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


- (id)init {
    if (self=[super init]) {
        needImportFilefullPaths=[NSMutableArray new];
        _db=[[FMDatabase alloc]initWithPath:DBPATH];
        [self checkIphoneDevice];
        shareSession=[NSURLSession sharedSession];
        netWorkStatus=NO;
        if ([_db open]) {
            NSLog(@"DataBase is open ok");
        } else {
            NSLog(@"DataBase is open faied");
            
        }
    }
    networkTimer=[NSTimer scheduledTimerWithTimeInterval:5 target:shareInstance selector:@selector(checkNetworkStatus) userInfo:nil repeats:YES];
    [self checkTableAndCreateAndMonitor];
    return self;
}


- (void)checkTableAndCreateAndMonitor{
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
        NSLog(@"path is %@",tmpDBPATH);
    });
    return shareInstance;
}



- (void)setupEnvModel:(NSString *)model DbFile:(NSString *)filename {
    
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

#pragma mark - coredata operation
- (void)addIntoDataSource:(Completed)completed{
    if (netWorkStatus) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self startTodoInitailizationData];
            if (completed) {
                return completed(YES);
            }
        });
    } else {
        return completed(NO);
    }
}
- (BOOL)startTodoInitailizationData {
    for (NSString *oneFilePath in needImportFilefullPaths) {
        NSString *fileName=[oneFilePath lastPathComponent];
        if ([fileName isEqualToString:@"songlist.txt"]) {
            [self importDataForSongs:oneFilePath];
        }
        else if([fileName isEqualToString:@"singlist.txt"]) {
            [self importDataForSingers:oneFilePath];
        }else if([fileName isEqualToString:@"typelist.txt"]) {
            [self importDataForType:oneFilePath];
        } else if ([fileName isEqualToString:@"orderdata.txt"]) {
            [self importDataForOrder:oneFilePath];
        }
    }
    [self initCollectionTable];
    return YES;
}

- (NSError*)importDataForSongs:(NSString*)txtFilePath {
    //check and create Table
    NSString *sqlCreateTable =@"CREATE TABLE IF NOT EXISTS SongTable (number TEXT PRIMARY KEY,songname TEXT,singer TEXT,singer1 TEXT,songpiy TEXT,word TEXT,language TEXT,volume TEXT,channel TEXT,sex TEXT,stype TEXT,newsong TEXT,movie TEXT,pathid TEXT,bihua TEXT,addtime TEXT,spath TEXT)";
    
    BOOL res = [_db executeUpdate:sqlCreateTable];
    if (!res) {
        NSLog(@"error when creating SongTable table");
    } else {
        NSLog(@"success to creating SongTable table");
    }
    NSString *fileName=[txtFilePath lastPathComponent];
    NSString *str=[NSString stringWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines=[str componentsSeparatedByString:@"\t\r\n"];
    hasCount=(int)lines.count;
    [self insertSongsData:0 toIndex:999 useTransaction:YES dataSource:lines];
    [[NSUserDefaults standardUserDefaults]setObject:@YES forKey:fileName];
    str=nil;
    lines=nil;
    return nil;
}

- (void)insertSongsData:(int)fromIndex toIndex:(int)toIndex useTransaction:(BOOL)useTransaction dataSource:(NSArray*)dataSource {
    if (useTransaction) {
        [_db beginTransaction];
        BOOL isRollBack=NO;
        @try {
            for (int i=fromIndex;i<toIndex+1; i++) {
                hasCount--;
                @autoreleasepool {
                    NSArray *lineArry=[dataSource[i] componentsSeparatedByString:@"\t"];
                    if  (lineArry.count !=17) {
                        toIndex--;
                        //                        NSLog(@"--line error--%d",i);
                        continue;
                    }
                    
                    NSString *insertSql1= [NSString stringWithFormat:@"INSERT INTO SongTable (number,songname,singer,singer1,songpiy,word,language,volume,channel,sex,stype,newsong,movie,pathid,bihua,addtime,spath)VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",[lineArry[0] encodeBase64],[lineArry[1] encodeBase64],[lineArry[2] encodeBase64],[lineArry[3] encodeBase64],[lineArry[4] encodeBase64],[lineArry[5] encodeBase64],[lineArry[6] encodeBase64],[lineArry[7] encodeBase64],[lineArry[8] encodeBase64],[lineArry[9] encodeBase64],[lineArry[10] encodeBase64],[lineArry[11] encodeBase64],[lineArry[12] encodeBase64],[lineArry[13] encodeBase64],[lineArry[14] encodeBase64],[lineArry[15] encodeBase64],[lineArry[16] encodeBase64]];
                    if (![_db executeUpdate:insertSql1]) {
                        NSLog(@"插入失败1");
                    }
                    
                }
            }
        }
        @catch (NSException *exception) {
            isRollBack = YES;
            [_db rollback];
        }
        @finally {
            if (!isRollBack) {
                [_db commit];
            }
        }
    } else {
        
    }
    if (hasCount >=limit) {
        fromIndex=toIndex+1;
        toIndex=fromIndex+limit;
        [self insertSongsData:fromIndex toIndex:toIndex useTransaction:YES dataSource:dataSource];
    } else if (hasCount >0 && hasCount < limit) {
        fromIndex=toIndex+1;
        toIndex=fromIndex+hasCount;
        [self insertSongsData:fromIndex toIndex:toIndex useTransaction:YES dataSource:dataSource];
    }
    //    NSLog(@"fromeIndex:%d toIndex:%d",fromIndex,toIndex);
}


- (NSError*)importDataForSingers:(NSString*)txtFilePath {
    //check and create Table
    NSString *sqlCreateTable =@"CREATE TABLE IF NOT EXISTS SingerTable (sid TEXT,singer TEXT,pingyin TEXT,s_bi_hua TEXT,area TEXT)";
    
    BOOL res = [_db executeUpdate:sqlCreateTable];
    if (!res) {
        NSLog(@"error when creating SingerTable table");
    } else {
        NSLog(@"success to creating SingerTable table");
    }
    
    NSString *fileName=[txtFilePath lastPathComponent];
    NSString *str=[NSString stringWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines=[str componentsSeparatedByString:@"\r\n"];
    hasCount=(int)lines.count;
    [self insertSingersData:0 toIndex:999 useTransaction:YES dataSource:lines];
    [[NSUserDefaults standardUserDefaults]setObject:@YES forKey:fileName];
    str=nil;
    lines=nil;
    return nil;
}

- (void)insertSingersData:(int)fromIndex toIndex:(int)toIndex useTransaction:(BOOL)useTransaction dataSource:(NSArray*)dataSource {
    if (toIndex>dataSource.count) {
        return;
    }
    if (useTransaction) {
        [_db beginTransaction];
        BOOL isRollBack=NO;
        @try {
            for (int i=fromIndex;i<toIndex+1; i++) {
                hasCount--;
                @autoreleasepool {
                    NSMutableString *lineStr=[dataSource[i] mutableCopy];
                    [lineStr replaceOccurrencesOfString:@"\t\t" withString:@"\t" options:NSLiteralSearch range:NSMakeRange(0, lineStr.length)];
                    NSArray *lineArry=[lineStr componentsSeparatedByString:@"\t"];
                    if  (lineArry.count !=4) {
                        toIndex--;
                        NSLog(@"line error %d",fromIndex);
                        continue;
                    }
                    NSString *insertSql1=[NSString stringWithFormat:@"INSERT INTO SingerTable (singer,pingyin,s_bi_hua,area)VALUES ('%@','%@','%@','%@')",[lineArry[0] encodeBase64],[lineArry[1] encodeBase64],[lineArry[2] encodeBase64],[lineArry[3] encodeBase64]];
                    if (![_db executeUpdate:insertSql1]) {
                        NSLog(@"插入失败1");
                    }
                    
                }
            }
        }
        @catch (NSException *exception) {
            isRollBack = YES;
            [_db rollback];
        }
        @finally {
            if (!isRollBack) {
                [_db commit];
            }
        }
    } else {
        
    }
    if (hasCount >=limit) {
        fromIndex=toIndex+1;
        toIndex=fromIndex+limit;
        [self insertSingersData:fromIndex toIndex:toIndex useTransaction:YES dataSource:dataSource];
    } else if (hasCount >0 && hasCount < limit) {
        fromIndex=toIndex+1;
        toIndex=fromIndex+hasCount;
        [self insertSingersData:fromIndex toIndex:toIndex useTransaction:YES dataSource:dataSource];
    }
    
}


- (NSError*)importDataForType:(NSString*)txtFilePath {
    //check and create Table
    NSString *sqlCreateTable =@"CREATE TABLE IF NOT EXISTS TypeTable (typeid TEXT,type TEXT,typename TEXT)";
    BOOL res = [_db executeUpdate:sqlCreateTable];
    if (!res) {
        NSLog(@"error when creating TypeTable table");
    } else {
        NSLog(@"success to creating TypeTable table");
    }
    
    NSString *fileName=[txtFilePath lastPathComponent];
    NSString *str=[NSString stringWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines=[str componentsSeparatedByString:@"\r\n"];
    [self insertTypesData:0 toIndex:999 useTransaction:YES dataSource:lines];
    hasCount=(int)lines.count;
    for (NSMutableString *lineStr in lines) {
        @autoreleasepool {
            NSArray *lineArry=[lineStr componentsSeparatedByString:@"\t"];
            if  (lineArry.count !=3) {
                continue;
            }
            NSString *insertSql= [NSString stringWithFormat:@"INSERT INTO TypeTable (typeid,type,typename)VALUES ('%@','%@','%@')",[lineArry[0] encodeBase64],[lineArry[1] encodeBase64],[lineArry[2] encodeBase64]];
            [_db executeUpdate:insertSql];
            
        }
    }
    [[NSUserDefaults standardUserDefaults]setObject:@YES forKey:fileName];
    str=nil;
    lines=nil;
    return nil;
}

- (void)insertTypesData:(int)fromIndex toIndex:(int)toIndex useTransaction:(BOOL)useTransaction dataSource:(NSArray*)dataSource {
    if (toIndex>dataSource.count) {
        return;
    }
    if (useTransaction) {
        [_db beginTransaction];
        BOOL isRollBack=NO;
        @try {
            for (int i=fromIndex;i<toIndex+1; i++) {
                hasCount--;
                @autoreleasepool {
                    NSArray *lineArry=[dataSource[i] componentsSeparatedByString:@"\t"];
                    if  (lineArry.count !=3) {
                        continue;
                    }
                    NSString *insertSql= [NSString stringWithFormat:@"INSERT INTO TypeTable (typeid,type,typename)VALUES ('%@','%@','%@')",[lineArry[0] encodeBase64],[lineArry[1] encodeBase64],[lineArry[2] encodeBase64]];
                    if (![_db executeUpdate:insertSql]) {
                        NSLog(@"插入失败1");
                    }
                    
                }
            }
        }
        @catch (NSException *exception) {
            isRollBack = YES;
            [_db rollback];
        }
        @finally {
            if (!isRollBack) {
                [_db commit];
            }
        }
    } else {
        
    }
    if (hasCount >=limit) {
        fromIndex=toIndex+1;
        toIndex=fromIndex+limit;
        [self insertSingersData:fromIndex toIndex:toIndex useTransaction:YES dataSource:dataSource];
    } else if (hasCount >0 && hasCount < limit) {
        fromIndex=toIndex+1;
        toIndex=fromIndex+hasCount;
        [self insertSingersData:fromIndex toIndex:toIndex useTransaction:YES dataSource:dataSource];
    }
}


- (NSError*)importDataForOrder:(NSString*)txtFilePath {
    //删除表
    NSString *sqlDeleteRecord =@"DROP TABLE IF EXISTS OrderTable";
    [_db executeUpdate:sqlDeleteRecord];
    //创建表
    NSString *sqlCreateTable =@"CREATE TABLE IF NOT EXISTS OrderTable (number TEXT,rcid TEXT,ordername TEXT)";
    
    BOOL res = [_db executeUpdate:sqlCreateTable];
    if (!res) {
        NSLog(@"error when creating OrderTable table");
    } else {
        NSLog(@"success to creating OrderTable table");
    }
    
    struct orderrec {
        char number[8];
        int rcid;
        int order;
    };
    struct orderrec *orderadd;
    FILE *fn=fopen([txtFilePath UTF8String], "r");
    if (fn==NULL) {
        return nil;
    }
    while (1) {
        orderadd=(struct orderrec*)calloc(1, sizeof(struct orderrec));
        
        if(fread(orderadd,sizeof(struct orderrec),1,fn)!=1)
        {
            break;
        }
        //        char * mynumber=(char *)malloc(8);
        //        strncpy(mynumber,orderadd->number,8);
        char * mynumber=(char *)malloc(9);
        memset(mynumber, 0, sizeof(char)*9);
        strncpy(mynumber,orderadd->number,8*sizeof(char));
        //        printf("\n%s\n%d\n%d\n",mynumber,orderadd->rcid,orderadd->order);
        NSString *number=[NSString stringWithCString:mynumber encoding:NSUTF8StringEncoding];
        NSString *rcid=[NSString stringWithFormat:@"%d",orderadd->rcid];
        NSString *order=[NSString stringWithFormat:@"%d",orderadd->order];
        if (number.length >8) {
            number=[number substringToIndex:7];
        } else if (number.length<8) {
            continue;
        }
        //        NSLog(@"\n%@\n%@\n%@",number,rcid,order);
        NSString *insertSql= [NSString stringWithFormat:@"INSERT INTO OrderTable (number,rcid,ordername)VALUES ('%@','%@','%@')",[number encodeBase64],[rcid encodeBase64],[order encodeBase64]];
        [_db executeUpdate:insertSql];
        free(mynumber);
    }
    fclose(fn);
    free(orderadd);
    return nil;
}

- (BOOL)initCollectionTable {
    //check and create Table
    NSString *sqlCreateTable =@"CREATE TABLE IF NOT EXISTS CollectionTable (number TEXT PRIMARY KEY,songname TEXT,singer TEXT,singer1 TEXT,songpiy TEXT,word TEXT,language TEXT,volume TEXT,channel TEXT,sex TEXT,stype TEXT,newsong TEXT,movie TEXT,pathid TEXT,bihua TEXT,addtime TEXT,spath TEXT)";
    BOOL res = [_db executeUpdate:sqlCreateTable];
    if (!res) {
        NSLog(@"error when creating TypeTable table");
        
    } else {
        NSLog(@"success to creating TypeTable table");
    }
    return res;
}


- (void)setYidianBadgeWidth:(BBBadgeBarButtonItem *)item  {
    NSString *urlStr=[[@"http://192.168.43.1:8080/puze/?cmd=" stringByAppendingFormat:@"0xbc"]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        //            NSLog(@"%d",[(NSHTTPURLResponse*)response statusCode]); 200 is ok
        if (connectionError) {
            NSLog(@"get yidian List connection error");
            return;
        }
        NSString *strContent=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSMutableArray *arr=[[strContent componentsSeparatedByString:@"\r\n"] mutableCopy];
        [arr removeLastObject];
        dispatch_sync(dispatch_get_main_queue(), ^{
            item.badgeValue=[NSString stringWithFormat:@"%d",(int)arr.count];
        });
    }];
}



-(BOOL)checkTableAndCreate {
    return YES;
}

//typelist.txt  songlist.txt orderdata.txt singlist.txt
- (void)downLoadFile:(NSString*)fileName{
    //need to add check network

    NSString *strURL=[COMM_URLStr stringByAppendingString:fileName];
    NSString *fileSavePath=[savePath_TxtDir stringByAppendingPathComponent:fileName];
    NSURL *url=[NSURL URLWithString:[strURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
    
    NSLog(@"%@",url);
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0f];
   NSURLSessionDataTask *dataTask= [shareSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        if ([httpResponse statusCode]==200) {
            if([data writeToFile:fileSavePath atomically:YES]) {
                [needImportFilefullPaths addObject:[savePath_TxtDir stringByAppendingPathComponent:fileName]];
            }
        } else {
        }
    }];
    [dataTask resume];
}

- (void)closeDB {
    [_db close];
    _db=nil;
}

- (void)networkStatus:(void(^)(BOOL isSecucess))block {
    NSURL *url=[NSURL URLWithString:@"http://192.168.43.1:8080/puze/"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:2];
   NSURLSessionDataTask *dataTask =[shareSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse*)response;
        NSInteger statuscode=httpResponse.statusCode;
        if (error==nil) {
            if (statuscode ==200 ) {
                netWorkStatus=YES;
            } else {
                netWorkStatus=NO;
            }
        } else {
            netWorkStatus=NO;
        }
        if (block) {
            block(netWorkStatus);
        }
    }];
    [dataTask resume];
}

- (void)checkNetworkStatus {
    NSURL *url=[NSURL URLWithString:@"http://192.168.43.1:8080/puze/"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:2];
   NSURLSessionDataTask *dataTask = [shareSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse*)response;
        NSInteger statuscode=httpResponse.statusCode;
        if (error==nil) {
            if (statuscode ==200 ) {
                netWorkStatus=YES;
            } else {
                netWorkStatus=NO;
                NSLog(@"network connection error");
            }
        } else {
            netWorkStatus=NO;
            NSLog(@"network connection error");
        }
       
       if (netWorkStatus==NO) {
        [[NSNotificationCenter defaultCenter]postNotificationName:HReachabilityChangedNotification object:shareInstance userInfo:@{@"networkStatus":@NO}];
       }
       
    }];
    [dataTask resume];
}

- (BOOL)networkStatus {
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self closeDB];
}
@end

