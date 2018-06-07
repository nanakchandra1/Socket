//
//  RequsetARideSocketExtension.swift
//  UserApp
//
//  Created by Appinventiv on 15/11/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import CoreLocation
import SwiftyJSON



// MARK: private methods for socket
//MARK:- =================================================

extension RequestARideViewController: RetryRideRequestDelegate{
    
    
    func requestARide(){
        
        sharedAppdelegate.stausTimer.invalidate()
        let pickupLoc = self.pickLocationDict
        
        var dropLoc = self.dropLocationDict
        dropLoc.removeLast()
        
        
        var params = JSONDictionary()
        
        
        let vehicle = ["no": self.seletedVehicle.vehicle_no ?? "","type":seletedVehicle.vehicle_type ?? "","model":seletedVehicle.vehicle_model ?? "","desc": seletedVehicle.vehicle_desc ?? ""]
        
        if self.currenLat_long != nil{
            
            params["current_lat"] = self.currenLat_long?.latitude
            params["current_lon"] = self.currenLat_long?.longitude
        }
        
        params["vehicle_type"] = self.seletedVehicle.vehicle_type.lowercased()
        
        params["estimated_time"] = "10" as AnyObject
        params["vehicle"] = vehicle//self.getJsonObject(vehicle as AnyObject)
        params["estimated_distance"] = "10" as AnyObject
        params["pickup_locations"] = pickupLoc//self.getJsonObject(pickupLoc as AnyObject)
        params["drop_locations"] = dropLoc//self.getJsonObject(dropLoc as AnyObject)
        params["p_mode"] = self.paymentMode
        params["country"] = CurrentUser.country?.lowercased()
        print_debug(params)
        
        self.requestRideSocket(params)
        
    }

    
    
    func requestRideSocket(_ params: JSONDictionary){
        
        if CommonClass.isConnectedToNetwork{
            
            CommonClass.startLoader("")
            
            SocketServicesController.requestRide(params)
        }
    }
    
    
    func getRequestResponce(){
    
        SocketServicesController.rideRequestResponce({ (success, json) in
            
            let code = json["code"].intValue
            
            let result = json["result"].dictionaryValue
            
            switch code{
                
            case 200:
                
                let ride_id = result["ride_id"]!.stringValue
                
                UserDefaults.save(ride_id, forKey: NSUserDefaultsKeys.RIDE_ID)
                
                self.showSearchingForDriverPopUp(with: ride_id)
                
            case 209:
                
                let detailModel = RideDetailModel(with: json)
                
                NotificationCenter.default.post(name: .aceeptRequestNotificationName, object: self, userInfo: nil)
                
                self.gotoOnrideScreen(with: detailModel)
                
            case 212:
                
                if let viewController = (mfSideMenuContainerViewController.centerViewController as AnyObject).visibleViewController {
                    
                    guard viewController != nil else {return}
                    
                    let popUp = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "NoDriverFoundVC") as! NoDriverFoundVC
                    
                    popUp.modalPresentationStyle = .overCurrentContext
                    popUp.delegate = self
                    
                    getMainQueue({
                        viewController!.present(popUp, animated: false, completion: nil)
                    })
                }
                //                    showToastWithMessage(data["message"].stringValue)
                NotificationCenter.default.post(name: .aceeptRequestNotificationName, object: self, userInfo: nil)
                UserDefaults.removeFromUserDefaultForKey(NSUserDefaultsKeys.RIDE_ID)
                
            default:
                
                print_debug("")
                
            }

        }) {
            
            
        }
        
    }
    
    
    
    func retryDidTap() {
        
        self.requestARide()
    }
    
    
    func getRegainRideState(){
        
        var params = JSONDictionary()
        params["ride_id"] = CurrentUser.ride_id
        
        CommonClass.startLoader("")
        SocketServicesController.regainRideState(params, SuccessBlock: { (success, data) in
            
            printlnDebug(data)
            let rideDetail = RideDetailModel(with: data)
            
            switch rideDetail.ride_status{
                
            case Status.one,Status.five:
                
                self.gotoOnrideScreen(with: rideDetail)
                
            case Status.six:
                
                if rideDetail.driver_rating == 0{
                    
                    self.gotoRatingVC(rideDetail: rideDetail)
                    
                }
            case Status.seven:
                UserDefaults.removeFromUserDefaultForKey(NSUserDefaultsKeys.RIDE_ID)
                
            default:
                
                printlnDebug("")
                
            }
            
        }) { 
            
            
        }
    }
    
    
    func nearbydriverEmit(withLocation location: CLLocation){
        self.nearbydriver_on_res()
        var params = JSONDictionary()
        params["current_lat"] = location.coordinate.latitude
        params["current_lon"] = location.coordinate.longitude
        printlnDebug(params)
        SocketServicesController.nearByDriverEmit(params)
    }
    
    func nearbydriver_on_res(){
        
        SocketServicesController.nearByDriver_on { (success, json) in
            printlnDebug(json)
            
            let result = json["result"].arrayValue
            
            self.nearbyUserData = result.map({ (user) -> NearbyUserDriverModel in
                
                NearbyUserDriverModel.init(with: user)
            })
            self.setMapZoomLevel()
        }
    }

}
