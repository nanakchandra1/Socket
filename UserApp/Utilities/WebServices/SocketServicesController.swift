//
//  SocketServicesController.swift
//  UserApp
//
//  Created by Appinventiv on 27/10/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

class SocketServicesController{
    
    class func check_Authersation(data: JSON){
    
        let code = data["code"].intValue
        
        if code == 401{
            
            UserDefaults.clearUserDefaults()
            
            CommonClass.goToLogin()
        }

    }
    
    
    class func nearByDriverEmit(_ params:JSONDictionary){
        
        let ack = SocketManegerInstance.socket?.emitWithAck("NearbyDriver", params)
        
        ack?.timingOut(after: 15, callback: { (data) in
            
        })
        
    }

    
    class func nearByDriver_on(_ SuccessBlock: @escaping socketSuccessBlock){
        
        SocketManegerInstance.socket?.on("NearbyDriver_res", callback: { (data, ack) in
            
            CommonClass.stopLoader()
            
            if !data.isEmpty{
                
                let data = JSON(data.first!)
                SuccessBlock(true,data)

            }
        })
        
    }

    
    class func requestRide(_ params:JSONDictionary ){
        
        
        let ack = SocketManegerInstance.socket?.emitWithAck("RequestRide", params)
        
        ack?.timingOut(after: 15, callback: { (data) in
            
            CommonClass.stopLoader()
        })

    }
    
    
    class func rideRequestResponce(_ SuccessBlock: @escaping socketSuccessBlock, failureBlock: @escaping socketFailureBlock){
        
        
        SocketManegerInstance.socket?.on("RequestRide_res", callback: { (data, ack) in
            
            CommonClass.stopLoader()
            
            if !data.isEmpty{
                
                let data = JSON(data.first!)
                self.check_Authersation(data: data)
                SuccessBlock(true,data)
                
            }else{
                
                failureBlock()
            }
            
        })
        
    }
    
    
    
    class func cancelRequestRide(_ params:JSONDictionary){
        
        let ack = SocketManegerInstance.socket?.emitWithAck("CancelRide", params)
        
        ack?.timingOut(after: 15, callback: { (data) in
            
            CommonClass.stopLoader()
        })
        
    }
    
    
    class func rideCancelled(_ SuccessBlock: @escaping socketSuccessBlock, failureBlock: @escaping socketFailureBlock){
    
        SocketManegerInstance.socket?.on("CancelRide_res", callback: { (data, ack) in
            
            CommonClass.stopLoader()
            
            if !data.isEmpty{
                
                UserDefaults.removeFromUserDefaultForKey(NSUserDefaultsKeys.RIDE_ID)
                let data = JSON(data.first!)
                self.check_Authersation(data: data)
                SuccessBlock(true,data)
                showToastWithMessage(data["message"].stringValue)
                
            }else{
                
                failureBlock()
                
            }
            
        })

    }
    
    
    class func driverArrived(_ SuccessBlock: @escaping socketSuccessBlock, failureBlock: @escaping socketFailureBlock){
        
        SocketManegerInstance.socket?.on("DriverArrived", callback: { (data, ack) in
            
            CommonClass.stopLoader()
            
            if !data.isEmpty{
                
                let data = JSON(data.first!)
                self.check_Authersation(data: data)
                SuccessBlock(true,data)
                
            }else{
                
                failureBlock()
                
            }
            
        })
        
        
    }
    
   class func rideStarted(_ SuccessBlock: @escaping socketSuccessBlock, failureBlock: @escaping socketFailureBlock){
    
        SocketManegerInstance.socket?.on("RideStarted", callback: { (data, ack) in
            
            CommonClass.stopLoader()
            
            if !data.isEmpty{
                
                let data = JSON(data.first!)
                self.check_Authersation(data: data)
                SuccessBlock(true,data)
                
            }else{
                
                failureBlock()
                
            }
            
        })

        
    }
    
    
    class func driver_location(_ SuccessBlock: @escaping socketSuccessBlock, failureBlock: @escaping socketFailureBlock){
        
        SocketManegerInstance.socket?.on("UpdatedLocation", callback: { (data, ack) in
            
            CommonClass.stopLoader()
            
            if !data.isEmpty{
                
                let data = JSON(data.first!)
                self.check_Authersation(data: data)
                SuccessBlock(true,data)
                
            }else{
                
                failureBlock()
                
            }
            
        })
    }
    
    
    class func changeDestination(_ params:JSONDictionary){
        
        let ack = SocketManegerInstance.socket?.emitWithAck("ChangeDrop", params)
        
        ack?.timingOut(after: 15, callback: { (data) in
            
            CommonClass.stopLoader()
        })
        
    }

    
    class func changeDestination_res(_ SuccessBlock: @escaping socketSuccessBlock, failureBlock: @escaping socketFailureBlock){
        
        SocketManegerInstance.socket?.on("ChangeDrop_res", callback: { (data, ack) in
            
            CommonClass.stopLoader()
            
            if !data.isEmpty{
                
                let data = JSON(data.first!)
                self.check_Authersation(data: data)
                SuccessBlock(true,data)
                
            }else{
                
                failureBlock()
                
            }
            
        })
    }

    
    class func changeDestination_status(_ SuccessBlock: @escaping socketSuccessBlock, failureBlock: @escaping socketFailureBlock){
        
        SocketManegerInstance.socket?.on("ChangeDropStatus", callback: { (data, ack) in
            
            CommonClass.stopLoader()
            
            if !data.isEmpty{
                
                let data = JSON(data.first!)
                self.check_Authersation(data: data)
                SuccessBlock(true,data)
                
            }else{
                
                failureBlock()
                
            }
            
        })
    }

    
    class func end_ride(_ SuccessBlock: @escaping socketSuccessBlock, failureBlock: @escaping socketFailureBlock){
        
        SocketManegerInstance.socket?.on("RideEnded", callback: { (data, ack) in
            
            CommonClass.stopLoader()
            
            if !data.isEmpty{
                
                let data = JSON(data.first!)
                self.check_Authersation(data: data)
                SuccessBlock(true,data)
                
            }else{
                
                failureBlock()
                
            }
            
        })
    }
    
    
    class func regainRideState(_ params:JSONDictionary ,SuccessBlock: @escaping socketSuccessBlock, failureBlock: @escaping socketFailureBlock){
        
        SocketManegerInstance.socket?.on("RegainState_res", callback: { (data, ack) in
            
            CommonClass.stopLoader()
            
            if !data.isEmpty{
                
                let data = JSON(data.first!)
                
                let code = data["code"].intValue
                
                self.check_Authersation(data: data)

                if code == 200{
                
                    SuccessBlock(true,data)

                }
                
                
            }else{
                
                failureBlock()
            }
            
        })
        
        let ack = SocketManegerInstance.socket?.emitWithAck("RegainState", params)
        
        ack?.timingOut(after: 15, callback: { (data) in
            
            CommonClass.stopLoader()
        })
        
    }
}
