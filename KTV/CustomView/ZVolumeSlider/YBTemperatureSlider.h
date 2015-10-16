//
//  YBTemperatureSlider.h
//  iAir
//
//  Created by Fuxp on 15/7/21.
//  Copyright (c) 2015年 epro. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YBTemperatureSlider;

@protocol YBTemperatureSliderDelegate <NSObject>

- (void)sliderDidDrag:(YBTemperatureSlider *)slider;

- (void)sliderDidEndDrag:(YBTemperatureSlider *)slider;

@end


@interface YBTemperatureSlider : UIView

@property (nonatomic, assign) NSInteger currentValue;

@property (nonatomic, weak) id<YBTemperatureSliderDelegate> delegate;

@property (nonatomic, assign) BOOL enabled;
@end
