//
//  AdjustSoundArray.m
//  KTV
//
//  Created by stevenhu on 15/9/16.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import "AdjustSoundArray.h"
#import "CommandControler.h"
@interface AdjustSoundArray () {
    NSOperationQueue *operationQueue;
    CommandControler *cmd;
}

@end


@implementation AdjustSoundArray

- (instancetype)init {
    if (self=[super init]) {
        operationQueue=[[NSOperationQueue alloc]init];
        [operationQueue setMaxConcurrentOperationCount:20];
        cmd=[[CommandControler alloc]init];
    }
    return self;
}

- (void)addObject:(id)anObject  {
//    NSLog(@"<--->%@",anObject);
   __block NSNumber *value=[[NSNumber alloc]init];
    if (anObject) {
        NSBlockOperation *operation=[NSBlockOperation blockOperationWithBlock:^{
            if ([value integerValue] < 0 || [value integerValue] >15 ||![value isKindOfClass:[NSNumber class]]) {
                value=@(0);
            }
            switch (_type) {
                case 0: {
                    if (value==anObject) {
//                        NSLog(@"---->%@",value);
                        break ;
                    }
                    [cmd sendCmd_soundAdjust:anObject completed:^(BOOL completed, NSError *error) {
                        if (completed) {
//                            NSLog(@"ok");
                        }
                    }];
                }
                break;
                case 1: {
                    
                }
                break;
                default:
                    break;
            }
        
        }];
     
//        NSLog(@"<----%@",value);
        [operationQueue addOperation:operation];
    }
//    [super addObject:anObject];
}
@end
