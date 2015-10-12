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
#define COMMANDURLHEADER @"http://192.168.43.1:8080/puze/?cmd="
#define COMM_URLStr @"http://192.168.43.1:8080/puze/?cmd=0x01&filename="
#define DOCUMENTPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
@interface DownLoadFileTool () {
    NSMutableArray *needImportFilefullPaths;
    NSString* savePath_TxtDir;
    NSUserDefaults *defaults;
    NSURLSession *shareSession;
    NSFileManager *fileManager;
    NSArray *allTXTFiles;
}

@end

@implementation DownLoadFileTool

- (instancetype)init {
    if (self=[super init]) {
       defaults =[NSUserDefaults standardUserDefaults];
       shareSession=[NSURLSession sharedSession];
       fileManager=[NSFileManager defaultManager];
       allTXTFiles=@[@"songlist.txt",@"singlist.txt",@"typelist.txt",@"orderdata.txt"];
       savePath_TxtDir=[DOCUMENTPATH stringByAppendingPathComponent:@"/downloadDir/txt"];
        if (![fileManager fileExistsAtPath:savePath_TxtDir]) {
            [fileManager createDirectoryAtPath:savePath_TxtDir withIntermediateDirectories:YES attributes:nil error:nil];
        }

    }
    return self;
    //
}

- (void)downLoadTxtFile:(DownloadTxtFilesCompleted)completed {
    if (completed) {
        _completed=completed;
    }
    //1.checkVersion
    NSString *currentVer=[defaults objectForKey:@"CURRENT_DATABASE_VERSION"];
    if (currentVer==nil) {
        //download
    } else {
      [self isNeedToUpdate_Database_version:^(BOOL canUpdate) {
          if (canUpdate) {
              //download
          }
      }];
    }
    
}

- (void)startDownloadFiles {
    dispatch_queue_t queue=dispatch_get_global_queue(2, 0);
    dispatch_group_t group=dispatch_group_create();
    for (NSString *fileName in allTXTFiles) {
        dispatch_group_async(group, queue, ^{
            [self downLoadFile:fileName];
        });
    }
    //等group里的task都执行完后执行notify方法里的内容,相当于把wait方法及之后要执行的代码合到一起了
    dispatch_group_notify(group, queue, ^{
        if (_completed) {
            _completed(YES);
        }
    });
}
//下载文件
//typelist.txt  songlist.txt orderdata.txt singlist.txt
- (void)downLoadFile:(NSString*)fileName{
    if (![Utility instanceShare].networkStatus)return;
    NSString *strURL=[COMM_URLStr stringByAppendingString:fileName];
    NSURL *url=[NSURL URLWithString:[strURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
//    NSLog(@"%@",url);
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:url];
    NSURLSessionDownloadTask *dataTask=[shareSession downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        if (responseStatusCode==200) {
            // 输出下载文件原来的存放目录
            NSLog(@"%@", location);
            // 设置文件的存放目标路径
            NSURL *fileURL = [[NSURL fileURLWithPath:savePath_TxtDir] URLByAppendingPathComponent:fileName];
            [self copyTxtFile:location Distance:fileURL];
        }
    }];
    [dataTask resume];
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
- (void)isNeedToUpdate_Database_version:(void(^)(BOOL canUpdate))update {
    if (![Utility instanceShare].networkStatus) return;
    NSString *urlStr=[[COMMANDURLHEADER stringByAppendingFormat:@"0xd4"]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSURLSessionDataTask *dataTask=[shareSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        if ([httpResponse statusCode]==200 && data) {
            NSString *newVersion=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSString *currentVer=[defaults objectForKey:@"CURRENT_DATABASE_VERSION"];
            if ([currentVer isEqualToString:newVersion]) {
                if (update) {
                    update(NO);
                }
            } else {
                if (update) {
                [defaults setObject:newVersion forKey:@"CURRENT_DATABASE_VERSION"];
                [defaults synchronize];
                update(YES);
                }
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}
@end
