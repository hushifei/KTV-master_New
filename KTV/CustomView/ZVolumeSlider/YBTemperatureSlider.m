//
//  YBTemperatureSlider.m
//  iAir
//
//  Created by Fuxp on 15/7/21.
//  Copyright (c) 2015年 epro. All rights reserved.
//

#import "YBTemperatureSlider.h"

#define MIN_WIDTH   20
#define MAX_WIDTH   40
#define MID_WIDTH   ((MIN_WIDTH + MAX_WIDTH) / 2.0)

typedef enum {
    SubLayerStateNormal,
    SubLayerStateSub,
    SubLayerStateCurrent
}SubLayerState;

@interface YBTemperatureSliderSubLayer : CALayer
@property (nonatomic, strong) CALayer *lineLayer;
@property (nonatomic, strong) CATextLayer *textLayer;
@property (nonatomic, assign) SubLayerState state;
@end

@implementation YBTemperatureSliderSubLayer

- (instancetype)init
{
    self = [super init] ;
    if (self)
    {
        [self setupContent];
    }
    return self;
}

- (void)setState:(SubLayerState)state
{
    _state = state;
    
    switch (state)
    {
        case SubLayerStateCurrent:
            self.lineLayer.bounds = CGRectMake(0, 0, MAX_WIDTH, 1);
            self.textLayer.opacity = 1;
            break;
        case SubLayerStateSub:
            self.lineLayer.bounds = CGRectMake(0, 0, MID_WIDTH, 1);
            self.textLayer.opacity = 0;
            break;
        case SubLayerStateNormal:
            self.lineLayer.bounds = CGRectMake(0, 0, MIN_WIDTH, 1);
            self.textLayer.opacity = 0;
            break;
        default:
            break;
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.lineLayer.frame = CGRectMake(self.bounds.size.width - MIN_WIDTH, self.bounds.size.height / 2, MIN_WIDTH, 1);
    self.textLayer.frame = CGRectMake(self.bounds.size.width - MAX_WIDTH - 20, 0, 20, self.bounds.size.height);
}

- (void)setupContent
{
    self.lineLayer = [CALayer layer];
    self.lineLayer.contentsScale = [UIScreen mainScreen].scale;
    self.lineLayer.anchorPoint = CGPointMake(1, 0.5);
    self.lineLayer.backgroundColor = [UIColor blackColor].CGColor;
    [self addSublayer:self.lineLayer];
    
    self.textLayer = [CATextLayer layer];
    self.textLayer.contentsScale = [UIScreen mainScreen].scale;
    self.textLayer.foregroundColor = [UIColor grayColor].CGColor;
    self.textLayer.fontSize = 10;
    self.textLayer.opacity = 0;
    [self addSublayer:self.textLayer];
}
@end

#define COUNT   15
#define HEIGHT  10

@implementation YBTemperatureSlider
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.enabled = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    for (NSInteger i = 0; i < COUNT; i++)
    {
        YBTemperatureSliderSubLayer *layer = [YBTemperatureSliderSubLayer layer];
        layer.frame = CGRectMake(0, i * HEIGHT, self.bounds.size.width, HEIGHT);
        layer.textLayer.string = [NSString stringWithFormat:@"%ld°",(long)(i + COUNT + 1)];
        [self.layer addSublayer:layer];
    }
}

- (void)moveLayerWithY:(CGFloat)y
{
    NSInteger index;
    if (y <= 0)
    {
        index = 0;
    }
    else if (y >= self.bounds.size.height)
    {
        index = COUNT - 1;
    }
    else
    {
        index = (NSInteger)(y / HEIGHT);
    }
    YBTemperatureSliderSubLayer *layer = self.layer.sublayers[index];
    layer.state = SubLayerStateCurrent;
    NSInteger lastIndex = index - 1, nextIndex = index + 1;
    if (lastIndex >= 0)
    {
        YBTemperatureSliderSubLayer *ll = self.layer.sublayers[lastIndex];
        ll.state = SubLayerStateSub;
    }
    if (nextIndex <= COUNT - 1)
    {
        YBTemperatureSliderSubLayer *nl = self.layer.sublayers[nextIndex];
        nl.state = SubLayerStateSub;
    }
    for (NSInteger i = 0; i < COUNT ; i++)
    {
        if (i != index && i != lastIndex && i != nextIndex)
        {
            YBTemperatureSliderSubLayer *layer = self.layer.sublayers[i];
            layer.state = SubLayerStateNormal;
        }
    }
    self.currentValue = index + COUNT + 1;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.enabled)
    {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self moveLayerWithY:point.y];
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderDidDrag:)])
    {
        [self.delegate sliderDidDrag:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.enabled)
    {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self moveLayerWithY:point.y];
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderDidDrag:)])
    {
        [self.delegate sliderDidDrag:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.enabled)
    {
        return;
    }
    for (YBTemperatureSliderSubLayer *layer in self.layer.sublayers)
    {
        layer.state = SubLayerStateNormal;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderDidEndDrag:)])
    {
        [self.delegate sliderDidEndDrag:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.enabled)
    {
        return;
    }
    for (YBTemperatureSliderSubLayer *layer in self.layer.sublayers)
    {
        layer.state = SubLayerStateNormal;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderDidEndDrag:)])
    {
        [self.delegate sliderDidEndDrag:self];
    }
}
@end
