//
//  WKSetting.m
//  WuKongIMSDK
//
//  Created by tt on 2021/4/9.
//

#import "WKSetting.h"

@implementation WKSetting


-(uint8_t) toUint8 {
    return self.receiptEnabled<<7 | self.signal << 5 | self.topic << 3;
}

+ (WKSetting *)fromUint8:(uint8_t)v {
    WKSetting *setting = [WKSetting new];
    setting.receiptEnabled = ((v >> 7) & 0x01) > 0;
    setting.signal = ((v >> 5) & 0x01) > 0;
    setting.topic = ((v >> 3) & 0x01) > 0;
    return  setting;
}

- (NSString *)description{
    
    return [NSString stringWithFormat:@"SETTING receiptEnabled:%d signal:%d topic:%d",self.receiptEnabled?1:0,self.signal?1:0,self.topic?1:0];
}

@end
