
//
//  TempViewController.m
//  QRCode_Demo
//
//  Created by 沈红榜 on 15/11/17.
//  Copyright © 2015年 沈红榜. All rights reserved.
//

#import "TempViewController.h"
#import "SHBQRView.h"
#import "Utility.h"
#import "NSString+Utility.h"

@interface TempViewController ()<SHBQRViewDelegate>

@end

@implementation TempViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    SHBQRView *qrView = [[SHBQRView alloc] initWithFrame:self.view.bounds];
    qrView.delegate = self;
    [self.view addSubview:qrView];
    
}

- (void)qrView:(SHBQRView *)view ScanResult:(NSString *)result {
    [view stopScan];
    if ([result hasPrefix:@"wifi->"] && [[result substringFromIndex:[@"wifi->" length]] componentsSeparatedByString:@","].count ==2){
        NSArray *scanArray=[[result substringFromIndex:[@"wifi->" length]] componentsSeparatedByString:@","];
        NSString *wifiName=scanArray[0];
        NSString *wifiPassWord=scanArray[1];
        UIAlertController *alVC=[UIAlertController alertControllerWithTitle:NSLocalizedString(@"connectnetwork", nil) message:NSLocalizedString(@"connectNetContent", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alVC dismissViewControllerAnimated:YES completion:nil];
            [self dismissViewControllerAnimated:YES completion:nil];

        }];
        UIAlertAction *confirmaction=[UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [Utility instanceShare].serverIPAddress=@"192.168.43.1";
            [alVC dismissViewControllerAnimated:YES completion:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        
        [alVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"username", nil),wifiName];
            textField.enabled=NO;
        }];
        [alVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"password", nil),wifiPassWord];
            textField.enabled=NO;
        }];
        
        [alVC addAction:cancelAction];
        [alVC addAction:confirmaction];
        [self presentViewController:alVC animated:YES completion:nil];
        
    } else if ([result hasPrefix:@"route->"] && [[result substringFromIndex:[@"route->" length]]isIpAddress]) {
        //192.168.0.90
        if (![[Utility instanceShare].serverIPAddress isEqualToString:[result substringFromIndex:[@"route->" length]]]) {
            NSLog(@"%@",[result substringFromIndex:[@"route->" length]]);
            [Utility instanceShare].serverIPAddress=[result substringFromIndex:[@"route->" length]];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIAlertController *alVC=[UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"scancodeerror", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action=[UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alVC dismissViewControllerAnimated:YES completion:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alVC addAction:action];
        [self presentViewController:alVC animated:YES completion:nil];

    }
}

@end
