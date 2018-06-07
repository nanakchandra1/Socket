//
//  CurrentUser.swift
//  UserApp
//
//  Created by Appinventiv on 23/09/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import Foundation

class CurrentUser{
    
    static var full_name : String? {
        
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.FULL_NAME)
    }
    static var email : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.EMAIL)
    }
    static var mobile : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.MOBILE)
    }

    static var token : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.TOKEN)
    }
    static var country_code : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.COUNTRY_CODE)
    }
    static var user_image : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.USER_IMAGE)
    }
    static var gender : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.GENDER)
    }
    static var dob : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.DOB)
    }

    static var social_id : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.SOCIAL_ID)
    }
    
    static var p_mode : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.P_MODE)
    }

    static var card_token : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.CARD_TOKEN)
    }


    static var userType : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.USER_TYPE)
    }

    static var amount : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.SUBSCRIPTION_AMNT)
    }

    static var userData : AnyObject?{
        return UserDefaults.userDefaultForKey(NSUserDefaultsKeys.USERDATA)
    }

    static var vehicles : String?{
        
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.VEHICLES)

    }
    
    static var saveLoc : AnyObject?{
        return UserDefaults.userDefaultForKey(NSUserDefaultsKeys.SAVE_LOC)
    }

    
    static var my_coupon : AnyObject?{
        return UserDefaults.userDefaultForKey(NSUserDefaultsKeys.MY_COUPON)
    }

    static var stripe : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.STRIPE_ID)
    }
    
    static var ride_state : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.RIDE_STATE)
    }
    
    static var ride_id : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.RIDE_ID)
    }

    static var driver_arriving_state : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.DRIVER_ARRIVING_STATE)
    }

    static var change_loc : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.CHANGE_LOC)
    }
    
    static var notification_status : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.NOTIFICATION_STATUS)
    }

    static var mobileVerified : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.is_mobile_verified)
    }

    static var ISFIRSTTIME : Bool? {
        return UserDefaults.userdefaultBoolForKey(NSUserDefaultsKeys.ISFIRSTTIME)
    }

    static var country : String? {
        return UserDefaults.userdefaultStringForKey(NSUserDefaultsKeys.COUNTRY)
    }

    static var isRideAvailable: Bool{
        
        if let vehicle = self.ride_id{
            
            if vehicle.isEmpty{
                
                return false
                
            }else{
                return true
            }
        }else{
            
            return false
            
        }
    }

    static var isVehicle: Bool{
    
        if let vehicle = self.vehicles{
        
            if vehicle.isEmpty || vehicle == "n"{
                
                return false

            }else{
                
                return true

            }
        }else{
            
            return false

        }
    }
    
    // MARK: Changed by Aakash
    static var isLogged : AnyObject?{
        return UserDefaults.userDefaultForKey(NSUserDefaultsKeys.ISUSERLOGGEDIN)
    }
    
    static var isLoggedIn : Bool {
        if let _ = self.isLogged{
            return true
        }
        else {
            return false
        }
    }
    // MARK: Upto here
    
    static var isUserLoggedIn : Bool {
        
        if self.token != nil {
            
            return true
        }
            
        else {
            
            return false
        }
    }
    
    static var is_mobileVerified : Bool {
        
        if let mobile_Verified = self.mobileVerified{
            
            if mobile_Verified.isEmpty || mobile_Verified == "0"{
                
                return false
                
            }else{
                
                return true
                
            }
        }else{
            
            return false
            
        }
    }

    
    static var getDob : String {
        
        if let d_o_b = self.dob {
            
            return setDateFormat(d_o_b)
        }
        else {
            
            return ""
        }
    }
    
    static var getUserImage : URL? {
        
        if let user_image = self.user_image , !user_image.isEmpty{
            
            let imageUrlStr = baseUrl + user_image
            
            if let imageUrl = URL(string: imageUrlStr) {
                
                return imageUrl
                
            }else{
                
                return nil
            }
        }
        else {
            
            return nil
        }
    }

    

}
