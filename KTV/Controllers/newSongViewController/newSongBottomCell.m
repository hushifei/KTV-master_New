//
//  newSongBottomCell.m
//  KTV
//
//  Created by admin on 15/10/21.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import "newSongBottomCell.h"
@interface newSongBottomCell ()
@property (strong, nonatomic)UIButton *collectionrec;
@property (strong, nonatomic)UIButton *priority;
@end
@implementation newSongBottomCell

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
    
    _collectionrec.titleLabel.font=[UIFont systemFontOfSize:14];
    _priority.titleLabel.font=[UIFont systemFontOfSize:14];
    
    [self addSubview:_collectionrec];
    [self addSubview:_priority];
}


- (void)clicked_collection:(id)sender {
    [_oneSong insertSongToCollectionTable:^(BOOL complete) {
        
    }];
}


- (void)clicked_priority:(id)sender {
    
    [_oneSong diangeToTop:^(BOOL complete) {
        
    }];
}

@end
