//
//  songTableViewCell.m
//  KTV
//
//  Created by stevenhu on 15/4/18.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//
#import "SongBottomCell.h"
#import "CommandControler.h"
@interface SongBottomCell ()
@property (weak, nonatomic) IBOutlet UIButton *collectionrec;
@property (weak, nonatomic) IBOutlet UIButton *priority;
@property (weak, nonatomic) IBOutlet UIButton *cutsong;

@end


@implementation SongBottomCell

- (void)awakeFromNib {
    [_collectionrec setTitle:NSLocalizedString(@"collect", nil) forState:UIControlStateNormal];
    [_priority setTitle:NSLocalizedString(@"top", nil) forState:UIControlStateNormal];

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (IBAction)clicked_collection:(id)sender {
    [_oneSong insertSongToCollectionTable:^(BOOL complete) {
        
    }];
}


- (IBAction)clicked_priority:(id)sender {
    
    [_oneSong diangeToTop:^(BOOL complete) {
        
    }];
}

- (IBAction)clicked_cutsong:(id)sender {
    [_oneSong cutSong:^(BOOL complete) {
        
    }];
}


//
//- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *view=[super hitTest:point withEvent:event];
//    if (view) {
//       return  nil;
//    }
//    return view;
//}



@end
