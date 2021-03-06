//
//  soundView.m
//  KTV
//
//  Created by stevenhu on 15/5/2.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import "soundView.h"
#import "Utility.h"
#import "UIImage+Utility.h"
#define WINDOW  [UIApplication sharedApplication].keyWindow
#define BOKONG_SPACE 15
#define LABEL_HEIGHT 20
#define myFont [UIFont systemFontOfSize:13];
#import "CommandControler.h"
#import "ZVolumeSlide.h"
#import "AppDelegate.h"
#import "HuToast.h"
@interface soundView () <ZVolumeSlideDelegate> {

    //three chuckview
    CGSize totoalSize;
    
    
    UIView *topChunckView;
    UIView *centerChunckView;
    UIView *bottomChunckbView;
    
    
    UIButton *switchBtn;
    UIButton *sendBtn;
    //controller
    CommandControler *cmdController;
    //top
//    jiajian
    UIImageView *playStopImageV;
    UIButton *playBtn;
    UIButton *stopbtn;
    
    //center
    UIButton *heCaiBtn;
    UIButton *daoCaiBtn;
    UIButton *mingLingBtn;
    UIButton *rouHeBtn;
    UIButton *dongGanBtn;
    UIButton *kaiGuangBtn;
    UIButton *serviceBtn;
    
    //bottm
//    UITextField *sendInput;
    AppDelegate *myAppDelegate;
    
    NSOperationQueue *mic_Queue;
    NSOperationQueue *music_Queue;
    NSUserDefaults *userDefaults;
    
    
    ZVolumeSlide *slider1;
    ZVolumeSlide *slider2;
    
    
}

@end

@implementation soundView


- (id)initWithFrame:(CGRect)frame   {
    if (self=[super initWithFrame:frame]) {
        myAppDelegate =(AppDelegate*)[UIApplication sharedApplication].delegate;
        self.backgroundColor=[UIColor groupTableViewBackgroundColor];
        totoalSize=self.bounds.size;
        self.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"songsList_bg"]];
        [self createChunckViews];
        cmdController=[[CommandControler alloc]init];
        mic_Queue=[[NSOperationQueue alloc]init];
        music_Queue=[[NSOperationQueue alloc]init];
        userDefaults=[NSUserDefaults standardUserDefaults];

    }
    return self;
}

//create chunck
- (void)createChunckViews {
    CGFloat centerY = 0.0;
    CGFloat centerYChunk = 0.0;
    CGFloat bottomX = 0.0;
    if (IS_IPHONE_4_OR_LESS) {
        centerY = 30.0;
        centerYChunk = 25.0;
        bottomX = 27.0;
    }
    //topChunkView
    topChunckView=[[UIView alloc]initWithFrame:CGRectMake(0,0,totoalSize.width,120)];
    [self addSubview:topChunckView];
    
    //centerchunck
    centerChunckView=[[UIView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(topChunckView.frame)-centerY,totoalSize.width, totoalSize.height/3)];
//        centerChunckView.backgroundColor=[UIColor redColor];
    [self addSubview:centerChunckView];

    //bottomChunkView
    bottomChunckbView=[[UIView alloc]initWithFrame:CGRectMake(0+bottomX,CGRectGetMaxY(centerChunckView.frame)+centerY-centerYChunk+15, totoalSize.width,centerChunckView.bounds.size.height-44)];
    
//    bottomChunckbView.backgroundColor=[UIColor blueColor];
    [self addSubview:bottomChunckbView];
    
    [self createViewsForAllChuncks];
    
}

//create up

- (void)createViewsForAllChuncks {

    playStopImageV=[[UIImageView alloc]init];
    playBtn=[[UIButton alloc]init];
    stopbtn=[[UIButton alloc]init];
    CGSize topChuckSize=centerChunckView.bounds.size;
    CGSize centerChuckSize=bottomChunckbView.bounds.size;
    
    heCaiBtn=[[UIButton alloc]init];
    daoCaiBtn=[[UIButton alloc]init];
    mingLingBtn=[[UIButton alloc]init];
    rouHeBtn=[[UIButton alloc]init];
    dongGanBtn=[[UIButton alloc]init];
    kaiGuangBtn=[[UIButton alloc]init];
    serviceBtn=[[UIButton alloc]init];
    

    //====topChunck SubViews
    float oneWidth=(WINDOW.bounds.size.width-BOKONG_SPACE)/4-BOKONG_SPACE*1.5;
    NSArray *strArray=@[NSLocalizedString(@"vocalonoff", nil),NSLocalizedString(@"nextsong", nil),NSLocalizedString(@"pauseplay", nil),NSLocalizedString(@"replay", nil)];
    NSMutableArray *btnArray=[[NSMutableArray alloc]init];
    for (int i=0;i<4;i++) {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame=CGRectMake(BOKONG_SPACE*(i+1)+i*oneWidth+15,BOKONG_SPACE+10,oneWidth,oneWidth);
        button.tag=i;
        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"bokong%d",i]] forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(bokongBtn_clicked:) forControlEvents:UIControlEventTouchUpInside];
        [topChunckView addSubview:button];
        
        UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(button.frame.origin.x, CGRectGetMaxY(button.frame),button.bounds.size.width+10,(LABEL_HEIGHT))];
        lable.text=strArray[i];
        lable.font=myFont;
        CGSize size=[lable.text boundingRectWithSize:CGSizeMake(lable.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:lable.font} context:nil].size;
        CGRect labelRect=lable.frame;
        labelRect.size.height=size.height;
        lable.frame=labelRect;
        lable.numberOfLines=0;
        lable.textAlignment=NSTextAlignmentCenter;
        lable.textColor=[UIColor whiteColor];
        [topChunckView addSubview:lable];
        [btnArray addObject:lable];
        
    }
    slider1=[[ZVolumeSlide alloc]initWithFrame:CGRectMake(-12,(topChuckSize.height-60)/2,topChuckSize.height-60, 23)type:0];
    CGRect newRect=slider1.frame;
    if (IS_IPHONE_4_OR_LESS) {
        newRect.origin.x+=32;
        newRect.origin.y+=10;
    } else if(IS_IPHONE_5) {
      newRect.origin.x+=26;
    } else if (IS_IPHONE_6) {
        
    } else if (IS_IPHONE_6P) {
        
    }
    slider1.frame=newRect;
    slider1.backgroundColor=[UIColor clearColor];
    slider1.layer.transform=CATransform3DMakeRotation(M_PI_2+M_PI, 0, 0, 1);
    slider1.delegate = self;

    //    //给图层添加一个有色边
      //imageview
    float ImageViewmaxWidth=MIN(topChuckSize.height, topChuckSize.width/3);
    
    playStopImageV.frame=CGRectMake(topChuckSize.width/3+(topChuckSize.width/3-(ImageViewmaxWidth-15))/2, topChuckSize.height/2-ImageViewmaxWidth/2, ImageViewmaxWidth-15,ImageViewmaxWidth-15);
    playStopImageV.image=[UIImage imageNamed:@"stopstart"];
    
    //静音／正常
    playBtn.frame = CGRectMake(topChuckSize.width/3+(topChuckSize.width/3-(ImageViewmaxWidth-15))/2, topChuckSize.height/2-ImageViewmaxWidth/2, CGRectGetWidth(playStopImageV.frame)/2-5,CGRectGetHeight(playStopImageV.frame));
//    [playBtn addTarget:self action:@selector(mute_clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    stopbtn.frame = CGRectMake(CGRectGetMaxX(playBtn.frame)+15, topChuckSize.height/2-ImageViewmaxWidth/2, CGRectGetWidth(playStopImageV.frame)/2-10,CGRectGetHeight(playStopImageV.frame));
//    [stopbtn addTarget:self action:@selector(unmute_clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    slider2=[[ZVolumeSlide alloc]initWithFrame:CGRectMake(CGRectGetMinX([[btnArray lastObject] frame])-40, (topChuckSize.height-60)/2,topChuckSize.height-60, 23) type:1];
    if (IS_IPHONE_4_OR_LESS) {
        CGRect newRect=slider2.frame;
        newRect.origin.x+=25;
        newRect.origin.y+=10;
        slider2.frame=newRect;
    } else if (IS_IPHONE_5) {
        
    } else if (IS_IPHONE_6) {
        
    } else if (IS_IPHONE_6P) {
        
    }

    slider2.backgroundColor=[UIColor clearColor];
    slider2.delegate = self;
    slider2.layer.transform=CATransform3DMakeRotation(M_PI_2+M_PI, 0, 0, 1);
    
    UILabel *micLabel=[[UILabel alloc]initWithFrame:CGRectMake(slider1.frame.origin.x/2, CGRectGetMaxY(slider1.frame), 80, 22)];
    if ([Utility instanceShare].myIphoneModel==isiPhone4s) {
        CGRect newRect=micLabel.frame;
        newRect.origin.y+=10;
        micLabel.frame=newRect;
    }
    micLabel.text=NSLocalizedString(@"microphone", nil);
    micLabel.textAlignment=NSTextAlignmentCenter;
    micLabel.font=myFont;
    micLabel.textColor=[UIColor groupTableViewBackgroundColor];
    
    UILabel *muteLabel=[[UILabel alloc]initWithFrame:CGRectMake(playStopImageV.frame.origin.x,micLabel.frame.origin.y, playStopImageV.bounds.size.width, slider1.bounds.size.height)];
    muteLabel.text=NSLocalizedString(@"mute", nil);
    muteLabel.textAlignment=NSTextAlignmentCenter;
    muteLabel.font=myFont;
    muteLabel.textColor=[UIColor groupTableViewBackgroundColor];
    
    UILabel *musicLabel=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(slider2.frame)-(60-22)/2, micLabel.frame.origin.y,60, 22)];
    musicLabel.text=NSLocalizedString(@"music", nil);
    musicLabel.textAlignment=NSTextAlignmentCenter;
    musicLabel.font=myFont;
    musicLabel.textColor=[UIColor groupTableViewBackgroundColor];
    
    [centerChunckView addSubview:micLabel];
    [centerChunckView addSubview:muteLabel];
    [centerChunckView addSubview:musicLabel];
    
    //center
    float btnMaxWidth=MIN(centerChuckSize.height/2, centerChuckSize.width/4-15);
    NSLog(@"%f",btnMaxWidth);
    heCaiBtn.frame=CGRectMake(16, 10, btnMaxWidth, btnMaxWidth);
    [heCaiBtn setBackgroundImage:[UIImage imageNamed:@"hecai_normal"]  forState:UIControlStateNormal];
    [heCaiBtn setTitle:NSLocalizedString(@"cheer", nil) forState:UIControlStateNormal];
    heCaiBtn.titleLabel.font=myFont;
    [bottomChunckbView addSubview:heCaiBtn]; //喝彩
    
    daoCaiBtn.frame=CGRectMake(CGRectGetMaxX(heCaiBtn.frame)+10, CGRectGetMinY(heCaiBtn.frame), btnMaxWidth, btnMaxWidth);
    [daoCaiBtn setBackgroundImage:[UIImage imageNamed:@"daocai_normal"] forState:UIControlStateNormal];
    [daoCaiBtn setTitle:NSLocalizedString(@"booing", nil) forState:UIControlStateNormal];
    daoCaiBtn.titleLabel.font=myFont;
    [bottomChunckbView addSubview:daoCaiBtn];//倒彩
    
    rouHeBtn.frame=CGRectMake(CGRectGetMaxX(daoCaiBtn.frame)+10, CGRectGetMinY(heCaiBtn.frame), btnMaxWidth, btnMaxWidth);
    [rouHeBtn setBackgroundImage:[UIImage imageNamed:@"rouhe_normal"] forState:UIControlStateNormal];
    [rouHeBtn setTitle:NSLocalizedString(@"soft", nil) forState:UIControlStateNormal];
    rouHeBtn.titleLabel.font=myFont;
    [bottomChunckbView addSubview:rouHeBtn];//柔和
    
    
    mingLingBtn.frame=CGRectMake(CGRectGetMaxX(rouHeBtn.frame)+10, CGRectGetMinY(heCaiBtn.frame), btnMaxWidth, btnMaxWidth);
    [mingLingBtn setBackgroundImage:[UIImage imageNamed:@"mingliang_normal"] forState:UIControlStateNormal];
    [mingLingBtn setTitle:NSLocalizedString(@"bright", nil) forState:UIControlStateNormal];
    mingLingBtn.titleLabel.font=myFont;
    [bottomChunckbView addSubview:mingLingBtn];//明亮
    
    dongGanBtn.frame=CGRectMake(CGRectGetMinX(heCaiBtn.frame), CGRectGetMaxY(heCaiBtn.frame)+10, btnMaxWidth, btnMaxWidth);
    [dongGanBtn setBackgroundImage:[UIImage imageNamed:@"donggang_normal"] forState:UIControlStateNormal];
    [dongGanBtn setTitle:NSLocalizedString(@"innervation", nil) forState:UIControlStateNormal];
    dongGanBtn.titleLabel.font=myFont;
    [bottomChunckbView addSubview:dongGanBtn];//动感

    
    kaiGuangBtn.frame=CGRectMake(CGRectGetMaxX(dongGanBtn.frame)+10, CGRectGetMinY(dongGanBtn.frame), btnMaxWidth, btnMaxWidth);
    [kaiGuangBtn setTitle:NSLocalizedString(@"switch", nil) forState:UIControlStateNormal];
    [kaiGuangBtn setBackgroundImage:[UIImage imageNamed:@"gaiguang_normal"] forState:UIControlStateNormal];
    kaiGuangBtn.titleLabel.font=myFont;
    [bottomChunckbView addSubview:kaiGuangBtn];//开关
    
    serviceBtn.frame=CGRectMake(CGRectGetMaxX(kaiGuangBtn.frame)+40, CGRectGetMinY(dongGanBtn.frame), btnMaxWidth*1.5, btnMaxWidth);
    [serviceBtn setBackgroundImage:[UIImage imageNamed:@"fuwu_normal"] forState:UIControlStateNormal];
    [serviceBtn setTitle:NSLocalizedString(@"service", nil) forState:UIControlStateNormal];
    serviceBtn.titleLabel.font=myFont;
    serviceBtn.titleEdgeInsets=UIEdgeInsetsMake(0, serviceBtn.bounds.size.width/2, 0, 0);
    [bottomChunckbView addSubview:serviceBtn];//服务
  

    [centerChunckView addSubview:slider1];
    [centerChunckView addSubview:slider2];

    [centerChunckView addSubview:playStopImageV];
    [playStopImageV addSubview:playBtn];
    [playStopImageV addSubview:stopbtn];
    UIButton *play_stop_btn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, ImageViewmaxWidth, ImageViewmaxWidth)];
    play_stop_btn.layer.cornerRadius=ImageViewmaxWidth/2;
    [play_stop_btn addTarget:self action:@selector(mute_unmute_clicked:) forControlEvents:UIControlEventTouchUpInside];
    [playStopImageV addSubview:play_stop_btn];
    playStopImageV.clipsToBounds=YES;
    playStopImageV.userInteractionEnabled=YES;
    [bottomChunckbView addSubview:heCaiBtn];
    [bottomChunckbView addSubview:daoCaiBtn];
    [bottomChunckbView addSubview:rouHeBtn];
    [bottomChunckbView addSubview:mingLingBtn];
    [bottomChunckbView addSubview:dongGanBtn];
    [bottomChunckbView addSubview:kaiGuangBtn];
    [bottomChunckbView addSubview:serviceBtn];
    
    //add event
    [heCaiBtn addTarget:self action:@selector(hecai_clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [daoCaiBtn addTarget:self action:@selector(daocai_clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [rouHeBtn addTarget:self action:@selector(rouhe_clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [mingLingBtn addTarget:self action:@selector(mingliang_clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [dongGanBtn addTarget:self action:@selector(donggang_clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [kaiGuangBtn addTarget:self action:@selector(kaiguang_clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [serviceBtn addTarget:self action:@selector(fuwu_clicked:) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - Events
//(1静音 2=放音)MUTE_SOUND
- (void)mute_unmute_clicked:(id)sender {
    if ([Utility instanceShare].netWorkStatus) {
        [cmdController sendCmd_mute_unmute:^(BOOL completed, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [HuToast showToastWithMessage:[NSString stringWithFormat:@"    %@ ",([userDefaults boolForKey:@"MUTE_SOUND"])?@"静音":@"放音"] WithTimeDismiss:nil messageType:KMessageSuccess];
            });
        }];
    } else {
        [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
    }
}


- (void)hecai_clicked:(id)sender {
    //气氛(1,喝彩 2，倒彩 3，明亮 4，柔和 5 动感 6 开关)
    if ([Utility instanceShare].netWorkStatus) {
        [cmdController sendCmd_qiFen:1 completed:^(BOOL completed, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [HuToast showToastWithMessage:[NSString stringWithFormat:@"      %@   ",@"喝彩"] WithTimeDismiss:nil messageType:KMessageSuccess];
            });
        }];
    } else {
        [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
    }
}

- (void)daocai_clicked:(id)sender {
    if ([Utility instanceShare].netWorkStatus) {
        [cmdController sendCmd_qiFen:2 completed:^(BOOL completed, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [HuToast showToastWithMessage:[NSString stringWithFormat:@"      %@   ",@"倒彩"] WithTimeDismiss:nil messageType:KMessageSuccess];
            });
        }];
    } else {
        [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
    }
}

- (void)rouhe_clicked:(id)sender {
    if ([Utility instanceShare].netWorkStatus) {
        [cmdController sendCmd_qiFen:4 completed:^(BOOL completed, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [HuToast showToastWithMessage:[NSString stringWithFormat:@"      %@   ",@"柔和"] WithTimeDismiss:nil messageType:KMessageSuccess];
            });
        }];
    } else {
        [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
    }
}

- (void)mingliang_clicked:(id)sender {
    if ([Utility instanceShare].netWorkStatus) {
        [cmdController sendCmd_qiFen:3 completed:^(BOOL completed, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [HuToast showToastWithMessage:[NSString stringWithFormat:@"      %@   ",@"明亮"] WithTimeDismiss:nil messageType:KMessageSuccess];
            });
        }];
    } else {
        [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
    }
}
//气氛(1,喝彩 2，倒彩 3，明亮 4，柔和 5 动感 6 开关)

- (void)donggang_clicked:(id)sender {
    if ([Utility instanceShare].netWorkStatus) {
        [cmdController sendCmd_qiFen:5 completed:^(BOOL completed, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [HuToast showToastWithMessage:[NSString stringWithFormat:@"      %@   ",@"动感"] WithTimeDismiss:nil messageType:KMessageSuccess];
            });
        }];
    } else {
        [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
    }
}

- (void)kaiguang_clicked:(id)sender {
    if ([Utility instanceShare].netWorkStatus) {
        [cmdController sendCmd_qiFen:6 completed:^(BOOL completed, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [HuToast showToastWithMessage:[NSString stringWithFormat:@"      %@   ",@"开关"] WithTimeDismiss:nil messageType:KMessageSuccess];
            });

        }];
    } else {
        [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
    }
}

- (void)fuwu_clicked:(id)sender {
    if ([Utility instanceShare].netWorkStatus) {
        [cmdController sendCmd_FUWU:^(BOOL completed, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [HuToast showToastWithMessage:[NSString stringWithFormat:@"  %@",@"呼叫服务"] WithTimeDismiss:nil messageType:KMessageSuccess];
            });
        }];
    } else {
        [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
    }

}

- (void)bokongBtn_clicked:(id)sender {
    UIButton *btn=(UIButton*)sender;
    if ([Utility instanceShare].netWorkStatus) {
    switch (btn.tag) {
        case 0: {
//            NSLog(@"点击原音");
            [cmdController sendCmd_yuanChang_pangChang:^(BOOL completed, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [HuToast showToastWithMessage:[NSString stringWithFormat:@"      %@   ",([userDefaults boolForKey:@"PANGYING"])?@"伴音":@"原音"] WithTimeDismiss:nil messageType:KMessageSuccess];
                });
            }];
            break;
        }
        case 1: {
//            NSLog(@"点击切歌");
            [cmdController sendCmd_switchSong:^(BOOL completed, NSError *error) {
//                if (completed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [HuToast showToastWithMessage:[NSString stringWithFormat:@"      %@   ",@"切歌"] WithTimeDismiss:nil messageType:KMessageSuccess];
                });
            }];
            break;
        }
        case 2: {
//            NSLog(@"点击播放");
            [cmdController sendCmd_stopPlay:^(BOOL completed, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [HuToast showToastWithMessage:[NSString stringWithFormat:@"      %@   ",([userDefaults boolForKey:@"PLAYING"])?@"播放":@"停止"] WithTimeDismiss:nil messageType:KMessageSuccess];
                });
            }];
            break;
        }
        case 3: {
            [cmdController sendCmd_rePlay:^(BOOL completed, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [HuToast showToastWithMessage:[NSString stringWithFormat:@"      %@   ",@"重唱"] WithTimeDismiss:nil messageType:KMessageSuccess];
                });
            }];
            break;
        }
        default:
            break;
    }
    }else {
        [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
    }
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)exitShenKong:(id)sender {
    if ([self.delegate respondsToSelector:@selector(exitShengKongView)]) {
        [self.delegate exitShengKongView];
    }
}

#pragma mark - ZVolumeSlideDelegate

- (void)sliderDidEndDrag:(NSNumber *)value slider:(ZVolumeSlide *)slider {
    NSLog(@"%@",value);
    [self handSendSoundMessageCommandWithValue:value View:slider];

}

- (void)handSendSoundMessageCommandWithValue:(NSNumber*)value View:(ZVolumeSlide*)slider {
//    NSLog(@"========%@=========",value);
    if ([Utility instanceShare].netWorkStatus) {
        CommandControler *cmd=[[CommandControler alloc]init];
        if (slider.type==0) {
            [cmd sendCmd_yingDiaoAdjustToObject:2 value:value completed:^(BOOL completed, NSError *error) {
                if (completed && error==nil) {
                    [userDefaults setObject:value forKey:@"Mic_soundAdjust"];
                    [userDefaults synchronize];
                    dispatch_async(dispatch_get_main_queue(), ^{
                     [HuToast showToastWithMessage:[NSString stringWithFormat:@"     %@   ",[value stringValue]] WithTimeDismiss:nil messageType:KMessageSuccess];
                    });

                    
                } else {
                    [slider resumeSliderValue];
                }
            }];
        } else {
            [cmd sendCmd_soundAdjust:value completed:^(BOOL completed, NSError *error) {
                if (completed && error==nil) {
                    [userDefaults setObject:value forKey:@"Music_soundAdjust"];
                    [userDefaults synchronize];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [HuToast showToastWithMessage:[NSString stringWithFormat:@"     %@   ",[value stringValue]] WithTimeDismiss:nil messageType:KMessageSuccess];
                    });

                } else {
                    [slider resumeSliderValue];
                }
            }];
        }
    } else {
        [slider resumeSliderValue];
        [[Utility readAppDelegate] showMessageTitle:@"error" message:@"networkError" showType:1];
    }
}

@end
