//
//  WKSenderKeyDao.swift
//  WuKongIMSDK
//
//  Created by tt on 2021/9/7.
//

import Foundation

public final class SenderKey {
    
    public let groupId: String
    public let senderId: String
    public let record: Data
    
    public init(groupId: String, senderId: String, record: Data) {
        self.groupId = groupId
        self.senderId = senderId
        self.record = record
    }
    
}

public class WKSenderKeyDao {
    public static let shared = WKSenderKeyDao()
    
    
    func save(senderKey:SenderKey) -> Bool {
        WKDB.shared().dbQueue.inDatabase { db in
            try! db.executeUpdate("insert into sender_keys(group_id,sender_id,record) values(?,?,?)", values: [senderKey.groupId,senderKey.senderId,senderKey.record.base64EncodedString()])
        }
        return true
    }
    
    func getSenderKey(groupId: String, senderId: String) -> SenderKey? {
        var senderKey:SenderKey?
        WKDB.shared().dbQueue.inDatabase { db in
           let result = try! db.executeQuery("select * from sender_keys where group_id=? and sender_id=?", values: [groupId,senderId])
            if(result.next()) {
                senderKey = toSenderKey(result: result)
            }
            result.close()
        }
        return senderKey
    }
    
    @discardableResult
    func delete(groupId: String, senderId: String) -> Bool {
        WKDB.shared().dbQueue.inDatabase { db in
            try! db.executeUpdate("delete from sender_keys where group_id=? and sender_id=?", values: [groupId,senderId])
        }
        return true
    }
    
    public func getAllSenderKeys() -> [SenderKey] {
        var senderKeys:[SenderKey] = []
        WKDB.shared().dbQueue.inDatabase { db in
           let result = try! db.executeQuery("select * from sender_keys", values: [])
            while(result.next()) {
                senderKeys.append(toSenderKey(result: result))
            }
            result.close()
        }
        return senderKeys
    }
    
    func toSenderKey(result:FMResultSet) -> SenderKey{
       let groupID = result.string(forColumn: "group_id") ?? ""
       let senderID = result.string(forColumn: "sender_id") ?? ""
        let record = result.string(forColumn: "record") ?? ""
        return SenderKey(groupId: groupID, senderId: senderID, record: Data(base64Encoded: record) ?? Data())
    }
}
