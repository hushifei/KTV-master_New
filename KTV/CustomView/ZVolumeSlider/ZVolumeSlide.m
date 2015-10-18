//
//  ZVolumeSlide.m
//  AppTestSlide
//
//  Created by ZStart on 13-8-16.
//  Copyright (c) 2013年 ZStart. All rights reserved.
//

#import "ZVolumeSlide.h"

@implementation ZVolumeSlide

- (instancetype)initWithFrame:(CGRect)frame type:(SliderType)sliderType;
{
    if (self=[super initWithFrame:frame]) {
        _type=sliderType;
        self.backgroundColor = [UIColor clearColor]; //背景颜色设置，设置为clearColor 背景透明
        _width = frame.size.width;
        _height= frame.size.height;
        _processView = [[UIView alloc]init];
        _processView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ZVolumeSlide_volumeCell2.png"]];
        _processView.frame = CGRectMake(0, 0, _width * .8, _height);
        _processView.userInteractionEnabled=NO;
        UIBezierPath *maskPath=[UIBezierPath bezierPathWithRoundedRect:_processView.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(1, 1)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _processView.bounds;
        maskLayer.path = maskPath.CGPath;
        _processView.layer.mask=maskLayer;
        [self addSubview:_processView];
        
        _slideView = [[UISlider alloc]initWithFrame:self.bounds];
        _slideView.value = 0.0;
        _slideView.maximumValue = 1.0;
        _slideView.minimumValue = 0.0;
        
        [_slideView setMaximumTrackImage:[UIImage imageNamed:@"ZVolumeSlide_clearBack"] forState:UIControlStateNormal];
        [_slideView setMinimumTrackImage:[UIImage imageNamed:@"ZVolumeSlide_clearBack"] forState:UIControlStateNormal];
        if (_type==IS_MIC_TYPE) {
            [self initSlideValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"Mic_soundAdjust"]];
        } else {
            [self initSlideValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"Music_soundAdjust"]];
        }
        _slideView.continuous = NO;
        [_slideView addTarget:self action:@selector(slideValueChanged) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_slideView];
    }
    return self;
}

- (void)initSlideValue:(NSNumber*) value{
    if (value==nil) {
        value=[NSNumber numberWithFloat:0.0];
        if (_slideView==IS_MIC_TYPE) {
            [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"Mic_soundAdjust"];
        } else {
             [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"Music_soundAdjust"];
        }
    } else {
        if (_slideView==IS_MIC_TYPE) {
            _slideView.value=[[[NSUserDefaults standardUserDefaults]objectForKey:@"Mic_soundAdjust"]floatValue]/15;
        } else {
            _slideView.value=[[[NSUserDefaults standardUserDefaults]objectForKey:@"Music_soundAdjust"]floatValue]/15;
        }

    }
    _processView.frame = CGRectMake(0, 0, _width * _slideView.value, _height);
}


- (void)resumeSliderValue {
    float value=0.0f;
    if (_slideView==IS_MIC_TYPE) {
        value=[[[NSUserDefaults standardUserDefaults]objectForKey:@"Mic_soundAdjust"]floatValue]/15;
    } else {
        value=[[[NSUserDefaults standardUserDefaults]objectForKey:@"Music_soundAdjust"]floatValue]/15;
    }
    _slideView.value=value;
    _processView.frame = CGRectMake(0, 0, _width * _slideView.value, _height);
}

- (void)slideValueChanged {
    __weak __typeof(self) weakSelf=self;
    _processView.frame = CGRectMake(0, 0, _width * _slideView.value, _height);
    if ([_delegate respondsToSelector:@selector(sliderDidEndDrag:slider:)]) {
        [_delegate sliderDidEndDrag:[NSNumber numberWithFloat:ceilf(_slideView.value*15)] slider:weakSelf];
    }
}

//- (void)sliderDragEnd {
//    NSLog(@"%s",__PRETTY_FUNCTION__);
//}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event  {
//    NSLog(@"begin_________________");
//}
//
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSLog(@"end_________________");
//
//}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    // 当touch point是在_btn上，则hitTest返回_btn
//    CGPoint a = [_slideView convertPoint:point fromView:self];
//    if ([_slideView pointInside:a withEvent:event]) {
//        CGFloat slideWidth=_slideView.bounds.size.width;
//        _slideView.value=a.x/slideWidth;
//        _processView.frame = CGRectMake(0, 0, slideWidth * _slideView.value, _height);
//        return self;
//    }
//    // 否则，返回默认处理
//    return [super hitTest:point withEvent:event];
//}

@end
