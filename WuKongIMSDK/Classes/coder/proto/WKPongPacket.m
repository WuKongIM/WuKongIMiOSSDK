//
//  WKPongPacket.m
//  WuKongIMSDK
//
//  Created by tt on 2019/11/27.
//

#import "WKPongPacket.h"
#import "WKConst.h"
#import "WKSDK.h"
@implementation WKPongPacket

-(WKPacketType) packetType {
    return WK_PONG;
}

- (WKPacket *)decode:(NSData *)body header:(WKHeader *)header {
    if([WKSDK shared].options.proto == WK_PROTO_MOS) {
       return [self decodeMOS:body header:header];
    }
    return nil;
}

- (NSData *)encode:(WKPacket *)packet {
    return nil;
}


-(WKPacket*) decodeMOS:(NSData*) body header:(WKHeader*)header {
    WKPongPacket *packet = [WKPongPacket new];
    return packet;
}

- (NSString *)description{
    
    return [NSString stringWithFormat:@"PONG"];
}
@end
