//
//  paiHangBottomCell.m
//  KTV
//
//  Created by admin on 15/10/20.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import "paiHangBottomCell.h"
#import "CommandControler.h"
#import "NSString+Utility.h"
#import "DataMananager.h"
#import "AppDelegate.h"
@interface paiHangBottomCell ()
@property (strong, nonatomic)UIButton *collectionrec;
@property (strong, nonatomic)UIButton *priority;
@end

@implementation paiHangBottomCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
            [self initViewContent];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize cellSize=self.bounds.size;
    _collectionrec.frame=CGRectMake((cellSize.width/2-80)/2,0, 80, cellSize.height);
    _priority.frame=CGRectMake((cellSize.width/2-80)/2+cellSize.width/2,0, 80, cellSize.height);
}


- (void)initViewContent {
    _collectionrec=[[UIButton alloc]initWithFrame:CGRectZero];
    [_collectionrec setTitle:NSLocalizedString(@"collect", nil) forState:UIControlStateNormal];
    [_collectionrec setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];
    [_collectionrec setImage:[UIImage imageNamed:@"collection_bt"] forState:UIControlStateNormal];
    [_collectionrec.titleLabel sizeToFit];
    
    _priority=[[UIButton alloc]initWithFrame:CGRectZero];
    [_priority setTitle:NSLocalizedString(@"top", nil) forState:UIControlStateNormal];
    [_priority setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];
    [_priority setImage:[UIImage imageNamed:@"priority_bt"] forState:UIControlStateNormal];
    [_priority.titleLabel sizeToFit];
    
    
    [_collectionrec addTarget:self action:@selector(clicked_collection:) forControlEvents:UIControlEventTouchUpInside];
    [_priority addTarget:self action:@selector(clicked_priority:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_collectionrec];
    [self addSubview:_priority];
}


- (void)clicked_collection:(id)sender {
//    [_oneSong insertSongToCollectionTable:^(BOOL actionCompleted) {
//        if (actionCompleted) {
//            _collectionrec.enabled=YES;
//        }
//    }];
        __block __weak typeof (self) weakSelf=self;
        NSString *querySqlStr=[NSString stringWithFormat:@"select * from CollectionTable where number='%@'",[_oneSong.number encodeBase64]];
        FMResultSet *rs=[[DataMananager instanceShare].db executeQuery:querySqlStr];
        while ([rs next]) {
            if ([_delegate respondsToSelector:@selector(addSongToCollectionResult:)]) {
                [_delegate addSongToCollectionResultKMessageStyleInfo];
            }
            if (actionCompleted) {
                actionCompleted(YES);
            }
            return;
        }

}

- (void)insertSongToCollectionTable:(void(^)(BOOL actionCompleted))actionCompleted{
//    __block __weak typeof (self) weakSelf=self;
//    NSString *querySqlStr=[NSString stringWithFormat:@"select * from CollectionTable where number='%@'",[_oneSong.number encodeBase64]];
//    FMResultSet *rs=[[DataMananager instanceShare].db executeQuery:querySqlStr];
//    while ([rs next]) {
//        if ([_delegate respondsToSelector:@selector(addSongToCollection:result:)]) {
//            [_delegate addSongToCollection:weakSelf result:KMessageStyleInfo];
//        }
//        if (actionCompleted) {
//            actionCompleted(YES);
//        }
//        return;
//    }
//    NSString *insertSql1= [NSString stringWithFormat:@"INSERT INTO CollectionTable (number,songname,singer,singer1,songpiy,word,language,volume,channel,sex,stype,newsong,movie,pathid,bihua,addtime,spath)VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",[_number encodeBase64],[_songname encodeBase64],[_singer encodeBase64],[_singer1 encodeBase64],[_songpiy encodeBase64],[_word encodeBase64],[_language encodeBase64],[_volume encodeBase64],[_channel encodeBase64],[_sex encodeBase64],[_stype encodeBase64],[_newsong encodeBase64],[_movie encodeBase64],[_pathid encodeBase64],[_bihua encodeBase64],[_addtime encodeBase64],[_spath encodeBase64]];
//    if (![[DataMananager instanceShare].db executeUpdate:insertSql1]) {
//        NSLog(@"插入失败1");
//        if ([self.delegate respondsToSelector:@selector(addSongToCollection:result:)]) {
//            [self.delegate addSongToCollection:weakSelf result:KMessageWarning];
//        }
//    } else {
//        if ([self.delegate respondsToSelector:@selector(addSongToCollection:result:)]) {
//            [self.delegate addSongToCollection:weakSelf result:KMessageSuccess];
//        }
//    }
//    if (actionCompleted) {
//        actionCompleted(YES);
//    }
}



- (void)clicked_priority:(id)sender {
    if (_priority.enabled) {
        _priority.enabled=NO;
        [_oneSong diangeToTop:^(BOOL actionCompleted) {
            if (actionCompleted) {
                _priority.enabled=YES;
            }
        }];
    }

}

@end
