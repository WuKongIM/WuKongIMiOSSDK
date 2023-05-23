//
//  WKRecvPacket.m
//  WuKongIMSDK
//
//  Created by tt on 2019/11/27.
//

#import "WKRecvPacket.h"
#import "WKConst.h"
#import "WKData.h"
#import "WKSDK.h"
#import "WKSecurityManager.h"
@implementation WKRecvPacket


-(WKPacketType) packetType {
    return WK_RECV;
}
- (WKSetting *)setting {
    if(!_setting) {
        _setting = [WKSetting new];
    }
    return  _setting;
}

-(WKPacket*) decode:(NSData*) body header:(WKHeader*)header {
    return [self decodeLM:body header:header];
}

-(WKPacket*) decodeLM:(NSData*) body header:(WKHeader*)header {
    WKRecvPacket *packet = [WKRecvPacket new];
    packet.header = header;
    WKDataRead *reader = [[WKDataRead alloc] initWithData:body];
    if([WKSDK shared].options.protoVersion>3) {
       uint8_t setting = [reader readUint8];
        packet.setting = [WKSetting fromUint8:setting];
    }
    NSString *msgKey;
    if([WKSDK shared].options.protoVersion>2) {
        msgKey = [reader readString];
        
    }
    packet.fromUid = [reader readString];
    packet.channelId = [reader readString];
    packet.channelType = [reader readUint8];
    packet.clientMsgNo = [reader readString];
    packet.messageId = [reader readUint64];
    packet.messageSeq = [reader readUint32];
    packet.timestamp = [reader readUint32];
    
    if(packet.setting.topic) {
        packet.topic = [reader readString];
    }
    
    
    
//    unsigned long payloadStartLen = 8  + 4 + (packet.clientMsgNo.length+2) + 4 + (packet.channelId.length + 2) + 1 + (packet.fromUid.length + 2) ;// 消息ID长度 + 消息序列号长度 + (客户端消息唯一编号+字符串标示长度) + 消息时间长度 + 频道类型长度 + (频道ID长度+字符串标示长度)
//    if([WKSDK shared].options.protoVersion>2) {
//        payloadStartLen+= (msgKey.length + 2);
//    }
    packet.payload = [reader remainingData];
    
    if([WKSDK shared].options.protoVersion>2) {
       NSString *exceptMsgKey = [[WKSecurityManager shared] encryption:[packet veritifyString]];
        exceptMsgKey= [[WKSecurityManager shared] md5:exceptMsgKey];
        if(![exceptMsgKey isEqualToString:msgKey]) {
            NSLog(@"消息不合法！期望的MsgKey:%@ 实际的MsgKey:%@",exceptMsgKey,msgKey);
            return nil;
        }
       NSString *payloadEnc = [[WKSecurityManager shared] decryption:[[NSString alloc] initWithData:packet.payload encoding:NSUTF8StringEncoding]];
       packet.payload = [payloadEnc dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return packet;
}


-(NSData*) encode:(WKRecvPacket*)packet{
    return nil;
}

-(NSString*) veritifyString {
    NSString *payloadStr = [[NSString alloc] initWithData:self.payload encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"%llu%u%@%u%@%@%u%@",self.messageId,self.messageSeq?:0,self.clientMsgNo?:@"",self.timestamp,self.fromUid?:@"",self.channelId?:@"",self.channelType,payloadStr?:@""];
}

- (NSString *)description{
    
    return [NSString stringWithFormat:@"RECV Header:%@ Setting:%@ fromUid:%@ messageId:%llu messageSeq:%u clientMsgNo:%@ timestamp:%u channelId:%@ channelType:%i topic:%@ payload: %@",self.header ,self.setting,       self.fromUid,self.messageId,self.messageSeq,self.clientMsgNo,self.timestamp,self.channelId,self.channelType,self.topic?:@"",[[NSString alloc] initWithData:self.payload encoding:NSUTF8StringEncoding]];
}

@end
