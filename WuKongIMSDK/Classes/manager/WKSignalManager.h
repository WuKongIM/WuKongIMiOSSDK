//
//  WKSignalManager.h
//  WuKongIMSDK
//
//  Created by tt on 2021/9/3.
//

#import <Foundation/Foundation.h>
#import "WKMessage.h"
NS_ASSUME_NONNULL_BEGIN
@class WKSignalKeyRequest;
@class WKSignalKey;
@class WKKeyPair;

typedef void(^WKChannelSignalKeysCallback)(WKSignalKey * __nullable signalKey,NSError  * __nullable error);


@interface WKSignalManager : NSObject

+ (WKSignalManager *)shared;

/**
 频道signal key提供者
 */
@property(nonatomic,copy) void(^channelSignalKeysProvider)(WKChannel *channel,WKChannelSignalKeysCallback callback);

/**
 初始化signal
 */
-(void) initSignal;

/**
  是否有本地身份key
 */
-(BOOL) hasLocalIdentityKey;

/**
 生成signal 相关key
 */
-(WKSignalKeyRequest*) generateKeys;

/**
  获取本地registrationId
 */
-(uint32_t) getLocalRegistrationId;

/**
 获取本地key
 */
-(WKKeyPair*) getLocalIdentityKeyPair;

/**
 加密消息
 */
-(NSData*)encrypt:(WKChannel*)channel contentData:(NSData*)contentData error:(NSError * *)error;

/**
 解密
 */
-(NSData*) decrypt:(WKChannel*)channel encryptData:(NSData*) encryptData error:(NSError * *)error;

@end

NS_ASSUME_NONNULL_END
