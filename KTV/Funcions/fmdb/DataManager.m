//
//  DownLoadFileTool.m
//  KTV
//
//  Created by admin on 15/10/12.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import "DataManager.h"
#import "CommandControler.h"
#import "Utility.h"
#import "NSString+Utility.h"
#import "DataManager.h"
#import "SDWebImageManager.h"
#import "KTVModel.h"
#import "ZipArchive.h"
static  int limit=1000;

#define DOCUMENTPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

#define DBPATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"DB.sqlite"]

#define DEMODBPATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"DB.sqlite.zip"]
typedef void (^completedBlock)(BOOL isOk,NSError *error);

@interface DataManager () {
    NSString* savePath_TxtDir;
    NSUserDefaults *defaults;
    NSURLSession *shareSession;
    NSFileManager *fileManager;
    
    //download
    completedBlock finishedBlock;
    dispatch_group_t completedGroup;
    NSMutableArray *requests;
    NSString * newVersion;
    
    //import
    int hasCount;
    dispatch_group_t importGroup;
    
}
@property(nonatomic,strong)NSOperationQueue *queue;
@property(nonatomic,strong)NSArray *downloadModels;
@end
static DataManager *instance=nil;
@implementation DataManager

+ (instancetype)instanceShare {
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
        [self createTables];
        NSLog(@"%@",DOCUMENTPATH);
        importGroup=dispatch_group_create();
        instance = [super init];
    });
    return instance;
}

/*
 *新的下载方法 形如
 * ===============
 */
//@[@"songlist.txt",@"singlist.txt",@"typelist.txt",@"orderdata.txt"]
- (void)downloadTxtFiles:(NSArray<KTVModel*> *)downloadModels delegate:(id<DataManagerDelegate>)delegate completionBlock:(void (^)(BOOL isOk,NSError *error))completionBlock {
    savePath_TxtDir=[DOCUMENTPATH stringByAppendingPathComponent:@"DownloadFiles"];
    if (![fileManager fileExistsAtPath:savePath_TxtDir]) {
        [fileManager createDirectoryAtPath:savePath_TxtDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    finishedBlock=[completionBlock copy];
    _delegate=delegate;
    _downloadModels=[downloadModels copy];
    shareSession=[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    _queue=[[NSOperationQueue alloc]init];
    [_queue setMaxConcurrentOperationCount:10];
    
    //是否有新版本需要更新
    NSString *urlStr=[NSString stringWithFormat:@"http://%@:8080/puze/?cmd=0xd4",[Utility instanceShare].serverIPAddress];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    NSURLSessionDataTask *dataTask=[shareSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        if ([httpResponse statusCode]==200 && data) {
            newVersion=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            //check and download
            [self checkAndDownloadfilesOpearations];
        } else {
            // all downloadCompleted ???
            if (finishedBlock) {
                finishedBlock(YES,[NSError errorWithDomain:@"9999" code:9999 userInfo:@{@"errorDescript":@"error connection to host for check version"}]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
    
}


-(void)checkAndDownloadfilesOpearations {
    completedGroup= dispatch_group_create();
    NSBlockOperation *finishedOperation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_group_notify(completedGroup, dispatch_get_main_queue(), ^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(tasksDownloaded:)]) {
                __weak __typeof(self) weakSelf=self;
                [self.delegate tasksDownloaded:weakSelf];
            }
            if (finishedBlock) {
                [[NSURLCache sharedURLCache]removeAllCachedResponses];
                finishedBlock(YES,nil);
            }
        });
    }];
    
    for (KTVModel *downloadModel in _downloadModels) {
        //check who will be to download,if download need to downdoad
        if (![downloadModel.txtVersion isEqualToString:newVersion]) {
            downloadModel.downloadStatus=TxtDownloadModel_starting;
            if (self.delegate && [self.delegate respondsToSelector:@selector(startingDownload:model:)]) {
                __weak __typeof(self) weakSelf=self;
                [self.delegate startingDownload:weakSelf model:downloadModel];
            }
            [_queue addOperation:[self createSingalTxtFileOpearation:downloadModel depenency:finishedOperation]];
        } else {
            downloadModel.downloadStatus=TxtDownloadModel_finished;
            if (self.delegate && [self.delegate respondsToSelector:@selector(finishedDownload:model:)]) {
                __weak __typeof(self) weakSelf=self;
                [self.delegate finishedDownload:weakSelf model:downloadModel];
            }
        }
    }
    if (_queue.operationCount > 0 && [self.delegate respondsToSelector:@selector(tasksWillDownloading:)]) {
        
        __weak __typeof(self) weakSelf=self;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.delegate tasksWillDownloading:weakSelf];
        });
    }
    
    [_queue addOperation:finishedOperation];
    
}

- (NSBlockOperation*)createSingalTxtFileOpearation:(KTVModel*)model depenency:(NSOperation*)deOperation {
    NSBlockOperation *operation=[NSBlockOperation blockOperationWithBlock:^{
        NSString *strURL=[[NSString stringWithFormat:@"http://%@:8080/puze/?cmd=0x01&filename=",[Utility instanceShare].serverIPAddress]stringByAppendingString:model.fileName];
        NSURL *URL = [NSURL URLWithString:strURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [requests addObject:request];
        NSURLSessionDownloadTask *downloadTask=[shareSession downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
            NSInteger responseStatusCode = [httpResponse statusCode];
            if (responseStatusCode==200) {
                //                NSURL *documentsDirectoryURL = [[fileManager URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:ye error:nil]URLByAppendingPathComponent:[response suggestedFilename]];
                NSURL * documentsDirectoryURL=[NSURL fileURLWithPath:[savePath_TxtDir stringByAppendingPathComponent:[response suggestedFilename]]];
                if (![self tryCopyFiles:location toDic:documentsDirectoryURL]) {
                    finishedBlock(YES,[NSError errorWithDomain:@"9999" code:9999 userInfo:@{@"errorDescript":@"copy files error"}]);
                }
                model.downloadStatus=TxtDownloadModel_finished;
                model.txtVersion=newVersion;
                if (self.delegate && [self.delegate respondsToSelector:@selector(finishedDownload:model:)]) {
                    __weak __typeof(self) weakSelf=self;
                    [self.delegate finishedDownload:weakSelf model:model];
                }
                dispatch_group_leave(completedGroup);
                
            } else {
                model.downloadStatus=TxtDownloadModel_failed;
                NSLog(@"File downloaded to failed: %@", model.fileName);
                if (self.delegate && [self.delegate respondsToSelector:@selector(failDownload:model:)]) {
                    __weak __typeof(self) weakSelf=self;
                    [self.delegate failDownload:weakSelf model:model];
                }
                dispatch_group_leave(completedGroup);
            }
        }];
        [downloadTask resume];
    }];
    dispatch_group_enter(completedGroup);
    [deOperation addDependency:operation];
    return operation;
}


- (BOOL)tryCopyFiles:(NSURL *)local toDic:(NSURL*)toDic {
    static int copyCount=0;
    NSURL *url=nil;
    if (![fileManager replaceItemAtURL:toDic withItemAtURL:local backupItemName:@"backup" options:NSFileManagerItemReplacementUsingNewMetadataOnly resultingItemURL:&url error:nil]) {
        copyCount++;
        //remove files
        [fileManager removeItemAtURL:toDic error:nil];
        if (copyCount <3) {
            [self tryCopyFiles:local toDic:toDic];
        } else {
            return NO;
        }
    }
    return YES;
}

/*
 *新的下载方法 结束
 * ===============
 */

//
////copy file
//- (void)copyTxtFile:(NSURL*)location Distance:(NSURL*)distancePath {
//    [self removeFile:[distancePath absoluteString]];
//    [fileManager moveItemAtURL:location toURL:distancePath error:NULL];
//}
//
////删除文件
//- (void)remove_downloadedTxtFiles {
//    savePath_TxtDir=[DOCUMENTPATH stringByAppendingPathComponent:@"/downloadDir/txt"];
//    for (NSString *str in allTXTFiles) {
//        [self removeFile:[savePath_TxtDir stringByAppendingPathComponent:str]];
//    }
//}
//
//- (BOOL)removeFile:(NSString*)filePath {
//    if ([fileManager fileExistsAtPath:filePath]) {
//        [fileManager removeItemAtPath:filePath error:nil];
//    }
//
//    return YES;
//}

// import

// open db file

- (BOOL)openDB {
    if ([_db open]) {
        NSLog(@"DataBase is open ok");
        return YES;
    }
    NSAssert1(0, @"Failed to open database file with message '%@'.", [_db lastErrorMessage]);
    return NO;
}

//close db file
- (BOOL)closeDB {
    if ([_db close]) {
        _db=nil;
        return YES;
    }
    return NO;
}

// 判断是否存在表
- (BOOL)isTableOK:(NSString *)tableName {
    FMResultSet *rs = [_db executeQuery:@"SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = ?", tableName];
    while ([rs next])
    {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        if (0 == count)  {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

// 获得表的数据条数
- (int)getTableItemCount:(NSString *)tableName {
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM %@", tableName];
    FMResultSet *rs = [_db executeQuery:sqlstr];
    while ([rs next])
    {
        // just print out what we've got in a number of formats.
        return [rs intForColumn:@"count"];
    }
    return 0;
}

// 清除表-清数据
- (BOOL)eraseTable:(NSString *)tableName {
    if ([self getTableItemCount:tableName]>0) {
        NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
        if (![_db executeUpdate:sqlstr])
        {
            NSLog(@"%@",sqlstr);
            return NO;
        }
    }
    return YES;
}

// 删除表-彻底删除表
- (BOOL)deleteTable:(NSString *)tableName {
    NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
    if (![_db executeUpdate:sqlstr])
    {
        return NO;
    }
    return YES;
}

- (void)createTables {
    _db=[[FMDatabase alloc]initWithPath:DBPATH];
    NSLog(@"%@",DBPATH);
    //1.check and create SongTable
    if (![self openDB]) {
        NSLog(@" DB open error %@",[_db lastErrorMessage]);
        return;
    }
    NSString *sqlCreateTable=nil;
    BOOL res =NO;
    if (![self isTableOK:@"SongTable"]) {
        sqlCreateTable =@"CREATE TABLE IF NOT EXISTS SongTable (number TEXT PRIMARY KEY,songname TEXT,singer TEXT,singer1 TEXT,songpiy TEXT,word TEXT,language TEXT,volume TEXT,channel TEXT,sex TEXT,stype TEXT,newsong TEXT,movie TEXT,pathid TEXT,bihua TEXT,addtime TEXT,spath TEXT)";
        
        BOOL res = [_db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating SongTable table");
        } else {
            NSLog(@"success to creating SongTable table");
        }
    }
    
    //2.check and create SingerTable
    if (![self isTableOK:@"SingerTable"]) {
        sqlCreateTable =@"CREATE TABLE IF NOT EXISTS SingerTable (sid TEXT,singer TEXT,pingyin TEXT,s_bi_hua TEXT,area TEXT)";
        
        res = [_db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating SingerTable table");
        } else {
            NSLog(@"success to creating SingerTable table");
        }
    }
    
    //3.check and create TypeTable
    if (![self isTableOK:@"TypeTable"]) {
        sqlCreateTable =@"CREATE TABLE IF NOT EXISTS TypeTable (typeid TEXT,type TEXT,typename TEXT)";
        res = [_db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating TypeTable table");
        } else {
            NSLog(@"success to creating TypeTable table");
        }
    }
    
    //4.check and create OrderTable
    if (![self isTableOK:@"OrderTable"]) {
        sqlCreateTable =@"CREATE TABLE IF NOT EXISTS OrderTable (number TEXT,rcid TEXT,ordername TEXT)";
        
        res = [_db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating OrderTable table");
        } else {
            NSLog(@"success to creating OrderTable table");
        }
    }
    
    //5.check and create CollectionTable
    if (![self isTableOK:@"CollectionTable"]) {
        sqlCreateTable =@"CREATE TABLE IF NOT EXISTS CollectionTable (number TEXT PRIMARY KEY,songname TEXT,singer TEXT,singer1 TEXT,songpiy TEXT,word TEXT,language TEXT,volume TEXT,channel TEXT,sex TEXT,stype TEXT,newsong TEXT,movie TEXT,pathid TEXT,bihua TEXT,addtime TEXT,spath TEXT)";
        res = [_db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating TypeTable table");
            
        } else {
            NSLog(@"success to creating TypeTable table");
        }
    }
    
}

- (BOOL)eraserTables:(KTVModel*)model{
    //    for (KTVModel *oneModel in models) {
    return  [self eraseTable:model.tableName];
    //    }
}

- (void)addIntoDataSourceWithModels:(NSArray<KTVModel*>*)models delegate:(id<DataManagerDelegate>)delegate {
    //drap  all  data for tables
    _delegate=delegate;
    for (KTVModel *oneModel in models) {
        if (![oneModel.tableVersion isEqualToString:newVersion]) {
            [self eraserTables:oneModel];
            if (self.delegate && [self.delegate respondsToSelector:@selector(startingImportData:model:)]) {
                __weak __typeof(self) weakSelf=self;
                [self.delegate startingImportData:weakSelf model:oneModel];
            }
            oneModel.importDataStatus=TxtDownloadModel_starting;
            if ([oneModel.fileName isEqualToString:@"songlist.txt"]) {
                [self importDataForSongs:oneModel];
            } else if([oneModel.fileName isEqualToString:@"singlist.txt"]) {
                [self importDataForSingers:oneModel];
            } else if([oneModel.fileName isEqualToString:@"typelist.txt"]) {
                [self importDataForType:oneModel];
            } else if ([oneModel.fileName isEqualToString:@"orderdata.txt"]) {
                [self importDataForOrder:oneModel];
            }
            oneModel.importDataStatus=TxtDownloadModel_finished;
            oneModel.tableVersion=newVersion;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(finishedImportData:model:)]) {
            __weak __typeof(self) weakSelf=self;
            [self.delegate finishedImportData:weakSelf model:oneModel];
        }
        
        if ([oneModel isEqual:[models lastObject]] ) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(tasksDataImported:)]) {
                __weak __typeof(self) weakSelf=self;
                [self.delegate tasksDataImported:weakSelf];
            }
        }
    }
}

- (NSError*)importDataForSongs:(KTVModel*)model {
    NSString *txtFilePath=[savePath_TxtDir stringByAppendingPathComponent:model.fileName];
    NSString *str=[NSString stringWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines=[str componentsSeparatedByString:@"\r\n"];
    hasCount=(int)lines.count;
    [self insertSongsData:0 toIndex:999 useTransaction:YES dataSource:lines];
    model.importDataStatus=TxtDownloadModel_finished;
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
                    if  (lineArry.count < 17) {
                        toIndex--;
                        // NSLog(@"--line error--%d",i);
                        continue;
                    }
                    
//                    NSString *insertSql1= [NSString stringWithFormat:@"INSERT INTO SongTable (number,songname,singer,singer1,songpiy,word,language,volume,channel,sex,stype,newsong,movie,pathid,bihua,addtime,spath)VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",[lineArry[0] encodeBase64],[lineArry[1] encodeBase64],[lineArry[2] encodeBase64],[lineArry[3] encodeBase64],[lineArry[4] encodeBase64],[lineArry[5] encodeBase64],[lineArry[6] encodeBase64],[lineArry[7] encodeBase64],[lineArry[8] encodeBase64],[lineArry[9] encodeBase64],[lineArry[10] encodeBase64],[lineArry[11] encodeBase64],[lineArry[12] encodeBase64],[lineArry[13] encodeBase64],[lineArry[14] encodeBase64],[lineArry[15] encodeBase64],[lineArry[16] encodeBase64]];
                    
                    NSString *songnm=[lineArry[1] stringByReplacingOccurrencesOfString:@"'" withString:@"‘"];
                    NSString *singnm=[lineArry[2] stringByReplacingOccurrencesOfString:@"'" withString:@"‘"];
                    NSString *singnm2=[lineArry[3] stringByReplacingOccurrencesOfString:@"'" withString:@"‘"];
                    
                   NSString *insertSql1= [NSString stringWithFormat:@"INSERT INTO SongTable (number,songname,singer,singer1,songpiy,word,language,volume,channel,sex,stype,newsong,movie,pathid,bihua,addtime,spath)VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",lineArry[0] ,songnm ,singnm ,singnm2,lineArry[4] ,lineArry[5] ,lineArry[6] ,lineArry[7] ,lineArry[8] ,lineArry[9] ,lineArry[10] ,lineArry[11] ,lineArry[12] ,lineArry[13] ,lineArry[14] ,lineArry[15] ,lineArry[16]];
                    if (![_db executeUpdate:insertSql1]) {
                        NSLog(@"插入失败_SongTable");
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



- (NSError*)importDataForSingers:(KTVModel*)model {
    NSString *txtFilePath=[savePath_TxtDir stringByAppendingPathComponent:model.fileName];
    NSString *str=[NSString stringWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines=[str componentsSeparatedByString:@"\r\n"];
    hasCount=(int)lines.count;
    [self insertSingersData:0 toIndex:999 useTransaction:YES dataSource:lines];
    model.importDataStatus=TxtDownloadModel_finished;
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
                    if  (lineArry.count < 4) {
                        toIndex--;
//                        NSLog(@"line error %d",fromIndex);
                        continue;
                    }
                    NSString *singnm=[lineArry[0] stringByReplacingOccurrencesOfString:@"'" withString:@"‘"];
                    NSString *pingying=[lineArry[1] stringByReplacingOccurrencesOfString:@"'" withString:@"‘"];
                    NSString *bihua=[lineArry[2] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    NSString *insertSql1=[NSString stringWithFormat:@"INSERT INTO SingerTable (singer,pingyin,s_bi_hua,area)VALUES ('%@','%@','%@','%@')",singnm,pingying,bihua,lineArry[3]];
                    if (![_db executeUpdate:insertSql1]) {
                        NSLog(@"插入失败 _SingerTable");
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


- (NSError*)importDataForType:(KTVModel*)model {
    NSString *txtFilePath=[savePath_TxtDir stringByAppendingPathComponent:model.fileName];
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
            NSString *insertSql= [NSString stringWithFormat:@"INSERT INTO TypeTable (typeid,type,typename)VALUES ('%@','%@','%@')",lineArry[0] ,lineArry[1] ,lineArry[2] ];
            [_db executeUpdate:insertSql];
            
        }
    }
    model.importDataStatus=TxtDownloadModel_finished;
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
                    NSString *insertSql= [NSString stringWithFormat:@"INSERT INTO TypeTable (typeid,type,typename)VALUES ('%@','%@','%@')",lineArry[0],lineArry[1],lineArry[2]];
                    if (![_db executeUpdate:insertSql]) {
                        NSLog(@"插入失败_TypeTable");
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


- (NSError*)importDataForOrder:(KTVModel*)model {
    struct orderrec {
        char number[8];
        int rcid;
        int order;
    };
    struct orderrec *orderadd;
    NSString *txtFilePath=[savePath_TxtDir stringByAppendingPathComponent:model.fileName];
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
        NSString *insertSql= [NSString stringWithFormat:@"INSERT INTO OrderTable (number,rcid,ordername)VALUES ('%@','%@','%@')",number,rcid,order];
        if (![_db executeUpdate:insertSql]) {
            NSLog(@"插入失败 ——OrderTable");
        }
        free(mynumber);
    }
    fclose(fn);
    free(orderadd);
    return nil;
}

- (int)rowCountWithStatment:(NSString*)statment {
    FMResultSet *rs=[[DataManager instanceShare].db executeQuery:statment];
    while ([rs next]) {
        return [rs intForColumnIndex:0];
    }
    return 0;
}

//解压文件为演示

- (void)unArchiveDemoDbFile:(void(^)(BOOL completed))completed {
    if ([[NSFileManager defaultManager]fileExistsAtPath:DBPATH])
        [fileManager removeItemAtPath:DBPATH error:nil];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSString *fileSourcePath=[[NSBundle mainBundle]pathForResource:@"DB.sqlite" ofType:@"zip"];
            NSString *savaPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
            if ([ZipArchive unzipFileAtPath:fileSourcePath
                              toDestination:savaPath]) {
                [self openDB];
                completed(YES);
            } else {
                completed(NO);
            }
        });
    
}

- (void)dealloc {
    [self closeDB];
}

@end
