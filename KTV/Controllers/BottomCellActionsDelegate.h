//
//  BottomCellActionsDelegate.h
//  KTV
//
//  Created by stevenhu on 15/10/20.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HuToast.h"
@protocol BottomCellActionsDelegate <NSObject>
@optional
- (void)addSongToCollectionResult:(KMessageStyle)result;
- (void)deleteCollectionSongResult:(KMessageStyle)result;
- (void)dingGeFromCollectionResult:(KMessageStyle)result;
- (void)cutSongFromCollectionResult:(KMessageStyle)result;
@end
