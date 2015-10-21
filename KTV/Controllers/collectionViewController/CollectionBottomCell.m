//
//  CollectionBottomCell.m
//  KTV
//
//  Created by stevenhu on 15/5/12.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import "CollectionBottomCell.h"
#import "CommandControler.h"
@implementation CollectionBottomCell

- (void)awakeFromNib {
    _collectBtn.titleLabel.text=NSLocalizedString(@"collect", nil);
    _cancelBtn.titleLabel.text=NSLocalizedString(@"cancel", nil);

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)clicked_cancelCollection:(id)sender {
    [_oneSong deleteSongFromCollectionTable:^(BOOL complete) {
        
    }];
}

- (IBAction)clicked_priory:(id)sender {
    [_oneSong diangeToTop:^(BOOL complete) {
        
    }];
}

- (IBAction)clicked_cutSong:(id)sender {
    [_oneSong cutSong:^(BOOL complete) {
        
    }];
}

@end
