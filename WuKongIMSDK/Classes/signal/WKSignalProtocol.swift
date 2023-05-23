//
//  WKSignalProtocol.swift
//  WuKongIMSDK
//
//  Created by tt on 2021/9/3.
//

import Foundation


@objc public class WKSignalProtocol: NSObject {
    
    internal static let batchSize: Int = 700
    internal static let prekeyMiniNum = 500
    
    internal static let DEFAULT_DEVICEID :Int32 = 1
    
    @objc public static let shared = WKSignalProtocol()

    private var store: SignalStore

   override init() {
        store = try! SignalStore(identityKeyStore: LiMaoIdentityKeyStore(), preKeyStore: LiMaoPreKeyStore(), sessionStore: LiMaoSessionStore(), signedPreKeyStore: LiMaoSignedPreKeyStore(), senderKeyStore: LiMaoSenderKeyStore())
    }

    // 初始化signal，一般在登陆的时候调用
   @objc public func initSignal() {
        let localRegistrationId = try! Signal.generateRegistrationId()
        let identityKeyPair = try! Signal.generateIdentityKeyPair()
        
        let identity = WKIdentity(address: "-1", registrationId: localRegistrationId, publicKey: identityKeyPair.publicKey, privateKey: identityKeyPair.privateKey, nextPreKeyId: nil, timestamp: Date().timeIntervalSince1970)
        
        WKIdentityDao.shared.saveOrUpdateIdentity(identity: identity)
        WKAppGroupUserDefaults.Signal.registrationId = localRegistrationId
        WKAppGroupUserDefaults.Signal.privateKey = identityKeyPair.privateKey
        WKAppGroupUserDefaults.Signal.publicKey = identityKeyPair.publicKey
    }
    
    @objc public func hasLocalIdentityKey() -> Bool {
        if WKIdentityDao.shared.getIdentity(address: "-1") != nil {
            return true
        }
        return false
       
    }
    
    @objc public func getLocalIdentityKeyPair() -> WKKeyPair {
        return WKKeyPair(publicKey: WKAppGroupUserDefaults.Signal.publicKey, privateKey: WKAppGroupUserDefaults.Signal.privateKey)
    }
    
    @objc public func getLocalRegistrationId() -> UInt32 {
        return WKAppGroupUserDefaults.Signal.registrationId
    }
    
    
    @objc public func generateKeys() -> WKSignalKeyRequest {
        let identityKeyPair = try! self.getIdentityKeyPair()
        let oneTimePreKeys = try! self.generatePreKeys()
        let signedPreKey = try! self.generateSignedPreKey(identityKeyPair: identityKeyPair)
        return WKSignalKeyRequest(registrationId:WKAppGroupUserDefaults.Signal.registrationId,identityKey: identityKeyPair.publicKey.base64EncodedString(),
                                signedPreKey: WKSignedPreKeyRequest(signed: signedPreKey),
                                oneTimePreKeys: oneTimePreKeys)
    }
    
    
    @objc public func encrypt(recipientID:String,contentData:Data) throws -> Data {
        let address = SignalAddress(name: recipientID, deviceId: WKSignalProtocol.DEFAULT_DEVICEID)
        let cipher = SessionCipher(for: address, in: store)
        let  cipherTxt = try cipher.encrypt(contentData)
        
        let cipherData = cipherTxt.message
        print("cipherTxt---->",cipherTxt.type)
        
        var cipherMessageData = cipherData.base64EncodedData();
       
        cipherMessageData.insert(cipherTxt.type.rawValue, at: 0)
        
        return cipherMessageData
        
    }
    
    @objc public func decrypt(recipientID:String,preKeySignalMessageData:Data) throws -> Data {
        let address = SignalAddress(name: recipientID, deviceId: WKSignalProtocol.DEFAULT_DEVICEID)
        let cipher = SessionCipher(for: address, in: store)
        
        let type = preKeySignalMessageData[0]
        
       let message = preKeySignalMessageData.subdata(in: 1..<preKeySignalMessageData.count)
        

        return try cipher.decrypt(message:  CiphertextMessage(type: CiphertextMessage.MessageType(rawValue: type) ?? CiphertextMessage.MessageType.unknown, message: Data(base64Encoded: message) ?? Data()),callback: nil)
    }
    
    
    @objc public func processSession(recipientID: String, key: WKSignalKey) {
        let address = SignalAddress(name: recipientID, deviceId: key.deviceId)
        let sessionBuilder = SessionBuilder(for: address, in: store)
        let preKeyBundle = SessionPreKeyBundle(registrationId: key.registrationId,
                                                     deviceId: key.deviceId,
                                                     preKeyId: key.preKey.keyID,
                                                     preKey: key.getPreKeyPublic(),
                                                     signedPreKeyId: UInt32(key.signedPreKey.keyID),
                                                     signedPreKey: key.getSignedPreKeyPublic(),
                                                     signature: key.getSignedSignature(),
                                                     identityKey: key.getIdentityPublic())
        try? sessionBuilder.process(preKeyBundle: preKeyBundle)
    }
    
    @objc public func containsUserSession(uid: String) -> Bool {
        return WKSessionDao.shared.getSessions(address: uid).count > 0
    }
    
    @objc public func containsSession(uid: String, deviceId: Int32) -> Bool {
        let address = SignalAddress(name: uid, deviceId: deviceId)
        return store.sessionStore.containsSession(for: address)
    }
    
    public static func convertSessionIdToDeviceId(_ sessionId: String?) -> Int32 {
     
        return 1
    }
    
    
    internal  func generatePreKeys() throws -> [WKOneTimePreKey] {
        let preKeyIdOffset = WKAppGroupUserDefaults.Crypto.Offset.prekey ?? self.makeRandomPrekeyOffset()
        let records = try Signal.generatePreKeys(start: preKeyIdOffset, count: WKSignalProtocol.batchSize)
        WKAppGroupUserDefaults.Crypto.Offset.prekey = preKeyIdOffset + UInt32(WKSignalProtocol.batchSize) + 1
        let preKeys = try records.map { PreKey(preKeyId: Int($0.id), record: try $0.data()) }
        LiMaoPreKeyStore().store(preKeys: preKeys)
        return records.map { WKOneTimePreKey(keyID: $0.id, preKey: $0) }
    }
    internal  func generateSignedPreKey(identityKeyPair : KeyPair) throws -> SessionSignedPreKey {
        let signedPreKeyOffset = WKAppGroupUserDefaults.Crypto.Offset.signedPrekey ?? makeRandomPrekeyOffset()
        let timestamp = UInt64(Date().timeIntervalSince1970 * 1000)
        let record = try Signal.generate(signedPreKey: signedPreKeyOffset, identity: identityKeyPair, timestamp: timestamp)
        let store = LiMaoSignedPreKeyStore()
        _ = store.store(signedPreKey: try record.data(), for: record.id)
        WKAppGroupUserDefaults.Crypto.Offset.signedPrekey = signedPreKeyOffset + 1
        return record
    }
    
    internal func getIdentityKeyPair() throws -> KeyPair {
        guard let identity = WKIdentityDao.shared.getIdentity(address: "-1") else {
            throw SignalError.noData
        }
        return identity.getIdentityKeyPair()
    }
    private  func makeRandomPrekeyOffset() -> UInt32 {
        let min: UInt32 = 1000
        let max: UInt32 = .max / 2
        return min + UInt32(arc4random_uniform(max - min))
    }
}

@objc public class WKSignalKeyRequest : NSObject {
    @objc public let registrationId:UInt32
    @objc public let identityKey: String
    @objc public let signedPreKey: WKSignedPreKeyRequest
    @objc public let oneTimePreKeys: [WKOneTimePreKey]?
    
    @objc public init(registrationId :UInt32,identityKey:String,signedPreKey :WKSignedPreKeyRequest,oneTimePreKeys :[WKOneTimePreKey]?) {
        self.registrationId = registrationId;
        self.identityKey = identityKey;
        self.signedPreKey = signedPreKey;
        self.oneTimePreKeys = oneTimePreKeys;
    }
}

@objc public class WKSignedPreKeyRequest: NSObject {
    
    @objc public let keyID: UInt32
    @objc  public let pubkey: String
    @objc public var signature: String
    
     public init(signed: SessionSignedPreKey) {
        keyID = signed.id
        pubkey = signed.keyPair.publicKey.base64EncodedString()
        signature = signed.signature.base64EncodedString()
    }
    
    @objc public init(keyID :UInt32,pubkey:String,signature:String) {
        self.keyID = keyID
        self.pubkey = pubkey
        self.signature = signature
    }
    
}
@objc public class WKOneTimePreKey: NSObject {
    
    @objc public let keyID: UInt32
    @objc public let pubkey: String?
    
    public init(keyID: UInt32, preKey: SessionPreKey) {
        self.keyID = keyID
        self.pubkey = preKey.keyPair.publicKey.base64EncodedString()
    }
    
    @objc public init(keyID:UInt32,pubkey:String) {
        self.keyID = keyID
        self.pubkey = pubkey
    }
    
}



class LiMaoIdentityKeyStore: IdentityKeyStore {
    
    private let lock = NSLock()
    
    func identityKeyPair() -> KeyPair? {
        let identity = WKIdentityDao.shared.getIdentity(address: "-1")
        return KeyPair(publicKey: identity?.publicKey ?? Data(), privateKey: identity?.privateKey ?? Data())
    }

    func localRegistrationId() -> UInt32? {
        let identity = WKIdentityDao.shared.getIdentity(address: "-1")
        return identity?.registrationId
    }

    func save(identity: Data?, for address: SignalAddress) -> Bool {
        objc_sync_enter(lock)
        defer {
            objc_sync_exit(lock)
        }
        let iden = WKIdentity(address: address.name, registrationId: 0, publicKey: identity!, privateKey: Data(), nextPreKeyId: 0, timestamp: Date().timeIntervalSince1970)
        WKIdentityDao.shared.saveOrUpdateIdentity(identity: iden)
        return true
    }

    func isTrusted(identity: Data, for address: SignalAddress) -> Bool? {
        return true
    }


}

class LiMaoPreKeyStore: PreKeyStore {
    private let lock = NSLock()
    func load(preKey: UInt32) -> Data? {
        WKPreKeyDao.shared.getPreKey(with: Int(preKey))?.record
    }

    func store(preKey: Data, for id: UInt32) -> Bool {
        objc_sync_enter(lock)
        defer {
            objc_sync_exit(lock)
        }
       return WKPreKeyDao.shared.savePreKey(PreKey(preKeyId: Int(id), record: preKey))
    }
    
    @discardableResult
    func store(preKeys: [PreKey]) -> Bool {
        objc_sync_enter(lock)
        defer {
            objc_sync_exit(lock)
        }
        return WKPreKeyDao.shared.savePreKeys(preKeys)
    }

    func contains(preKey: UInt32) -> Bool {
        WKPreKeyDao.shared.getPreKey(with: Int(preKey)) != nil
    }

    func remove(preKey: UInt32) -> Bool {
        WKPreKeyDao.shared.deletePreKey(with: Int(preKey))
    }


}

class LiMaoSessionStore: SessionStore {
    private let lock = NSLock()
    
    func loadSession(for address: SignalAddress) -> (session: Data, userRecord: Data?)? {
        guard let session = WKSessionDao.shared.getSession(address: address.name, device: address.deviceId) else {
            return nil
        }
        return (session.record, nil)
    }

    func subDeviceSessions(for name: String) -> [Int32]? {
        return WKSessionDao.shared.getSubDevices(address: name)
    }

    func store(session: Data, for address: SignalAddress, userRecord: Data?) -> Bool {
        objc_sync_enter(lock)
        defer {
            objc_sync_exit(lock)
        }
        let oldSession = WKSessionDao.shared.getSession(address: address.name, device: address.deviceId)
        if oldSession == nil {
            let newSession = Session(address: address.name,
                                     device: address.deviceId,
                                     record: session,
                                     timestamp: Date().timeIntervalSince1970)
            WKSessionDao.shared.save(session: newSession)
        } else if oldSession!.record != session {
          
            WKSessionDao.shared.updateSession(record: session, address: address.name, device: address.deviceId)
        }
        return true
    }

    func containsSession(for address: SignalAddress) -> Bool {
        return WKSessionDao.shared.sessionExists(address: address.name, device: address.deviceId)
    }

    func deleteSession(for address: SignalAddress) -> Bool? {
        return WKSessionDao.shared.delete(address: address.name, device: address.deviceId)
    }

    func deleteAllSessions(for name: String) -> Int? {
        return WKSessionDao.shared.delete(address: name)
    }


}

class LiMaoSignedPreKeyStore: SignedPreKeyStore {
    
    private let lock = NSLock()
    
    func load(signedPreKey: UInt32) -> Data? {
        return WKSignedPreKeyDao.shared.getSignedPreKey(signedPreKeyId: Int(signedPreKey))?.record
    }

    func store(signedPreKey: Data, for id: UInt32) -> Bool {
        objc_sync_enter(lock)
        defer {
            objc_sync_exit(lock)
        }
        let key = SignedPreKey(preKeyId: Int(id),
                               record: signedPreKey,
                               timestamp: Date().timeIntervalSince1970)
        return WKSignedPreKeyDao.shared.save(signedPreKey: key)
    }

    func contains(signedPreKey: UInt32) -> Bool {
        return WKSignedPreKeyDao.shared.getSignedPreKey(signedPreKeyId: Int(signedPreKey)) != nil
    }

    func remove(signedPreKey: UInt32) -> Bool {
        return WKSignedPreKeyDao.shared.delete(signedPreKeyId: Int(signedPreKey))
    }


}


class LiMaoSenderKeyStore: SenderKeyStore {
    private let lock = NSLock()
    
    func store(senderKey: Data, for address: SignalSenderKeyName, userRecord: Data?) -> Bool {
        objc_sync_enter(lock)
        defer {
            objc_sync_exit(lock)
        }
        let senderKey = SenderKey(groupId: address.groupId,
                                  senderId: address.sender.toString(),
                                  record: senderKey)
        return WKSenderKeyDao.shared.save(senderKey: senderKey)
    }

    func loadSenderKey(for address: SignalSenderKeyName) -> (senderKey: Data, userRecord: Data?)? {
        guard let senderKey = WKSenderKeyDao.shared.getSenderKey(groupId: address.groupId, senderId: address.sender.toString()) else {
            return nil
        }
        return (senderKey.record, nil)
    }
    


}
