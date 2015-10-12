//
//  ZVolumeSlide.m
//  AppTestSlide
//
//  Created by ZStart on 13-8-16.
//  Copyright (c) 2013年 ZStart. All rights reserved.
//

#import "ZVolumeSlide.h"

@implementation ZVolumeSlide

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor]; //背景颜色设置，设置为clearColor 背景透明
        
        _width = frame.size.width;
        _height= frame.size.height;
        
        UIView *view = [[UIView alloc]initWithFrame:self.bounds];
        view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ZVolumeSlide_volumeCell1.png"]];
        [self addSubview:view];
        
        
        
        _processView = [[UIView alloc]init];
        _processView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ZVolumeSlide_volumeCell2.png"]];
        _processView.frame = CGRectMake(0, 0, _width * .8, _height);
        
        [self addSubview:_processView];
        
        _slideView = [[UISlider alloc]initWithFrame:self.bounds];
        _slideView.value = 0.8;
        _slideView.maximumValue = 1.0;
        _slideView.minimumValue = 0.0;
        
        [_slideView setMaximumTrackImage:[UIImage imageNamed:@"ZVolumeSlide_clearBack"] forState:UIControlStateNormal];
        [_slideView setMinimumTrackImage:[UIImage imageNamed:@"ZVolumeSlide_clearBack"] forState:UIControlStateNormal];
        
        [_slideView addTarget:self action:@selector(slideValueChanged) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_slideView];
    }
    return self;
}
- (void) setSlideValue:(NSNumber*) value{
    _slideView.value = [value floatValue];
    [self slideValueChanged];
}

- (void) slideValueChanged {
//    CGFloat value = _slideView.value;
    _processView.frame = CGRectMake(0, 0, _width * _slideView.value, _height);
  int newValue=(int)(_slideView.value *15.0);
    if (((int)_slideView.value)==newValue) return;
   __weak typeof(self) weakself=self;
    if ([_delegate respondsToSelector:@selector(slideValueChange:slider:)]) {
        [_delegate slideValueChange:[NSNumber numberWithInt:newValue] slider:weakself];
    }


}
@end
