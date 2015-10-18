//
//  ZVolumeSlide.h
//  AppTestSlide
//
//  Created by ZStart on 13-8-16.
//  Copyright (c) 2013年 ZStart. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger,SliderType) {
    IS_MIC_TYPE = 0,
    is_MUSIC_TYPE
};


@class ZVolumeSlide;
@protocol ZVolumeSlideDelegate <NSObject>
- (void)sliderDidEndDrag:(NSNumber*)value slider:(ZVolumeSlide*)slider;
@end


@interface ZVolumeSlide : UIView
@property (weak, nonatomic) id<ZVolumeSlideDelegate>delegate;
@property (strong, nonatomic) UISlider  *slideView;
@property (strong, nonatomic) UIView    *processView;
@property (nonatomic,assign)  CGFloat width;
@property (nonatomic,assign)  CGFloat height;
@property (nonatomic,strong) CAShapeLayer *processLayer;



- (void) slideValueChanged;
- (instancetype)initWithFrame:(CGRect)frame type:(SliderType)sliderType;
@end
