//
//  AdjustSoundArray.h
//  KTV
//
//  Created by stevenhu on 15/9/16.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import <Foundation/Foundation.h>
 typedef enum  {
    mic_sound=0,
    music_sound
}adjustType;
@interface AdjustSoundArray : NSMutableArray
@property(nonatomic,assign)adjustType type;
@end
