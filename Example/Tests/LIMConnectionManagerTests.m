//
//  WKConnectionManagetTests.m
//  WuKongIMSDK_Example
//
//  Created by tt on 2019/11/23.
//  Copyright © 2019 tangtaoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WuKongIMSDK/WuKongIMSDK.h>
#import <OCMock/OCMock.h>
SpecBegin(WKConnectionManagerTests)

static NSString *uid = @"75d7295740ec4fefb96d00ea44363f7d";
static NSString *token = @"ab7387e38d8a465296242506fefdf974";

describe(@"测试链接", ^{
    
    // 初始化SDK
    beforeAll(^{
        WKOptions *options = [[WKOptions alloc] init];
        options.host = @"49.235.59.182";
        options.port = 6666;
        [WKSDK share].options = options;
        [[[WKSDK share] connectionManager] setConnectInfoCallback:^WKConnectInfo * _Nonnull{
            WKConnectInfo *connectInfo = [WKConnectInfo new];
            connectInfo.uid = uid;
            connectInfo.token = token;
            return  connectInfo;
        }];
    });
    
    it(@"连接", ^{
        id mock = [OCMockObject mockForProtocol:@protocol(WKConnectionManagerDelegate)];
        [[[WKSDK share] connectionManager] addDelegate:mock];
       
        [[[mock expect] andDo:^(NSInvocation *invocation) {
        }] onConnecting];
        
        waitUntilTimeout(1, ^(DoneCallback done) {
            [[[mock expect] andDo:^(NSInvocation *invocation) {
                [[[WKSDK share] connectionManager] sendPing];
                done();
            }] onConnected];
            [[[WKSDK share] connectionManager] connect];
        });
    });
    
});

SpecEnd
