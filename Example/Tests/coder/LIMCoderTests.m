//
//  WuKongIMSDKTests.m
//  WuKongIMSDKTests
//
//  Created by tangtaoit on 11/23/2019.
//  Copyright (c) 2019 tangtaoit. All rights reserved.
//

// https://github.com/Specta/Specta
#import <WuKongIMSDK/WuKongIMSDK.h>
#import <WuKongIMSDK/WKConnectPacket.h>
SpecBegin(WKCoder)

describe(@"编码connect", ^{
    
    it(@"编码连接消息", ^{
        WKConnectPacket *packet = [WKConnectPacket new];
        packet.version = 1;
        packet.deviceFlag = 1;
        packet.deviceId = @"2";
        packet.clientTimestamp = 1;
        packet.uid = @"1";
        packet.token = @"3";
       NSData *data = [[WKSDK share].coder encode:packet];
        expect(21).equal(data.length);
    });
    
    it(@"解码connack", ^{
        Byte testByte[] = {0x20,0x09,0x00,0x00,0x00,0x00,0x00,0x00,0x30,0x39,0x01};
        NSData *data = [NSData dataWithBytes:testByte length:sizeof(testByte)];
         WKConnackPacket *packet = (WKConnackPacket*)[[WKSDK share].coder decode:data];
        expect(12345).equal(packet.timeDiff);
         expect(1).equal(packet.reasonCode);
    });
    
    waitUntil(^(DoneCallback done) {
        done();
    });
});

SpecEnd

