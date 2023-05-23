//
//  WKSessionDao.swift
//  WuKongIMSDK
//
//  Created by tt on 2021/9/7.
//

import Foundation

public struct Session {
    
    public let address: String
    public let device: Int32
    public let record: Data
    public let timestamp: TimeInterval
    
    public init(address: String, device: Int32, record: Data, timestamp: TimeInterval) {
        self.address = address
        self.device = device
        self.record = record
        self.timestamp = timestamp
    }
    
}

public class WKSessionDao {
    public static let shared = WKSessionDao()
    
    func save(session:Session) {
        WKDB.shared().dbQueue.inDatabase { db in
            try! db.executeUpdate("insert into sessions(address,device,record,timestamp) values(?,?,?,?)", values: [session.address,session.device,session.record.base64EncodedString(),session.timestamp])
        }
    }
    
    func sessionExists(address: String, device: Int32) -> Bool {
        var cn :Int32 = 0
        WKDB.shared().dbQueue.inDatabase { db in
           let result = try! db.executeQuery("select count(*) from sessions where address=? and device=?", values: [address,device])
            if(result.next()) {
                 cn = result.int(forColumnIndex: 0)
            }
            result.close()
            
        }
        return cn>0
    }
    
    func getCount() -> Int {
        var cn :Int32 = 0
        WKDB.shared().dbQueue.inDatabase { db in
           let result = try! db.executeQuery("select count(*) from sessions", values: [])
            if(result.next()) {
                 cn = result.int(forColumnIndex: 0)
            }
            result.close()
            
        }
        return Int(cn)
    }
    func getSession(address: String, device: Int32) -> Session? {
        var session :Session?
        WKDB.shared().dbQueue.inDatabase { db in
           let result = try! db.executeQuery("select * from sessions where address=? and device=?", values: [address,device])
            if(result.next()) {
                session = toSession(result: result)
            }
            result.close()
            
        }
        return session
    }
    func getSessions(address: String) -> [Session] {
        var sessions :[Session] = []
        WKDB.shared().dbQueue.inDatabase { db in
           let result = try! db.executeQuery("select * from sessions where address=?", values: [address])
            while(result.next()) {
                sessions.append(toSession(result: result))
            }
            result.close()
            
        }
        return sessions
    }
    
    func getSubDevices(address: String) -> [Int32] {
        var deviceIDs:[Int32] = []
        WKDB.shared().dbQueue.inDatabase { db in
           let result = try! db.executeQuery("select device from sessions where address=? and device<>1", values: [address])
            while(result.next()) {
                deviceIDs.append(result.int(forColumn: "device"))
            }
            result.close()
            
        }
        return deviceIDs
    }
    
    public func getSessionAddress() -> [Session] {
        var sessions :[Session] = []
        WKDB.shared().dbQueue.inDatabase { db in
           let result = try! db.executeQuery("select * from sessions where device=1",values: [])
            while(result.next()) {
                sessions.append(toSession(result: result))
            }
            result.close()
            
        }
        return sessions
    }
    
    public func updateSession(record :Data,address: String, device: Int32) {
        WKDB.shared().dbQueue.inDatabase { db in
            try! db.executeUpdate("update sessions set record=?, timestamp=? where address=? and device=?", values: [record.base64EncodedString(),Date().timeIntervalSince1970,address,device])
        }
    }
    func delete(address: String) -> Int  {
        WKDB.shared().dbQueue.inDatabase { db in
            try! db.executeUpdate("delete from sessions where address=?", values: [address])
        }
        return 1
    }
    
    func delete(address: String, device: Int32) -> Bool {
        WKDB.shared().dbQueue.inDatabase { db in
            try! db.executeUpdate("delete from sessions where address=? and device=?", values: [address,device])
        }
        return true
    }
    
    func toSession(result:FMResultSet) -> Session {
        let address = result.string(forColumn: "address") ?? ""
        let device = result.int(forColumn: "device")
        let record = result.string(forColumn: "record") ?? ""
        let timestamp = result.int(forColumn: "timestamp")
        return Session(address: address, device: device, record: Data(base64Encoded: record) ?? Data(), timestamp: TimeInterval(timestamp))
    }
}
