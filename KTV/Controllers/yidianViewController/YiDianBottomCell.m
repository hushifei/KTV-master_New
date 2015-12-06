//
//  YiDianBottomCell.m
//  KTV
//
//  Created by stevenhu on 15/5/16.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import "YiDianBottomCell.h"
#import "CommandControler.h"
#import "Order.h"
#import "DataManager.h"
#import "AppDelegate.h"
@interface YiDianBottomCell ()

@end

@implementation YiDianBottomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViewContent];
    }
    return self;
}


- (void)initViewContent {
    _collectionrec=[[UIButton alloc]initWithFrame:CGRectZero];
    [_collectionrec setImage:[UIImage imageNamed:@"collection_bt"] forState:UIControlStateNormal];
    [_collectionrec setTitle:@"收藏" forState:UIControlStateNormal];
    [_collectionrec addTarget:self action:@selector(clicked_collection:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _priority=[[UIButton alloc]initWithFrame:CGRectZero];
    [_priority setImage:[UIImage imageNamed:@"priority_bt"] forState:UIControlStateNormal];
    [_priority setTitle:@"优先" forState:UIControlStateNormal];

    [_priority addTarget:self action:@selector(clicked_priority:) forControlEvents:UIControlEventTouchUpInside];

    
    _remove=[[UIButton alloc]initWithFrame:CGRectZero];
    [_remove setImage:[UIImage imageNamed:@"remove_yidian"] forState:UIControlStateNormal];
    [_remove setTitle:@"移除" forState:UIControlStateNormal];
    
    [_remove addTarget:self action:@selector(removeSong:) forControlEvents:UIControlEventTouchUpInside];

    
    [self.contentView addSubview:_collectionrec];
    [self.contentView addSubview:_priority];
    [self.contentView addSubview:_remove];


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size=self.contentView.bounds.size;
    NSArray *btns=@[_collectionrec,_priority,_remove];
    float width=size.width/btns.count;
    for (int i=0;i<btns.count;i++) {
        UIButton *oneButton=btns[i];
        oneButton.frame=CGRectMake(width*i, 0, width,size.height);
        NSLog(@"%@",NSStringFromCGRect(oneButton.frame));
    }
}



- (void)clicked_priority:(id)sender {
    //1.search order tableDemoTableViewController
    if ([Utility instanceShare].netWorkStatus) {
    if (self.orderID==nil) return;
    CommandControler *cmd=[[CommandControler alloc]init];
     [cmd sendCmd_moveSongToTop:_orderID completed:^(BOOL completed, NSError *error) {
         if (completed) {
             if ([_oneSong.delegate respondsToSelector:@selector(dingGeFromCollection:result:)]) {
                 [_oneSong.delegate dingGeFromCollection:_oneSong result:KMessageSuccess];
             }
         }
     }];
} else {
    [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
}
}


- (void)clicked_cutsong:(id)sender {
    [_oneSong cutSong:^(BOOL complete) {
    }];
}

- (void)removeSong:(id)sender {
    if ([Utility instanceShare].netWorkStatus) {
    CommandControler *cmd=[[CommandControler alloc]init];
    [cmd sendCmd_remove_yidian:_orderID completed:^(BOOL completed, NSError *error) {
        if (completed) {
            if ([_delegate respondsToSelector:@selector(removeFromYidian:result:)]) {
                [_delegate removeFromYidian:_oneSong result:KMessageSuccess];
            }
        } else {
            //network error
        }
    }];
    } else {
        [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
    }
}


- (void)clicked_collection:(id)sender {
    [_oneSong insertSongToCollectionTable:^(BOOL complete) {
        
    }];
}

@end
