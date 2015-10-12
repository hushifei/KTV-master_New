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

- (IBAction)clicked_priority:(id)sender {
    //1.search order table
    if (self.orderID==nil) return;
    CommandControler *cmd=[[CommandControler alloc]init];
    [cmd sendCmd_moveSongToTop:self.orderID];
    if ([_oneSong.delegate respondsToSelector:@selector(dingGeFromCollection:result:)]) {
        [_oneSong.delegate dingGeFromCollection:_oneSong result:KMessageSuccess];
    }
    //    NSString *order_sqlStr= [NSString stringWithFormat:@"select * from OrderTable"];
    //    FMResultSet *order_rs=[[Utility instanceShare].db executeQuery:order_sqlStr];
    //    Order *oneOrder=[[Order alloc]init];
    //    while ([order_rs next]) {
    //        oneOrder.number = [order_rs stringForColumn:@"number"];
    //        NSLog(@"%@===>%@",oneOrder.number,_oneSong.number);
    //        oneOrder.rcid = [order_rs stringForColumn:@"rcid"];
    //        oneOrder.ordername = [order_rs stringForColumn:@"ordername"];
    //        if ([oneOrder.number isEqualToString:_oneSong.number]) {
    //            CommandControler *cmd=[[CommandControler alloc]init];
    //            [cmd sendCmd_moveSongToTop:oneOrder.ordername];
    //            if ([_oneSong.delegate respondsToSelector:@selector(dingGeFromCollection:result:)]) {
    //                [_oneSong.delegate dingGeFromCollection:_oneSong result:KMessageSuccess];
    //            }
    //            break;
    //        }
    //    }
    //
}


- (IBAction)clicked_cutsong:(id)sender {
    [_oneSong cutSong];
}

- (IBAction)removeSong:(id)sender {
    //1.search order table
    NSString *order_sqlStr= [NSString stringWithFormat:@"select * from OrderTable"];
    FMResultSet *order_rs=[[DataMananager instanceShare].db executeQuery:order_sqlStr];
    Order *oneOrder=[[Order alloc]init];
    while ([order_rs next]) {
        oneOrder.number = [order_rs stringForColumn:@"number"];
        oneOrder.rcid = [order_rs stringForColumn:@"rcid"];
        oneOrder.ordername = [order_rs stringForColumn:@"ordername"];
        if ([oneOrder.number isEqualToString:_oneSong.number]) {
            CommandControler *cmd=[[CommandControler alloc]init];
            [cmd sendCmd_remove_yidian:oneOrder.ordername];
            if ([_delegate respondsToSelector:@selector(removeFromYidian:result:)]) {
                [_delegate removeFromYidian:_oneSong result:KMessageSuccess];
            }
            break;
        }
    }
    
}


- (IBAction)clicked_collection:(id)sender {
    [_oneSong insertSongToCollectionTable];
}

@end
