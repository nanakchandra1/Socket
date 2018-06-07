//
//  UserData.swift
//  UserApp
//
//  Created by Appinventiv on 25/02/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

let userdata = UserData.sharedInstance

final class UserData {
    
    static let sharedInstance = UserData()
    
    func saveJSONDataToUserDefault(_ resDict : JSON) {
        
        if let name = resDict["name"].string{
            UserDefaults.save(name, forKey: NSUserDefaultsKeys.FULL_NAME)
        }
        
        if let email = resDict["email"].string{
            UserDefaults.save(email, forKey: NSUserDefaultsKeys.EMAIL)
        }
        
        if let mobile = resDict["phone"].string{
            UserDefaults.save(mobile, forKey: NSUserDefaultsKeys.MOBILE)
        }
        
        if let countryCode = resDict["country_code"].string{
            UserDefaults.save(countryCode, forKey: NSUserDefaultsKeys.COUNTRY_CODE)
        }
        
        if let token = resDict["token"].string{
            UserDefaults.save(token, forKey: NSUserDefaultsKeys.TOKEN)
        }
        
        if let ride_id = resDict["ride_id"].string, !ride_id.isEmpty{
            UserDefaults.save(ride_id, forKey: NSUserDefaultsKeys.RIDE_ID)
        }

        if let default_pmode = resDict["default_pmode"].string{
        
            UserDefaults.save(default_pmode , forKey: NSUserDefaultsKeys.P_MODE)

        }
        
        if let image = resDict["image"].string{
            UserDefaults.save(image , forKey: NSUserDefaultsKeys.USER_IMAGE)
        }
        if let gender = resDict["gender"].string{
            UserDefaults.save(gender , forKey: NSUserDefaultsKeys.GENDER)
        }
        if let dob = resDict["dob"].string{
            UserDefaults.save(dob , forKey: NSUserDefaultsKeys.DOB)
        }
        
        if let vehicles = resDict["vehicles"].array{
            
            if vehicles.isEmpty{
                
                UserDefaults.save("n" , forKey: NSUserDefaultsKeys.VEHICLES)

                
            }else{
                
                UserDefaults.save("y" , forKey: NSUserDefaultsKeys.VEHICLES)

            }
            
        }else{
            
            UserDefaults.save("n", forKey: NSUserDefaultsKeys.VEHICLES)

        }
        
        if let noti = resDict["notification_status"].string{
            UserDefaults.save("\(noti)" , forKey: NSUserDefaultsKeys.NOTIFICATION_STATUS)
        }
        
        
            UserDefaults.save(resDict["balance"].stringValue , forKey: NSUserDefaultsKeys.SUBSCRIPTION_AMNT)
            
        if let saveLoc = resDict["savedlocs"].arrayObject{
        
            UserDefaults.save(saveLoc, forKey: NSUserDefaultsKeys.SAVE_LOC)
        }
        
        if let mycoupon = resDict["myCoupon"].array{
            if !mycoupon.isEmpty{
                UserDefaults.save(mycoupon.first!, forKey: NSUserDefaultsKeys.MY_COUPON)
                printlnDebug(CurrentUser.my_coupon)
            }
        }
        if let fb_id = resDict["fb_id"].string{
            UserDefaults.save(fb_id , forKey: NSUserDefaultsKeys.SOCIAL_ID)
        }
        
        if let google_id = resDict["google_id"].string{
            UserDefaults.save(google_id , forKey: NSUserDefaultsKeys.SOCIAL_ID)
        }
        
        if let twt_id = resDict["twt_id"].string{
            UserDefaults.save(twt_id , forKey: NSUserDefaultsKeys.SOCIAL_ID)
        }
        
        if let userType = resDict["type"].string{
            UserDefaults.save(userType , forKey: NSUserDefaultsKeys.USER_TYPE)
        }
        
        if let stripe_id = resDict["stripe"].string{
            UserDefaults.save(stripe_id , forKey: NSUserDefaultsKeys.STRIPE_ID)
        }
        

        UserDefaults.save(resDict["is_mobile_verified"].stringValue , forKey: NSUserDefaultsKeys.is_mobile_verified)

        
        if (resDict["rides"].dictionary) != nil{
            UserDefaults.save("init", forKey: NSUserDefaultsKeys.RIDE_STATE)
        }
    }
    
}

