//
//  WKSignedPreKeyDao.swift
//  WuKongIMSDK
//
//  Created by tt on 2021/9/7.
//

import Foundation

struct SignedPreKey {
    
    let preKeyId: Int
    let record: Data
    let timestamp: TimeInterval
    
    init(preKeyId: Int, record: Data, timestamp: TimeInterval) {
        self.preKeyId = preKeyId
        self.record = record
        self.timestamp = timestamp
    }
    
}


internal class WKSignedPreKeyDao {
    static let shared = WKSignedPreKeyDao()
    
    func save(signedPreKey:SignedPreKey) -> Bool {
        WKDB.shared().dbQueue.inDatabase { db in
            try! db.executeUpdate("insert into signed_prekeys(pre_key_id,record,timestamp) values(?,?,?)", values: [signedPreKey.preKeyId,signedPreKey.record.base64EncodedString(),signedPreKey.timestamp])
        }
        return true
    }
    
    func getSignedPreKey(signedPreKeyId: Int) -> SignedPreKey? {
        var signedPreKey :SignedPreKey?
        WKDB.shared().dbQueue.inDatabase { db in
           let result =  try! db.executeQuery("select * from signed_prekeys where pre_key_id=?", values: [signedPreKeyId])
            if(result.next()) {
                signedPreKey = toSignedPreKey(result: result)
            }
            result.close()
        }
        return signedPreKey
    }
    
    func getSignedPreKeyList() -> [SignedPreKey] {
        var signedPreKeys :[SignedPreKey] = []
        WKDB.shared().dbQueue.inDatabase { db in
           let result =  try! db.executeQuery("select * from signed_prekeys", values: [])
            while(result.next()) {
                signedPreKeys.append(toSignedPreKey(result: result))
            }
            result.close()
        }
        return signedPreKeys
    }
    
    func delete(signedPreKeyId: Int) -> Bool {
        WKDB.shared().dbQueue.inDatabase { db in
           try! db.executeUpdate("delete from signed_prekeys where pre_key_id=?", values: [signedPreKeyId])
        }
        return true
    }
    
    func toSignedPreKey(result:FMResultSet) ->SignedPreKey {
        let preKeyId = result.int(forColumn: "pre_key_id")
        let record = result.string(forColumn: "record") ?? ""
        let timestamp = result.int(forColumn: "timestamp")
        
        return SignedPreKey(preKeyId: Int(preKeyId), record: Data(base64Encoded: record) ?? Data(), timestamp: TimeInterval(timestamp))
    }
}
