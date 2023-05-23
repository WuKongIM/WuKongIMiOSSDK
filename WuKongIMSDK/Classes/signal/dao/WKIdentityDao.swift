//
//  WKIdentityDao.swift
//  WuKongIMSDK
//
//  Created by tt on 2021/9/3.
//

import Foundation

public struct WKIdentity {
    let address: String?
    let registrationId: UInt32?
    let publicKey: Data
    let privateKey: Data?
    let nextPreKeyId: UInt64?
    let timestamp: TimeInterval
    
    init(resultSet: FMResultSet) {
        self.address = resultSet.string(forColumn: "address")
        self.registrationId = UInt32(resultSet.int(forColumn: "registration_id"))
        let publicK = resultSet.string(forColumn: "public_key") ?? ""
        let privateK = resultSet.string(forColumn: "private_key") ?? ""
        self.nextPreKeyId = resultSet.unsignedLongLongInt(forColumn: "next_prekey_id")
        self.timestamp = TimeInterval(resultSet.int(forColumn: "timestamp"))
        
        self.publicKey = Data(base64Encoded: publicK) ?? Data()
        self.privateKey = Data(base64Encoded: privateK) ?? Data()
    }
    init(address:String?,registrationId:UInt32?,publicKey:Data,privateKey:Data?,nextPreKeyId:UInt64?,timestamp:TimeInterval) {
        self.address = address
        self.registrationId = registrationId
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.nextPreKeyId = nextPreKeyId
        self.timestamp = timestamp
    }
    
}

extension WKIdentity {
    
    func getIdentityKeyPair() -> KeyPair {
        return KeyPair(publicKey: publicKey, privateKey: privateKey!)
    }
    
}

public class WKIdentityDao {
    public static let shared = WKIdentityDao()
    
//    public func saveLocalIdentity() {
//        self.saveOrUpdateIdentity(identity: WKIdentity(address: "-1", registrationId: 0, publicKey: "", privateKey: "", nextPreKeyId: 0, timestamp: 0))
//    }
    
    
    public func saveOrUpdateIdentity(identity:WKIdentity!) {
        WKDB.shared().dbQueue.inDatabase { db in
            try! db.executeUpdate("insert into identities(address,registration_id,public_key,private_key,next_prekey_id,`timestamp`) values(?,?,?,?,?,?) ON CONFLICT(address) DO UPDATE SET registration_id=excluded.registration_id,public_key=excluded.public_key,private_key=excluded.private_key,next_prekey_id=excluded.next_prekey_id,`timestamp`=excluded.timestamp", values: [identity.address!,(identity.registrationId ?? 0),identity.publicKey.base64EncodedString(),identity.privateKey?.base64EncodedString() ??  "" ,(identity.nextPreKeyId ?? 0),(identity.timestamp ?? 0)])

        }
    }
    
    public func getIdentity(address:String) -> WKIdentity? {
        var identity :WKIdentity?
        WKDB.shared().dbQueue.inDatabase { db in
           let resultSet = try! db.executeQuery("select * from identities where address=?", values: [address])
            if(resultSet.next()) {
                identity = WKIdentity(resultSet: resultSet)
            }
            resultSet.close()
        }
        return identity;
    }
    
    public func deleteIdentity(address: String) {
        WKDB.shared().dbQueue.inDatabase { db in
            db.executeUpdate("delete from identities where address=?", withArgumentsIn: [address])
        }
    }
}
