//
//  CommandControler.m
//  KTV
//
//  Created by stevenhu on 15/6/3.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import "CommandControler.h"
#import "Utility.h"
#define COMMANDURLHEADER @"http://192.168.43.1:8080/puze/?cmd="

#define COMMANDURLHEADER_PIC @"http://192.168.43.1:8080/puze?cmd=0x02&filename="

#define DOCUMENTPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
@interface CommandControler() {
    NSOperationQueue *queue;
    int yingLiang;
    long long _totalLength;
    NSUserDefaults *accountDefaults;
    NSURLSession *session;
    NSURLSessionConfiguration *configuration;
}

@end
@implementation CommandControler


- (instancetype)init {
    if (self=[super init]) {
        queue=[[NSOperationQueue alloc]init];
        configuration=[NSURLSessionConfiguration ephemeralSessionConfiguration];
        session=[NSURLSession sessionWithConfiguration:configuration];
    }
    return self;
}

- (void)clearCacheData {
    NSFileManager *manager=[NSFileManager defaultManager];
    NSString *removeDir=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadDir/Images"];
    [manager removeItemAtPath:removeDir error:nil];
    // resume default setting;
}

//服务
- (void)sendCmd_FUWU:(sendCompleted)completed {
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xb1"];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}

//气氛(1,喝彩 2，倒彩 3，明亮 4，柔和 5 动感 6 开关)
- (void)sendCmd_qiFen:(int)value completed:(sendCompleted)completed {
    //  http://192.168.43.1:8080/puze?cmd=0xb2&ID= (1,喝彩 2，倒彩 3，明亮 4，柔和 5 动感 6 开关)
    if (value<=0 || value>6)  return;
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xb2&ID=%d",value];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}

//祝福文字
- (void)sendCmd_zhuFuWithWord:(NSString *)value completed:(sendCompleted)completed {
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xb3&label=%@",value];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}

//祝福（图片）(最大512*512)数据流
- (void)sendCmd_zhuFuWithPicture:(UIImage *)image completed:(sendCompleted)completed {
    if (image.size.width>512 || image.size.height>512) {
        if (completed) {
            completed(NO,[CommandControler errorWithMessage:@"Image Size Too big"]);
        }
        return;
    }
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xb4"];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSURLSessionUploadTask *dataTask=[session uploadTaskWithRequest:request fromData:UIImagePNGRepresentation(image) completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}

//静音/放音
- (void)sendCmd_mute:(BOOL)mute completed:(sendCompleted)completed {
    //    http://192.168.43.1:8080/puze?cmd=0xb6&ID=(1静音 2=放音)
    int value;
    value= mute?1:2;
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xb6&ID=%d",value];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}

//音量(-+) ::TODO
- (void)sendCmd_soundAdjust:(NSNumber *)value completed:(sendCompleted)completed {
    //http://192.168.43.1:8080/puze?cmd=0xb7&vol=音量
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xb7&vol=%@",value];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:3];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}
//need to cancel session
//调音(1麦克风 2 音乐 3 功放 4音调 ) & value
- (void)sendCmd_yingDiaoAdjustToObject:(int)who value:(NSNumber *)value completed:(sendCompleted)completed {
    //    http://192.168.43.1:8080/puze?cmd=0xb5&ID=(1麦克风 2 音乐 3 功放 4音调 ) &vol=音量
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xb5&ID=%d&vol=%@",who,value];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:3];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}

//切歌
- (void)sendCmd_switchSong:(sendCompleted)completed {
    //http://192.168.43.1:8080/puze?cmd=0xb8
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xb8"];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}

//重唱
- (void)sendCmd_rePlay:(sendCompleted)completed {
    //    http://192.168.43.1:8080/puze?cmd=0xb9
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xb9"];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}


//暂停/播放
- (void)sendCmd_stopPlay:(sendCompleted)completed {
    // http://192.168.43.1:8080/puze?cmd=0xba&ID=(1暂停 2 播放)
    int value;
    if ([accountDefaults boolForKey:@"PLAYING"]) {
        value=1;
    } else {
        value=2;
    }
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xba&ID=%d",value];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200  && !error) {
            if (value==1) {
                [accountDefaults setBool:NO forKey:@"PLAYING"];
            } else {
                [accountDefaults setBool:YES forKey:@"PLAYING"];
            }
            [accountDefaults synchronize];
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(YES,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}
//原唱/伴唱
- (void)sendCmd_yuanChang_pangChang:(sendCompleted)completed {
    //http://192.168.43.1:8080/puze?cmd=0xbb&ID=(1原唱2伴唱)
    int value;
    if ([accountDefaults boolForKey:@"PANGYING"]) {
        value=1;
    } else {
        value=2;
    }
    
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xbb&ID=%d",value];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (value==1) {
                [accountDefaults setBool:NO forKey:@"PANGYING"];
            } else {
                [accountDefaults setBool:YES forKey:@"PANGYING"];
            }
            [accountDefaults synchronize];
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}

//获取已点歌单
- (void)sendCmd_get_yiDianList:(yiDianCompleted)completed {
    //http://192.168.43.1:8080/puze?cmd=0xbc
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xbc"];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                NSString *strContent=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                NSMutableArray *arr=[[strContent componentsSeparatedByString:@"\r\n"] mutableCopy];
                [arr removeLastObject];
                completed(YES,arr);
            }
        } else {
            if (completed) {
                completed(NO,nil);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}

//删除已点
- (void)sendCmd_remove_yidian:(NSString *)value completed:(sendCompleted)completed {
    //    http://192.168.43.1:8080/puze?cmd=0xbd&orderid=序号
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xbd&orderid=%@",value];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}

//已点打乱
- (void)sendCmd_yiDianDaluang:(sendCompleted)completed {
    //    http://192.168.43.1:8080/puze?cmd=0xbf
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xbf"];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}

//已点移到顶
- (void)sendCmd_moveSongToTop:(NSString *)order completed:(sendCompleted)completed {
    //   http://192.168.43.1:8080/puze?cmd=0xbe&orderid=序号
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xbe&orderid=%@",order];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}

//已点还原
- (void)sendCmd_yiDianResume:(sendCompleted)completed  {
    //    http://192.168.43.1:8080/puze?cmd=0xc0
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xc0"];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}

//点歌
- (void)sendCmd_Diange:(NSString *)number completed:(sendCompleted)completed {
    //    http://192.168.43.1:8080/puze?cmd=0xc1&number=编号
    NSString *urlStr=[[COMMANDURLHEADER stringByAppendingFormat:@"0xc1&number=%@",number]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //    NSLog(@"url:%@",urlStr);
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}
//点歌(顶)
- (void)sendCmd_DiangeToTop:(NSString *)number completed:(sendCompleted)completed {
    //http://192.168.43.1:8080/puze?cmd=0xc2&number=编号
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xc2&number=%@",number];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}

//推送视频(音频)
- (void)sendCmd_pushVideoAudio:(NSData *)data completed:(sendCompleted)completed {
    //http://192.168.43.1:8080/puze?cmd=0xe1（数据流）
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xe1"];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    
    NSURLSessionUploadTask *dataTask=[session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
        
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
    
}
//推送图片
- (void)sendCmd_pushPicture:(UIImage *)image completed:(sendCompleted)completed {
    //http://192.168.43.1:8080/puze?cmd=0xe2    (数据流）
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xe2"];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}

// 重起
- (void)sendCmd_restartDevice:(sendCompleted)completed {
    //    http://192.168.43.1:8080/puze?cmd=0xd1
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xd1"];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
            completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}
// 关机
- (void)sendCmd_shutdownDevice:(sendCompleted)completed {
    //    http://192.168.43.1:8080/puze?cmd=0xd2
    NSString *urlStr=[COMMANDURLHEADER stringByAppendingFormat:@"0xd2"];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([self httpsStatuCode:response]==200 && !error) {
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(NO,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}

+ (void)setYidianBadgeWidth:(BBBadgeBarButtonItem *)item completed:(sendCompleted)completed {
    if (![Utility instanceShare].netWorkStatus) return;
    NSString *urlStr=[[@"http://192.168.43.1:8080/puze/?cmd=" stringByAppendingFormat:@"0xbc"]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"query:%@",urlStr);
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    NSURLSession *session=[NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse*)response;
            if (httpResponse.statusCode==200 && !error) {
            NSString *strContent=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSMutableArray *arr=[[strContent componentsSeparatedByString:@"\r\n"] mutableCopy];
            [arr removeLastObject];
            dispatch_sync(dispatch_get_main_queue(), ^{
                item.badgeValue=[NSString stringWithFormat:@"%d",(int)arr.count];
        });
            if (completed) {
                completed(YES,nil);
            }
        } else {
            if (completed) {
                completed(YES,[CommandControler errorWithMessage:error.description]);
            }
        }
    }];
    dataTask.priority=NSURLSessionTaskPriorityHigh;
    [dataTask resume];
}

- (NSInteger)httpsStatuCode:(NSURLResponse*)response {
    NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse*)response;
    return httpResponse.statusCode;
}

+ (NSError*)errorWithMessage:(NSString*)message {
    NSDictionary* errorMessage = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"SEND_COMMAND" code:999 userInfo:errorMessage];
}
@end
