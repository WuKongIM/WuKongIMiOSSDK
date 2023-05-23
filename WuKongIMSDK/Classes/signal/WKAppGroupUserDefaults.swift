//
//  WKAppGroupUserDefaults.swift
//  WuKongIMSDK
//
//  Created by tt on 2021/9/8.
//

import Foundation

public enum WKAppGroupUserDefaults {
    internal static let defaults = UserDefaults(suiteName: "group.im.limao.messenger")!
    
    public enum Namespace {
        case signal
        case crypto
        
        var stringValue: String {
            if self == .signal {
                return "signal"
            } else if self == .crypto {
                return "crypto"
            }
            fatalError("Unhandled namespace")
        }
    }
    
    @propertyWrapper
    public class Default<Value> {
        fileprivate let namespace: Namespace?
        fileprivate let key: String
        fileprivate let defaultValue: Value
        
        fileprivate var wrappedKey: String {
            Self.wrappedKey(forNamespace: namespace, key: key)
        }
        // default values are returned as is without writting back
        public init(namespace: Namespace?, key: String, defaultValue: Value) {
            self.namespace = namespace
            self.key = key
            self.defaultValue = defaultValue
        }
        // default values are returned as is without writting back
        public convenience init<KeyType: RawRepresentable>(namespace: Namespace?, key: KeyType, defaultValue: Value) where KeyType.RawValue == String {
            self.init(namespace: namespace, key: key.rawValue, defaultValue: defaultValue)
        }
        public var wrappedValue: Value {
            get {
                defaults.object(forKey: wrappedKey) as? Value ?? defaultValue
            }
            set {
                if let newValue = newValue as? AnyOptional, newValue.isNil {
                    defaults.removeObject(forKey: wrappedKey)
                } else {
                    defaults.set(newValue, forKey: wrappedKey)
                }
            }
        }
        
        static func wrappedKey(forNamespace namespace: Namespace?, key: String) -> String {
            if let namespace = namespace {
                return namespace.stringValue + "." + key
            } else {
                return key
            }
        }
    }
    @propertyWrapper
    public class RawRepresentableDefault<Value: RawRepresentable>: Default<Value> where Value.RawValue: PropertyListType {
        
        public override var wrappedValue: Value {
            get {
                if let rawValue = defaults.object(forKey: wrappedKey) as? Value.RawValue, let value = Value(rawValue: rawValue) {
                    return value
                } else {
                    return defaultValue
                }
            }
            set {
                defaults.set(newValue.rawValue, forKey: wrappedKey)
            }
        }
        
    }
}

extension WKAppGroupUserDefaults {
    public enum Crypto {
        
        enum Key: String, CaseIterable {
            case statusOffset = "status_offset"
            case prekeyOffset = "prekey_offset"
            case signedPrekeyOffset = "signed_prekey_offset"
            case isPrekeyLoaded = "prekey_loaded"
            case isSessionSynchronized = "session_synchronized"
            case oneTimePrekeyRefreshDate = "one_time_prekey_refresh_date"
            case iterator = "iterator"
        }
        
        public enum Offset {
            
            
            @Default(namespace: .crypto, key: Key.prekeyOffset, defaultValue: nil)
            public static var prekey: UInt32?
            
            @Default(namespace: .crypto, key: Key.signedPrekeyOffset, defaultValue: nil)
            public static var signedPrekey: UInt32?
            
        }
        
    }
}

extension WKAppGroupUserDefaults {
    
    public enum Signal {
        
        enum Key: String, CaseIterable {
            case registrationId = "registration_id"
            case privateKey = "private_key"
            case publicKey = "public_key"
        }
        
        @Default(namespace: .signal, key: Key.registrationId, defaultValue: 0)
        public static var registrationId: UInt32
        
        @Default(namespace: .signal, key: Key.privateKey, defaultValue: Data())
        public static var privateKey: Data
        
        @Default(namespace: .signal, key: Key.publicKey, defaultValue: Data())
        public static var publicKey: Data
        
        internal static func migrate() {
            registrationId = UInt32(UserDefaults.standard.integer(forKey: "local_registration_id"))
            privateKey = UserDefaults.standard.data(forKey: "local_private_key") ?? Data()
            publicKey = UserDefaults.standard.data(forKey: "local_public_key") ?? Data()
        }
        
    }
    
}

public protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }
}

public protocol PropertyListType { }

extension Array: PropertyListType where Element: PropertyListType { }
extension Dictionary: PropertyListType where Key: PropertyListType, Value: PropertyListType { }
extension String: PropertyListType { }
extension Data: PropertyListType { }
extension Date: PropertyListType { }
extension NSNumber: PropertyListType { }
extension Int: PropertyListType { }
extension Float: PropertyListType { }
extension Double: PropertyListType { }
extension Bool: PropertyListType { }
