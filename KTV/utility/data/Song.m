//
//  Song.m
//  KTV
//
//  Created by stevenhu on 15/4/24.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//
#import "Song.h"
#import "CommandControler.h"
#import "NSString+Utility.h"
#import "DataManager.h"
#import "AppDelegate.h"

typedef NS_ENUM (NSUInteger,LuangeType) {
    CHINA_TYPE =0, //国语
    ENGLISH_TYPE,//英语
    YUEYU_TYPE,//粤语
    HANGYU_TYPE,//韩语
    TAIYU_TYPE,//台语
    JASPAN_TYPE,//日语
    FEILUPING_TYPE,//菲律宾
    OTHER_TYPE,//其它
};

@implementation Song
- (void)insertSongToCollectionTable:(void(^)(BOOL complete))actionCompleted{
    __block __weak typeof (self) weakSelf=self;
    NSString *querySqlStr=[NSString stringWithFormat:@"select * from CollectionTable where number='%@'",_number];
    FMResultSet *rs=[[DataManager instanceShare].db executeQuery:querySqlStr];
    while ([rs next]) {
        if ([self.delegate respondsToSelector:@selector(addSongToCollection:result:)]) {
            [self.delegate addSongToCollection:weakSelf result:KMessageStyleInfo];
        }
        if (actionCompleted) {
            actionCompleted(YES);
        }
        return;
    }
    NSString *insertSql1= [NSString stringWithFormat:@"INSERT INTO CollectionTable (number,songname,singer,singer1,songpiy,word,language,volume,channel,sex,stype,newsong,movie,pathid,bihua,addtime,spath)VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",_number,_songname ,_singer ,_singer1 ,_songpiy ,_word ,_language ,_volume ,_channel ,_sex ,_stype ,_newsong ,_movie ,_pathid ,_bihua ,_addtime ,_spath ];
    if (![[DataManager instanceShare].db executeUpdate:insertSql1]) {
        NSLog(@"插入失败1");
        if ([self.delegate respondsToSelector:@selector(addSongToCollection:result:)]) {
            [self.delegate addSongToCollection:weakSelf result:KMessageWarning];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(addSongToCollection:result:)]) {
            [self.delegate addSongToCollection:weakSelf result:KMessageSuccess];
        }
    }
    if (actionCompleted) {
        actionCompleted(YES);
    }

}

- (void)deleteSongFromCollectionTable:(void(^)(BOOL complete))actionCompleted {
    NSString *insertSql1= [NSString stringWithFormat:@"delete from CollectionTable where number='%@'",_number];
    __block __weak typeof (self) weakSelf=self;
    if (![[DataManager instanceShare].db executeUpdate:insertSql1]) {
//        NSLog(@"取消收藏失败");
        if ([self.delegate respondsToSelector:@selector(deleteCollectionSong:result:)]) {
            [self.delegate deleteCollectionSong:weakSelf result:KMessageWarning];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(deleteCollectionSong:result:)]) {
            [self.delegate deleteCollectionSong:weakSelf result:KMessageSuccess];
        }
    }
    if (actionCompleted) {
        actionCompleted(YES);
    }
}

- (void)cutSong:(void(^)(BOOL complete))actionCompleted {
    if ([Utility instanceShare].netWorkStatus) {
    if (_number.length>0) {
        CommandControler *cmd=[[CommandControler alloc]init];
        __weak __block typeof (self) weakSelf=self;
        [cmd sendCmd_switchSong:^(BOOL completed, NSError *error) {
            if (completed) {
                if ([self.delegate respondsToSelector:@selector(cutSongFromCollection:result:)]) {
                    [self.delegate cutSongFromCollection:weakSelf result:KMessageSuccess];
                }
            } else {
                
            }
            if (actionCompleted) {
                actionCompleted(YES);
            }
        }];
    } else {
        if (actionCompleted) {
            actionCompleted(YES);
        }
    }
    } else {
        [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
        if (actionCompleted) {
            actionCompleted(YES);
        }
    }
}

- (void)prioritySong:(void(^)(BOOL complete))actionCompleted {
    if ([Utility instanceShare].netWorkStatus) {
    CommandControler *cmd=[[CommandControler alloc]init];
    __weak __block typeof (self) weakSelf=self;
    [cmd sendCmd_get_yiDianList:^(BOOL completed, NSArray *list) {
        if (completed) {
            if (list.count > 0) {
                for (NSString *tmpNumber in list) {
                    //                    NSLog(@"%@-->",tmpNumber);
                    if  ([tmpNumber isEqualToString:_number]) {
                        [cmd sendCmd_moveSongToTop:_number completed:^(BOOL completed, NSError *error) {
                            if (completed) {
                                if ([self.delegate respondsToSelector:@selector(dingGeFromCollection:result:)]) {
                                    [self.delegate dingGeFromCollection:weakSelf result:KMessageSuccess];
                                }
                                return;
                            } else {
                                //error
                                return;
                            }
                        }];
                        return;
                    }
                }
            }
        } else {
            //no data or network issue
        }
    }];
    } else {
        [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
    }
    
}


- (void)diangeToTop:(void(^)(BOOL complete))actionCompleted {
    if ([Utility instanceShare].netWorkStatus) {
        __weak __block typeof (self) weakSelf=self;
        CommandControler *cmd=[[CommandControler alloc]init];
        [cmd sendCmd_DiangeToTop:_number completed:^(BOOL completed, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed) {
                    if ([self.delegate respondsToSelector:@selector(dingGeFromCollection:result:)]) {
                        [self.delegate dingGeFromCollection:weakSelf result:KMessageSuccess];
                    }
                } else {
                    //network error
                }
            });}];
    } else {
        [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
        if (actionCompleted) {
            actionCompleted(YES);
        }
    }
}

- (NSString*)getLuangeString {
    int languageType=[_language intValue];
    switch (languageType) {
        case 0: {
            return @"國語";
        }
            break;
        case 1: {
            return @"英語";

        }
            break;
        case 2: {
            return @"粵語";

        }
            break;
        case 3: {
            return @"韓語";

        }
            break;
        case 4: {
            return @"臺語";

        }
            break;
        case 5: {
            return @"日語";

        }
            break;
        case 6: {
            return @"菲律賓";
        }
        default:
            break;
    }
    
    return nil;
}

@end
