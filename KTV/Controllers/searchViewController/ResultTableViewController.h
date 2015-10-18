//
//  ResultTableViewController.h
//  ZZKTV
//
//  Created by stevenhu on 15/3/30.
//  Copyright (c) 2015年 zz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFSelectView.h"
@class Song;
@class Singer;
@protocol searchSongDelegate <NSObject>
- (void)searching;
- (void)searchDone;
- (void)clickSinger:(Singer*)singer;
- (void)clickSong:(Song*)song;

@end

enum selectSearchType{
    searchAll,
    searchSong,
    searchSinger
};

@interface ResultTableViewController : UITableViewController<UISearchResultsUpdating,UISearchBarDelegate,SelectViewOnSelectedDelegate>
@property (nonatomic,weak) id<searchSongDelegate>delegate;
@property (nonatomic,assign)enum selectSearchType searchSelectIndex;

@end
