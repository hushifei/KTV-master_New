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
#import "DataMananager.h"
#import "AppDelegate.h"
@implementation Song

-(void)setAddtime:(NSString *)addtime {
    _addtime=[addtime  decodeBase64];
}

- (void)setBihua:(NSString *)bihua {
    _bihua=[bihua  decodeBase64];
}

- (void)setChannel:(NSString *)channel {
    _channel=[channel  decodeBase64];
}

- (void)setLanguage:(NSString *)language {
    _language=[language  decodeBase64];
}

-(void)setMovie:(NSString *)movie {
    _movie=[movie  decodeBase64];
}

- (void)setNewsong:(NSString *)newsong {
    _newsong=[newsong  decodeBase64];
}

- (void)setNumber:(NSString *)number {
    _number=[number  decodeBase64];
}

- (void)setPathid:(NSString *)pathid {
    _pathid=[pathid  decodeBase64];
    
}

- (void)setSex:(NSString *)sex {
    _sex=[sex decodeBase64];
    
}

- (void)setSinger:(NSString *)singer {
    _singer=[singer  decodeBase64];
    
}

- (void)setSinger1:(NSString *)singer1 {
    _singer1=[singer1  decodeBase64];
    
}

- (void)setSongname:(NSString *)songname {
    _songname=[songname  decodeBase64];
    
}

- (void)setSongpiy:(NSString *)songpiy {
    _songpiy=[songpiy  decodeBase64];
    
}


- (void)setSpath:(NSString *)spath {
    _spath=[spath  decodeBase64];
    
}

- (void)setStype:(NSString *)stype {
    _stype=[stype  decodeBase64];
    
}

- (void)setVolume:(NSString *)volume {
    _volume=[volume  decodeBase64];
    
}

- (void)setWord:(NSString *)word {
    _word=[word  decodeBase64];
}


- (void)insertSongToCollectionTable:(void(^)(BOOL complete))actionCompleted{
    __block __weak typeof (self) weakSelf=self;
    NSString *querySqlStr=[NSString stringWithFormat:@"select * from CollectionTable where number='%@'",[_number encodeBase64]];
    FMResultSet *rs=[[DataMananager instanceShare].db executeQuery:querySqlStr];
    while ([rs next]) {
        if ([self.delegate respondsToSelector:@selector(addSongToCollection:result:)]) {
            [self.delegate addSongToCollection:weakSelf result:KMessageStyleInfo];
        }
        if (actionCompleted) {
            actionCompleted(YES);
        }
        return;
    }
    NSString *insertSql1= [NSString stringWithFormat:@"INSERT INTO CollectionTable (number,songname,singer,singer1,songpiy,word,language,volume,channel,sex,stype,newsong,movie,pathid,bihua,addtime,spath)VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",[_number encodeBase64],[_songname encodeBase64],[_singer encodeBase64],[_singer1 encodeBase64],[_songpiy encodeBase64],[_word encodeBase64],[_language encodeBase64],[_volume encodeBase64],[_channel encodeBase64],[_sex encodeBase64],[_stype encodeBase64],[_newsong encodeBase64],[_movie encodeBase64],[_pathid encodeBase64],[_bihua encodeBase64],[_addtime encodeBase64],[_spath encodeBase64]];
    if (![[DataMananager instanceShare].db executeUpdate:insertSql1]) {
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
    NSString *insertSql1= [NSString stringWithFormat:@"delete from CollectionTable where number='%@'",[_number encodeBase64]];
    __block __weak typeof (self) weakSelf=self;
    if (![[DataMananager instanceShare].db executeUpdate:insertSql1]) {
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
            dispatch_sync(dispatch_get_main_queue(), ^{
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
@end
