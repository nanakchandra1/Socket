//
//  DigestAuth.swift
//  UserApp
//
//  Created by Appinventiv on 07/11/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import CommonCrypto

class DigestAuth{

    //    Digest Auth
    //    ============
    static func getDigestHeader(method : String, uri : String) -> String{
        
        let cnonce = "\(NSDate().timeIntervalSince1970 * 1000)"
        
        let ha1 = getMD5Hex(md5Data: MD5(string : (getMD5Hex(md5Data: MD5(string : (Constants.user + ":" + Constants.realm + ":" + Constants.pass))) + ":" + Constants.nonce + ":" + cnonce)))
        
        let ha2 = getMD5Hex(md5Data: MD5(string: (method + ":" + uri)))
        
        let response = getMD5Hex(md5Data: MD5(string : (ha1 + ":" + Constants.nonce + ":" + Constants.nonceCount + ":" + cnonce + ":" + Constants.qop + ":" + ha2)))
        
        let digestHeader = "Digest username=\"\(Constants.user)\", realm=\"\(Constants.realm)\", nonce=\"\(Constants.nonce)\", uri=\"\(uri)\", qop=\(Constants.qop), nc=\(Constants.nonceCount), cnonce=\"\(cnonce)\", response=\"\(response)\", opaque="
        
        return digestHeader
    }
    
    private static func MD5(string: String) -> Data? {
        guard let messageData = string.data(using:String.Encoding.utf8) else { return nil }
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData
    }
    
    private static func getMD5Hex(md5Data : Data?) -> String
    {
        if md5Data == nil
        {
            return ""
        }
        return md5Data!.map { String(format: "%02hhx", $0) }.joined()
    }
    
}
