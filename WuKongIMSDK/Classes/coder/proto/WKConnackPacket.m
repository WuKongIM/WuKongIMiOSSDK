//
//  WKConnackPacket.m
//  WuKongIMSDK
//
//  Created by tt on 2019/11/26.
//

#import "WKConnackPacket.h"
#import "WKConst.h"
#import "WKData.h"
#import "WKSDK.h"
@implementation WKConnackPacket


-(WKPacketType) packetType {
    return WK_CONNACK;
}

-(WKPacket*) decode:(NSData*) body header:(WKHeader*)header {
    return [self decodeLM:body header:header];
}

-(WKPacket*) decodeLM:(NSData*) body header:(WKHeader*)header {
    WKConnackPacket *packet = [WKConnackPacket new];
    WKDataRead *reader = [[WKDataRead alloc] initWithData:body];
    packet.timeDiff = [reader readint64];
    packet.reasonCode = [reader readUint8];
    packet.serverKey = [reader readString];
    packet.salt = [reader readString];
   
    return packet;
}

-(NSData*) encode:(WKConnackPacket*)packet{
    return nil;
}

- (NSString *)description{
 
    return [NSString stringWithFormat:@"timeDiff:%lli reasonCode:%i",self.timeDiff,self.reasonCode];
}

@end
