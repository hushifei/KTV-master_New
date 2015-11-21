//
//  SHBQRView.m
//  QRCode_Demo
//
//  Created by 沈红榜 on 15/11/17.
//  Copyright © 2015年 沈红榜. All rights reserved.
//

#import "SHBQRView.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SHBQRView ()<AVCaptureMetadataOutputObjectsDelegate>

@end

@implementation SHBQRView {
    AVCaptureSession *_session;
    
    UIImageView     *_scanView;
    UIImageView     *_lineView;
    UIButton        *_cancelBtn;
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)cancelBtn_Clicked:(id)sender {
    if ([_delegate respondsToSelector:@selector(cancelQrView:)]) {
        [self stopScan];
        __weak typeof(self) weakSelf=self;
        [_delegate cancelQrView:weakSelf];
    }
}

- (void)initView {
    UIImage *scanImage = [UIImage imageNamed:@"scanscanBg"];
//    UIImage *scanImage = [UIImage imageNamed:@"pick_bg"];

    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    CGFloat scanW = 220;
    
    CGRect scanFrame = CGRectMake(width / 2. - scanW / 2. , height / 2. - scanW / 2., scanW, scanW);
    _scanViewFrame = scanFrame;
    
    
    _scanView = [[UIImageView alloc] initWithImage:scanImage];
    _scanView.backgroundColor = [UIColor clearColor];
    _scanView.frame = scanFrame;
    [self addSubview:_scanView];
    
    //cancel Button
//    float cancelBtnWidth=_scanView.bounds.size.width/2.;
//    float x=_scanView.center.x-(cancelBtnWidth/2);
//    float cancelBtnHeight=40.;
//    _cancelBtn=[[UIButton alloc]initWithFrame:CGRectMake(x, CGRectGetMaxY(_scanView.frame)+40, cancelBtnWidth, cancelBtnHeight)];
//    [_cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
//    [_cancelBtn addTarget:self action:@selector(cancelBtn_Clicked:) forControlEvents:UIControlEventTouchUpInside];
//    [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancel_bt_bg"] forState:UIControlStateNormal];
//    [self addSubview:_cancelBtn];
    
    // 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //闪光灯
    if ([device hasFlash] && [device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setFlashMode:AVCaptureFlashModeAuto];
        [device setTorchMode:AVCaptureTorchModeAuto];
        [device unlockForConfiguration];
    }
    
    //创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    //创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    //设置代理 刷新线程
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
//    output.rectOfInterest = [self turnRect:_scanZomeBack.frame];
    output.rectOfInterest = [self rectOfInterestByScanViewRect:_scanView.frame];
    // 初始化链接对象
    _session = [[AVCaptureSession alloc] init];
    
    //采集率
    _session.sessionPreset = AVCaptureSessionPresetHigh;
    
    if (input) {
        [_session addInput:input];
    }
    
    if (output) {
        [_session addOutput:output];
        
        //设置扫码支持的编码格式
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
        
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            [array addObject:AVMetadataObjectTypeQRCode];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
            [array addObject:AVMetadataObjectTypeEAN13Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
            [array addObject:AVMetadataObjectTypeEAN8Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [array addObject:AVMetadataObjectTypeCode128Code];
        }
        output.metadataObjectTypes = array;
    }
    
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.bounds;
    [self.layer insertSublayer:layer above:0];
    
    [self bringSubviewToFront:_scanView];
    [self bringSubviewToFront:_cancelBtn];
    [self setOverView];
    
    [_session startRunning];
    [self loopDrawLine];
}

- (CGRect)rectOfInterestByScanViewRect:(CGRect)rect {
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    CGFloat x = (height - CGRectGetHeight(rect)) / 2 / height;
    CGFloat y = (width - CGRectGetWidth(rect)) / 2 / width;
    
    CGFloat w = CGRectGetHeight(rect) / height;
    CGFloat h = CGRectGetWidth(rect) / width;
    
    return CGRectMake(x, y, w, h);
}

#pragma mark - 添加模糊效果
- (void)setOverView {
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    CGFloat x = CGRectGetMinX(_scanView.frame);
    CGFloat y = CGRectGetMinY(_scanView.frame);
    CGFloat w = CGRectGetWidth(_scanView.frame);
    CGFloat h = CGRectGetHeight(_scanView.frame);
    
    [self creatView:CGRectMake(0, 0, width, y)];
    [self creatView:CGRectMake(0, y, x, h)];
    [self creatView:CGRectMake(0, y + h, width, height - y - h)];
    [self creatView:CGRectMake(x + w, y, width - x - w, h)];
}

- (void)creatView:(CGRect)rect {
    CGFloat alpha = 0.5;
    UIColor *backColor = [UIColor grayColor];
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = backColor;
    view.alpha = alpha;
    [self addSubview:view];
    

}


#pragma mark - 动画
- (void)loopDrawLine {
//    UIImage *lineImage = [UIImage imageNamed:@"scanLine"];
    UIImage *lineImage = [UIImage imageNamed:@"line"];

    CGFloat x = CGRectGetMinX(_scanView.frame);
    CGFloat y = CGRectGetMinY(_scanView.frame);
    CGFloat w = CGRectGetWidth(_scanView.frame);
    CGFloat h = CGRectGetHeight(_scanView.frame);
    
    CGRect start = CGRectMake(x, y, w, 2);
    CGRect end = CGRectMake(x, y + h - 2, w, 2);
    
    if (!_lineView) {
        _lineView = [[UIImageView alloc] initWithImage:lineImage];
        _lineView.frame = start;
        [self addSubview:_lineView];
    } else {
        _lineView.frame = start;
    }
    
    __weak typeof(self) SHB = self;
    [UIView animateWithDuration:2 animations:^{
        _lineView.frame = end;
    } completion:^(BOOL finished) {
        [SHB loopDrawLine];
    }];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects firstObject];
        if ([_delegate respondsToSelector:@selector(qrView:ScanResult:)]) {
            [self stopScan];
            __weak typeof(self) weakSelf=self;
            [_delegate qrView:weakSelf ScanResult:metadataObject.stringValue];
        }
    }
}

- (void)startScan {
    [_session startRunning];
}

- (void)stopScan {
    [_session stopRunning];
}

//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
////    UITouch *touch=[touches anyObject];
////    CGPoint point=[touch locationInView:self];
////    if ([_cancelBtn pointInside:point withEvent:event]) {
////        NSLog(@"ff");
////    }
////    [self.nextResponder touchesBegan:touches withEvent:event];
//
//}

@end
