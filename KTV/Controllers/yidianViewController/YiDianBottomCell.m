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
#import "DataMananager.h"
#import "AppDelegate.h"
@interface YiDianBottomCell ()

@end

@implementation YiDianBottomCell

- (void)awakeFromNib {
    // Initialization code
 
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGSize size=self.contentView.bounds.size;
    NSArray *btns=@[_collectionrec,_priority,_cutsong,_remove];
    float width=size.width/btns.count;
    float x=0.0;
    for (int i=0;i<btns.count;i++) {
        UIButton *oneButton=btns[i];
        oneButton.frame=CGRectMake(x+(width*i), 0, size.width,size.height);
        NSLog(@"%@",NSStringFromCGRect(oneButton.frame));
    }
}

- (IBAction)clicked_priority:(id)sender {
    //1.search order table
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


- (IBAction)clicked_cutsong:(id)sender {
    [_oneSong cutSong:^(BOOL complete) {
        
    }];
}

- (IBAction)removeSong:(id)sender {
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


- (IBAction)clicked_collection:(id)sender {
    [_oneSong insertSongToCollectionTable:^(BOOL complete) {
        
    }];
}

@end
