//
//  WKSignalKey.swift
//  WuKongIMSDK
//
//  Created by tt on 2021/9/8.
//

import Foundation

@objc public class WKSignalKey: NSObject {

    @objc public let identityKey: String
    @objc public let signedPreKey: WKSignedPreKeyRequest
    @objc public let preKey: WKOneTimePreKey
    @objc public let registrationId: UInt32
//    @objc public let userId: String?
    @objc public let sessionId: String?
    
    @objc public init(identityKey :String,signedPreKey:WKSignedPreKeyRequest,preKey:WKOneTimePreKey,registrationId:UInt32,sessionId:String?) {
        self.identityKey = identityKey;
        self.signedPreKey = signedPreKey;
        self.preKey = preKey;
        self.registrationId = registrationId;
//        self.userId = userId;
        self.sessionId =  sessionId;
    }

    @objc func getPreKeyPublic() -> Data? {
        guard let key = preKey.pubkey, !key.isEmpty else {
            return nil
        }
        return Data(base64Encoded: key)
    }

    @objc func getIdentityPublic() -> Data {
        return Data(base64Encoded: identityKey)!
    }

    @objc func getSignedPreKeyPublic() -> Data {
        return Data(base64Encoded: signedPreKey.pubkey)!
    }

    @objc func getSignedSignature() -> Data {
        return Data(base64Encoded: signedPreKey.signature)!
    }

    @objc var deviceId: Int32 {
        return WKSignalProtocol.convertSessionIdToDeviceId(sessionId)
    }

}


