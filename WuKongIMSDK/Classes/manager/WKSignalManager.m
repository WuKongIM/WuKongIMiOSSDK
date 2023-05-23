//
//  WKSignalManager.m
//  WuKongIMSDK
//
//  Created by tt on 2021/9/3.
//

#import "WKSignalManager.h"
#import <WuKongIMSDK/WuKongIMSDK-Swift.h>

@interface WKSignalManager ()

@property(nonatomic,strong) dispatch_queue_t signalQueue; // 处理消息的队列

@end

@implementation WKSignalManager


static WKSignalManager *_instance;
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (WKSignalManager *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (dispatch_queue_t)signalQueue {
    if(!_signalQueue) {
        _signalQueue = dispatch_queue_create("im.limao.services.queue.signal", DISPATCH_QUEUE_CONCURRENT);
    }
    return _signalQueue;
}


-(void) initSignal {
    [WKSignalProtocol.shared initSignal];
    
}

- (BOOL)hasLocalIdentityKey {
    return [WKSignalProtocol.shared hasLocalIdentityKey];
}

-(WKSignalKeyRequest* ) generateKeys {

    return [WKSignalProtocol.shared generateKeys];
}

-(WKKeyPair*) getLocalIdentityKeyPair {
    return [WKSignalProtocol.shared getLocalIdentityKeyPair];
}

-(uint32_t) getLocalRegistrationId {
    return [WKSignalProtocol.shared getLocalRegistrationId];
}

-(NSData*)encrypt:(WKChannel*)channel contentData:(NSData*)contentData error:(NSError * *)error{
    
    if(!self.channelSignalKeysProvider) {
        NSLog(@"没有设置channelSignalKeysProvider，不能对数据加密！");
        return contentData;
    }
    
    if(channel.channelType == WK_GROUP) { // 咱不支持群加密
        return contentData;
    }
    
   BOOL hasSession = [WKSignalProtocol.shared containsSessionWithUid:channel.channelId deviceId:1];
    
    if(!hasSession) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
       __block  WKSignalKey *signalKey;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            weakSelf.channelSignalKeysProvider(channel, ^(WKSignalKey * _Nonnull signalK,NSError *error) {
                signalKey = signalK;
                dispatch_semaphore_signal(semaphore);
                
            });
        });
        dispatch_semaphore_wait(semaphore,  DISPATCH_TIME_FOREVER);
        
        if(signalKey) {
            [WKSignalProtocol.shared processSessionWithRecipientID:channel.channelId key:signalKey];
        }
    }
   
    return  [WKSignalProtocol.shared encryptWithRecipientID:channel.channelId contentData:contentData error:error];
}

-(NSData*) decrypt:(WKChannel*)channel encryptData:(NSData*) encryptData error:(NSError * *)error{
    if(channel.channelType == WK_GROUP) { // 咱不支持群加密
        return encryptData;
    }
    return [WKSignalProtocol.shared decryptWithRecipientID:channel.channelId preKeySignalMessageData:encryptData error:error];
}

@end
