//
//  NSUserDefaults.swift
//  UserApp
//
//  Created by Appinventiv on 23/09/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

//MARK:- extension for NSUserDefault
//MARK:- ************************************

extension UserDefaults {
    //MARK: UserDefault
    
    class func save(_ value:Any,forKey key:String)     {
        
        UserDefaults.standard.set(value, forKey:key)
        UserDefaults.standard.synchronize()
        
    }
    
    class func userDefaultForKey(_ key:String) -> AnyObject? {
        
        if let value: AnyObject =  UserDefaults.standard.object(forKey: key) as AnyObject {
            return value
        } else {
            return nil
        }
    }
    
    class func userdefaultStringForKey(_ key:String) -> String? {
        
        if let value =  UserDefaults.standard.object(forKey: key) as? String {
            
            return value
            
        } else {
            return nil
        }
    }
    
    
    class func userdefaultBoolForKey(_ key:String) -> Bool? {
        
        if let value =  UserDefaults.standard.object(forKey: key) as? Bool {
            
            return value
            
        } else {
            return nil
        }
    }

    
    class func userdefaultStringArrayForKey(_ key:String) -> [String]? {
        
        if let value =  UserDefaults.standard.object(forKey: key) as? [String] {
            
            return value
            
        } else {
            return nil
        }
    }

    
    class func removeFromUserDefaultForKey(_ key:String) {
        
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    
    class func clearUserDefaults() {
        
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        UserDefaults.standard.synchronize()
        UserDefaults.save(true as AnyObject, forKey: NSUserDefaultsKeys.ISFIRSTTIME)
        SocketManegerInstance.closeConnection()
        
    }
}
