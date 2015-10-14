//
//  DataMananager.m
//  KTV
//
//  Created by admin on 15/10/12.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import "DataMananager.h"
#import "NSString+Utility.h"
#define DBPATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"DB.sqlite"]
static DataMananager *shareInstance=nil;
#define DATABASE_ALREADY  @"DATABASE_ALREADY"
static  int limit=1000;
@interface DataMananager () {
    int hasCount;
    NSUserDefaults *userDefaults;
}

@end

@implementation DataMananager
+ (instancetype)instanceShare {
    static  dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!shareInstance) {
            shareInstance=[[self alloc]init];
        }
    });
    return shareInstance;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone  {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance=[super allocWithZone:zone];
    });
    return shareInstance;
}

- (id)init {
    if (self=[super init]) {
        _db=[[FMDatabase alloc]initWithPath:DBPATH];
        NSLog(@"%@",DBPATH);
        userDefaults=[NSUserDefaults standardUserDefaults];
        if ([_db open]) {
            NSLog(@"DataBase is open ok");
            if (![userDefaults objectForKey:@"DATABASE_ALREADY"]) {
//                if (DEBUG) {
//                    [self copyDBFile];
//                }
                [self createTables];
            }
        } else {
            [_db close];
            NSAssert1(0, @"Failed to open database file with message '%@'.", [_db lastErrorMessage]);
        }
    }
    return self;
}

- (void)copyDBFile {
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSString *filePath=[[NSBundle mainBundle]pathForResource:@"DB.sqlite" ofType:nil];
    if ([fileManager fileExistsAtPath:DBPATH]) {
        [fileManager removeItemAtPath:DBPATH error:nil];
        [fileManager copyItemAtPath:filePath toPath:DBPATH error:nil];
        [self setDatabaseAlready:YES];
    }
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

- (BOOL)databaseAlready {
    return [userDefaults objectForKey:DATABASE_ALREADY];
}

- (void)setDatabaseAlready:(BOOL)already {
    [userDefaults objectForKey:DATABASE_ALREADY];
    [userDefaults synchronize];
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
    NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    if (![_db executeUpdate:sqlstr])
    {
        return NO;
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
    //1.check and create SongTable
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

- (void)eraserTables:(NSArray*)fileArray{
    for (NSString *oneFilePath in fileArray) {
        NSString *fileName=[oneFilePath lastPathComponent];
        if ([fileName isEqualToString:@"songlist.txt"]) {
            [self eraseTable:@"SongTable"];
        } else if ([fileName isEqualToString:@"singlist.txt"]) {
            [self eraseTable:@"SingerTable"];
        } else if ([fileName isEqualToString:@"typelist.txt"]) {
            [self eraseTable:@"TypeTable"];
        } else if ([fileName isEqualToString:@"orderdata.txt"]) {
            [self eraseTable:@"OrderTable"];
        }
        //        //删除表 CollectionTable
        //        sqlDeleteRecord =@"DROP TABLE IF EXISTS CollectionTable";
        //        [_db executeUpdate:sqlDeleteRecord];
        
    }
}

- (void)addIntoDataSourceWithFileNames:(NSArray*)fileNames completed:(DataImportCompleted)completed {
    if (completed) {
        _completed=completed;
    }
    //drap  all  data for tables
    [self eraserTables:fileNames];
    //Import all data for tables
    for (NSString *oneFilePath in fileNames) {
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
    [self setDatabaseAlready:YES];
    _completed(YES);
    
}

- (NSError*)importDataForSongs:(NSString*)txtFilePath {
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
                        // NSLog(@"--line error--%d",i);
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

- (int)rowCountWithStatment:(NSString*)statment {
    if ([_db open]) {
        FMResultSet *rs=[[DataMananager instanceShare].db executeQuery:statment];
        while ([rs next]) {
            return [rs intForColumnIndex:0];
        }
    }
    return 0;
}


- (void)closeDB {
    [_db close];
    _db=nil;
}

- (void)dealloc {
    [self closeDB];
}
@end
