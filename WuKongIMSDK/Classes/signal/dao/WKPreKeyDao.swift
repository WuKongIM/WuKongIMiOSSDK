//
//  WKPreKeyDao.swift
//  WuKongIMSDK
//
//  Created by tt on 2021/9/7.
//

import Foundation


struct PreKey {
    
    let preKeyId: Int
    let record: Data
    
    init(preKeyId: Int, record: Data) {
        self.preKeyId = preKeyId
        self.record = record
    }
    
}

public class WKPreKeyDao {
    public static let shared = WKPreKeyDao()
    
    func getPreKey(with id: Int) -> PreKey? {
        var preKey :PreKey?
        WKDB.shared().dbQueue.inDatabase { db in
           let result =  try! db.executeQuery("select * from prekeys where pre_key_id=?", values: [id])
            if(result.next()) {
                let preKeyID = result.int(forColumn: "pre_key_id")
                let record = result.string(forColumn: "record") ?? ""
                preKey = PreKey(preKeyId: Int(preKeyID), record: Data(base64Encoded: record) ?? Data())
            }
            result.close()
        }
        return preKey
    }
    
    func savePreKey(_ preKey: PreKey) -> Bool {
        WKDB.shared().dbQueue.inDatabase { db in
            try! db.executeUpdate("insert into prekeys(pre_key_id,record) values(?,?)", values: [preKey.preKeyId,preKey.record.base64EncodedString()])
        }
        return true
    }
    
    func savePreKeys(_ preKeys: [PreKey]) -> Bool {
        for  preKey in preKeys {
            self.savePreKey(preKey)
        }
        return true
    }
    
    func deletePreKey(with id: Int) -> Bool {
        WKDB.shared().dbQueue.inDatabase { db in
            try! db.executeUpdate("delete from prekeys where pre_key_id=?", values: [id])
        }
        return true
    }
    
    
}
