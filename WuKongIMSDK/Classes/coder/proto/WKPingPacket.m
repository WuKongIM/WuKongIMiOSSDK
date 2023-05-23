//
//  WKPingPacket.m
//  WuKongIMSDK
//
//  Created by tt on 2019/11/27.
//

#import "WKPingPacket.h"
#import "WKConst.h"
#import "WKData.h"
#import "WKSDK.h"
@implementation WKPingPacket

-(WKPacketType) packetType {
    return WK_PING;
}

- (WKPacket *)decode:(NSData *)body header:(WKHeader *)header {
    return nil;
}

- (NSData *)encode:(WKPingPacket *)packet {
    if([WKSDK shared].options.proto == WK_PROTO_MOS) {
       return [self encodeMOS:packet];
    }
    return nil;
}
-(NSData*) encodeMOS:(WKPingPacket*)packet {
    WKDataWrite  *writer = [WKDataWrite initLittleEndian];
    
    // login type
    [writer writeUint8:1];
    
    // uid
    unsigned long long  uid = strtoull([[WKSDK shared].options.connectInfo.uid UTF8String],NULL,0);
    [writer writeUint64:uid];
    
    return [writer toData];
}

@end
