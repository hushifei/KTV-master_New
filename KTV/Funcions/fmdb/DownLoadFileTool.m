//
//  DownLoadFileTool.m
//  KTV
//
//  Created by admin on 15/10/12.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import "DownLoadFileTool.h"
#import "CommandControler.h"
#import "Utility.h"
#import "DataMananager.h"
#import "SDWebImageManager.h"
//#define COMMANDURLHEADER @"http://192.168.43.1:8080/puze/?cmd="
//#define COMM_URLStr @"http://192.168.43.1:8080/puze/?cmd=0x01&filename="
#define DOCUMENTPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

@interface DownLoadFileTool () {
    NSMutableArray *needImportFilefullPaths;
    NSString* savePath_TxtDir;
    NSUserDefaults *defaults;
    NSURLSession *shareSession;
    NSFileManager *fileManager;
    NSArray *allTXTFiles;
    NSMutableArray *downloadStatus;
    NSString *newDatabaseVer;
    DataMananager *dataManager;
    dispatch_group_t group;
}

@end
static DownLoadFileTool *instance=nil;
@implementation DownLoadFileTool

+ (instancetype)instance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    instance = [[self alloc]init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    instance = [super allocWithZone:zone];
    });
    return instance;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return self;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    defaults =[NSUserDefaults standardUserDefaults];
    shareSession=[NSURLSession sharedSession];
    fileManager=[NSFileManager defaultManager];
    dataManager=[DataMananager instanceShare];
    allTXTFiles=@[@"songlist.txt",@"singlist.txt",@"typelist.txt",@"orderdata.txt"];
    savePath_TxtDir=[DOCUMENTPATH stringByAppendingPathComponent:@"/downloadDir/txt"];
    if (![fileManager fileExistsAtPath:savePath_TxtDir]) {
        [fileManager createDirectoryAtPath:savePath_TxtDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    downloadStatus=[[NSMutableArray alloc]initWithCapacity:4];
    instance = [super init];
    });
    return instance;
}

- (void)downLoadTxtFile:(DownloadTxtFilesCompleted)completed {
    if (completed) {
        _completed=completed;
    }
    // check version and download files
    [self isNeedToUpdate_Database_version:^(S_Actions action, BOOL completed) {
            if (action==S_Can_Donload && completed) {
                [self startDownloadFiles];
            } else if (action ==S_Can_ImportData && completed) {
                //check txt files exist
                if ([dataManager databaseAlready]) {
                    if (_completed) {
                        _completed(YES,nil);
                    }
                    return;
                }
                NSMutableArray *willImportArray=[NSMutableArray new] ;
                for (NSString *fileName in allTXTFiles) {
                    NSString *filePath=[savePath_TxtDir stringByAppendingPathComponent:fileName];
                    if ([fileManager fileExistsAtPath:filePath]) {
                        [willImportArray addObject:filePath];
                    }
                }
                //import data;
                if (willImportArray.count ==4) {
                  [self importTxtFilesToDataBase:willImportArray];
                } else {
                    if (_completed) {
                        _completed(YES,nil);
                        return;
                    }
                }
            } else {
                //return error information
                if (_completed) {
                    _completed(YES,[NSError errorWithDomain:@"9999" code:9999 userInfo:@{@"errorDescript":@"network error"}]);
                }
            }
    }];
}

- (void)startDownloadFiles {
    group=dispatch_group_create();
    for (NSString *fileName in allTXTFiles) {
            dispatch_group_enter(group);
            [self downLoadFile:fileName];
    }
    //等group里的task都执行完后执行notify方法里的内容,相当于把wait方法及之后要执行的代码合到一起了
        dispatch_group_notify(group,dispatch_get_global_queue(0, 0), ^{
                [self importTxtFilesToDataBase:downloadStatus];
        });
}
//下载文件
//typelist.txt  songlist.txt orderdata.txt singlist.txt
- (void)downLoadFile:(NSString*)fileName{
    //#define COMM_URLStr @"http://192.168.43.1:8080/puze/?cmd=0x01&filename="
    NSString *strURL=[[NSString stringWithFormat:@"http://%@:8080/puze/?cmd=0x01&filename=",[Utility instanceShare].serverIPAddress]stringByAppendingString:fileName];
    NSURL *url=[NSURL URLWithString:[strURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:url];
    NSURLSessionDownloadTask *dataTask=[shareSession downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        if (responseStatusCode==200) {
            // 输出下载文件原来的存放目录
            //            NSLog(@"%@", location);
            // 设置文件的存放目标路径
            NSURL *fileURL = [[NSURL fileURLWithPath:savePath_TxtDir] URLByAppendingPathComponent:fileName];
            [self copyTxtFile:location Distance:fileURL];
            [downloadStatus addObject:[savePath_TxtDir stringByAppendingPathComponent:fileName]];
        } else {
            NSLog(@"download file eror -->%@",fileName);
        }
        dispatch_group_leave(group);
    }];
    [dataTask resume];
}

- (void)importTxtFilesToDataBase:(NSArray*)filePaths {
    //import data
    [[DataMananager instanceShare]addIntoDataSourceWithFileNames:filePaths completed:^(BOOL Completed) {
        if (Completed) {
            if (_completed) {
                [defaults setObject:newDatabaseVer forKey:@"CURRENT_DATABASE_VERSION"];
                [defaults synchronize];
                [self remove_downloadedTxtFiles];
                _completed(YES,nil);
            }
            NSLog(@"import data done!");
        }
    }];
}

//copy file

- (void)copyTxtFile:(NSURL*)location Distance:(NSURL*)distancePath {
    [self removeFile:[distancePath absoluteString]];
    [fileManager moveItemAtURL:location toURL:distancePath error:NULL];
}

//删除文件
- (void)remove_downloadedTxtFiles {
    savePath_TxtDir=[DOCUMENTPATH stringByAppendingPathComponent:@"/downloadDir/txt"];
    for (NSString *str in allTXTFiles) {
        [self removeFile:[savePath_TxtDir stringByAppendingPathComponent:str]];
    }
}

- (BOOL)removeFile:(NSString*)filePath {
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
    
    return YES;
}

//获取数据版本
- (void)isNeedToUpdate_Database_version:(void(^)(S_Actions action,BOOL completed))completed {
//    NSString *strURL=[NSString stringWithFormat:@"http://%@:8080/puze/?cmd=0x01&filename=",[Utility instanceShare].serverIPAddress];
    //#define COMMANDURLHEADER @"http://192.168.43.1:8080/puze/?cmd="
    NSString *urlStr=[NSString stringWithFormat:@"http://%@:8080/puze/?cmd=0xd4",[Utility instanceShare].serverIPAddress];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    NSURLSessionDataTask *dataTask=[shareSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        if ([httpResponse statusCode]==200 && data) {
            newDatabaseVer=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSString *currentVer=[defaults objectForKey:@"CURRENT_DATABASE_VERSION"];
            if (![currentVer isEqualToString:newDatabaseVer]) {
                if (completed) {
                    completed(S_Can_Donload,YES);
                }
            } else {
                if (completed) {
                    completed(S_Can_ImportData,YES);
                }
            }
        } else {
            if (completed) {
                completed(S_Network_Error,NO);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}
@end
