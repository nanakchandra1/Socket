//
//  ServiceController.swift
//  UserApp
//
//  Created by Appinventiv on 25/09/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import SwiftyJSON

typealias socketSuccessBlock = ((Bool,JSON) -> Void)
typealias socketFailureBlock = (() -> Void)

typealias successBlock = ((Bool,JSON) -> Void)
typealias failureBlock = ((Error) -> Void)

extension NSError {
    
    convenience init(localizedDescription : String) {
        
        self.init(domain: "AppNetworkingError", code: 0, userInfo: [NSLocalizedDescriptionKey : localizedDescription])
        
    }
    
    convenience init(code : Int, localizedDescription : String) {
        
        self.init(domain: "AppNetworkingError", code: code, userInfo: [NSLocalizedDescriptionKey : localizedDescription])
        
    }
}


class ServiceController {
    
    class func signUpApi(_ params:JSONDictionary, userImage: [String:UIImage]? ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POSTWithImage(endPoint: URLName.SignUpApiUrl,parameters: params, image: userImage ,success: { (json) in
            
            print_debug(json)
            let message = json["message"].stringValue
            if json["statusCode"].intValue == 219{
                
                SuccessBlock(true,json)
                
            }else{
                showToastWithMessage(message)
                SuccessBlock(false,json)
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
        
    }
    
    
    
    class func loginApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.LoginApiUrl, parameters: params, loader: true, success: { (json) in
            
            
            SuccessBlock(true,json)
            
        }) { (error) in
            
            failureBlock(error)
            
        }
    }
    
    
    class func forgotPassowrdApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.ForgotPasswordApiUrl, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
        }) { (error) in
            
            failureBlock(error)
            
        }
        
    }
    
    
    class func varifyforgotPassowrdOtpApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.validateforgotUrl, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
        }) { (error) in
            
            failureBlock(error)
            
        }
        
    }

    
    class func verifyOTPApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        
        AppNetworking.POST(endPoint: URLName.VerifyOtpApiUrl, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
            
        }) { (error) in
            
            failureBlock(error)
            
        }
        
    }
    
    
    class func sendOTPApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.SendOTPUrl, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
        
    }
    
    
    class func updatePasswordApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.ChangePasswordUrl, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
        }) { (error) in
            
            failureBlock(error)
            
        }
    }
    
    
    class func add_update_VehicleApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.getvehicleUrl, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
        }) { (error) in
            
            failureBlock(error)
            
        }
        
    }
    
    
    class func googlePlacesAPI(_ params:String ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.GET(endPoint: params, success: { (json) in
            
            let status = json["status"].string ?? ""
            
            if status == "OK"{
                SuccessBlock(true, json)
            }
            
        }) { (error) in
            
            failureBlock(error)
        }
        
    }
    
    
    
    class func googleGeocodeApi(_ params:JSONDictionary, SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.GET(endPoint: URLName.googleGeocodeUrl, parameters: params, headers: ["":""], loader: false, success: { (json) in
            
            SuccessBlock(true, json)
            
        }) { (error) in
            
            failureBlock(error)
            
        }
        
    }
    
    
    class func getLatLong(_ params:JSONDictionary, SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.GET(endPoint: URLName.placeDetailUrl, parameters: params, headers: ["":""], loader: false, success: { (json) in
            
            SuccessBlock(true, json)
            
        }) { (error) in
            
            failureBlock(error)
        }
    }
    
    
    
    class func getPreviousLocations(SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        
        AppNetworking.POST(endPoint: URLName.getPreviousLocs, parameters: ["":""], loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
        
    }
    
    
    
    class func getvehicleApi(_ params: JSONDictionary , SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.getvehicleUrl, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
        }) { (error) in
            
            CommonClass.stopLoader()
            printlnDebug(error)
            failureBlock(error)
            
        }
    }
    
    
    class func logOutApi(_ SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.LogoutUrl, parameters: ["":""], loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
    }
    
    
    class func editProfile(_ params:JSONDictionary, userImage: [String:UIImage]? ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POSTWithImage(endPoint: URLName.editprofileURL,parameters: params, image: userImage ,success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            failureBlock(error)
            
        }
    }
    
    
    class func changeMobileEditProfileApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        
        AppNetworking.POSTWithImage(endPoint: URLName.SignUpApiUrl, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
    }
    
    
    class func update_remove_VehicleApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.getvehicleUrl, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
        
    }
    
    
    class func staticPagesService(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.staticPagesUrl, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
        
    }
    
    
    class func postQueryService(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.postQueryUrl, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
    }
    
    
    class func rateApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.rateUrl, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
        }) { (error) in
            
            failureBlock(error)
            
        }
        
    }
    
    
    
    class func promotionApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.promotionUrl, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
    }
    
    
    
    class func notificationApi(SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.notificationURL, parameters: [:], loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
    }
    
    
    class func saveLocationApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.saveLocationUrl, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
        
    }
    
    class func scheduleRideApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.scheduleUrl, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
        
    }
    
    
    class func rideHistoryApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.rideHistoryURL, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
    }
    
    
    
    class func subsViewCoupons(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.SubsViewCouponsURL, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
    }
    
    
    
    class func shareCouponsApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.shareCoupon, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
        
    }
    
    
    class func myTransactionApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.myTransURL, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                let result = json["result"]
                
                SuccessBlock(true,result)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
    }
    
    class func subsAddUserMonetApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.subsPaymentURL, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
    }
    
    
    class func applyCouponsAPI(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.applyCouponsURL, parameters: params, loader: true, success: { (json) in
            
            showToastWithMessage(json["message"].stringValue)
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
    }
    
    
    class func addUserCardAPI(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.addUserCardURL, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
        
    }
    
    
    class func setDefaultPayMethodAPI(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.setDefaultPaymentMethodURL, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
        
    }
    
    
    class func saveCardDetailAPI(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.saveCardDetailURL, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
    }
    
    
    class func removeSaveCardApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.removeSaveCardDetailURL, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 147{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
    }
    
    
    class func rideactionApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.rideActionURL, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
    }
    
    
    class func getEatApi(_ source:String,destination:String, SuccessBlock:@escaping successBlock, failureBlock: @escaping failureBlock){
        
        let url = "https://maps.googleapis.com/maps/api/distancematrix/json?&origins=\(source)&destinations=\(destination)"
        
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        AppNetworking.GET(endPoint: encodedUrl!, success: { (json) in
            
            SuccessBlock(true,json)
            
        }) { (error) in
            
            failureBlock(error)
            
        }
        
    }
    
    
    class func getRideFareApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.getFare, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
        
    }
    
    
    
    class func notificationStatusApi(_ params:JSONDictionary ,SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        AppNetworking.POST(endPoint: URLName.notificationstatusURL, parameters: params, loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
    }
    
    
    class func getAvailableAPI(_ SuccessBlock: @escaping successBlock, failureBlock: @escaping failureBlock){
        
        
        AppNetworking.POST(endPoint: URLName.availableCouponsURL, parameters: ["": ""], loader: true, success: { (json) in
            
            if json["statusCode"].intValue == 200{
                
                SuccessBlock(true,json)
                
            }else{
                
                SuccessBlock(false,json)
                
            }
            
        }) { (error) in
            
            failureBlock(error)
            
        }
    }
}

    
    

