//
//  Order.m
//  KTV
//
//  Created by stevenhu on 15/7/4.
//  Copyright (c) 2015年 stevenhu. All rights reserved.
//

#import "Order.h"
#import "NSString+Utility.h"
@implementation Order

- (void)setNumber:(NSString *)number {
    _number=[number decodeBase64];

}

- (void)setRcid:(NSString *)rcid {
    _rcid=[rcid decodeBase64];

}

-  (void)setOrdername:(NSString *)ordername {
    _ordername=[ordername decodeBase64];
}

@end
