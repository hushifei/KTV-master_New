//
//  ZVolumeSlide.h
//  AppTestSlide
//
//  Created by ZStart on 13-8-16.
//  Copyright (c) 2013年 ZStart. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZVolumeSlide;
@protocol ZVolumeSlideDelegate <NSObject>

- (void) slideValueChange:(NSNumber*) value slider:(ZVolumeSlide*)slider;

@end


@interface ZVolumeSlide : UIView
@property (weak, nonatomic) id<ZVolumeSlideDelegate>delegate;
@property (strong, nonatomic) UISlider  *slideView;
@property (strong, nonatomic) UIView    *processView;
@property (nonatomic,assign)  CGFloat width;
@property (nonatomic,assign)  CGFloat height;


- (void) setSlideValue:(NSNumber*) value;
- (void) slideValueChanged;
- (id)initWithFrame:(CGRect)frame;
@end
