//
//  WKSignal.swift
//  WuKongIMSDK
//
//  Created by tt on 2021/9/3.
//

import Foundation


@objc public class WKSignal:NSObject {
    
   @objc public static func generateIdentityKeyPair()  -> WKKeyPair {
        let keyPair = try! Signal.generateIdentityKeyPair()
        let limKeyPari = WKKeyPair(publicKey: keyPair.publicKey, privateKey: keyPair.privateKey)
        return limKeyPari;
    
    }
    
    @objc public static func generateRegistrationId(extendedRange: Bool = false) -> UInt32 {
        return try! Signal.generateRegistrationId()
    }
}


@objc public class WKKeyPair:NSObject {
    /// The public key data
    @objc public let publicKey: Data

    /// The private key data
    @objc public let privateKey: Data
    /**
     Create a key pair from the components.
     - parameter publicKey: The public key data
     - parameter privateKey: The private key data
     */
    init(publicKey: Data, privateKey: Data) {
        self.publicKey = publicKey
        self.privateKey = privateKey
    }

    
}
