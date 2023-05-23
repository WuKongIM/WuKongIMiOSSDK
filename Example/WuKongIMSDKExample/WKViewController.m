//
//  WKViewController.m
//  WuKongIMSDK
//
//  Created by tangtaoit on 11/23/2019.
//  Copyright (c) 2019 tangtaoit. All rights reserved.

// 7d2af6b1013c4db79e719b778b18831c  token: 9375d6a7eaf8416b90848721e455bc8a
// 75d7295740ec4fefb96d00ea44363f7d  token: ab7387e38d8a465296242506fefdf974
static NSString *uid = @"7d2af6b1013c4db79e719b778b18831c";
static NSString *token = @"9375d6a7eaf8416b90848721e455bc8a";

static NSString *toUid = @"75d7295740ec4fefb96d00ea44363f7d";

#import "WKViewController.h"
#import <WuKongIMSDK/WuKongIMSDK.h>
@interface WKViewController ()<WKConnectionManagerDelegate>

@end

@implementation WKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    WKOptions *options = [[WKOptions alloc] init];
    options.host = @"49.235.59.182";
    options.port = 6666;
    options.heartbeatInterval = 10;
    [WKSDK shared].options = options;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)onConnect:(id)sender {
    
    [[WKSDK shared].options setConnectInfoCallback:^WKConnectInfo * _Nonnull{
        WKConnectInfo *connectInfo = [WKConnectInfo new];
        connectInfo.uid = uid;
        connectInfo.token = token;
        return  connectInfo;
    }];
    [[[WKSDK shared] connectionManager] addDelegate:self];
    [[[WKSDK shared] connectionManager] connect];
    
}

-(IBAction)onSendMessage:(id)sender {
    for (int i=0; i<1; i++) {
        [[[WKSDK shared] chatManager] sendMessage:[[WKTextContent alloc] initWithContent:[NSString stringWithFormat:@"测试下咯->%i",i]] channel:[[WKChannel alloc] initWith:toUid channelType:WK_PERSON]];
    }
   
}

/**
 连接中
 */
-(void) onConnecting {
    NSLog(@"连接中...");
}

/**
 已连接
 */
-(void) onConnected{
    NSLog(@"已连接");
}


/**
 已断开
 
 @param error <#error description#>
 */
-(void) onDisconnected:(NSError*)error{
     NSLog(@"已断开");
}

@end
