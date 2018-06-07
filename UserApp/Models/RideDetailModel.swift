//
//  RideDetailModel.swift
//  UserApp
//
//  Created by Appinventiv on 27/10/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

class RideDetailModel {
    
    var driver_contact: String!
    var driver_id: String!
    var driver_image: String!
    var driver_name: String!
    var driver_uid: String!
    var driver_lat:Double = 0
    var driver_long:Double = 0
    var driver_address = ""
    var drop_address = ""
    var pickup_lat:Double = 0
    var pickup_long:Double = 0
    var pickup_address: String!
    var ride_id: String!
    var vehicle_no: String!
    var vehicle_model: String!
    var vehicle_type: String!
    var vehicle_desc: String!
    var drop_lat_long = ""
    var dropLatLongArray = [JSON]()
    var drop = [JSON]()
    var ride_status: String!
    var cd_status: String!
    var p_amount: String!
    var date_created: String!
    var dropLocations = JSONDictionaryArray()
    var driver_rating = 0
    
    init(with data: JSON) {
        
        let detail = data["result"].dictionaryValue
        let driver_detail = detail["driver_detail"]?.dictionaryValue
        self.driver_name = driver_detail?["name"]?.stringValue
        self.driver_image = driver_detail?["image"]?.stringValue
        self.driver_contact = driver_detail?["contact"]?.stringValue
        self.driver_id = driver_detail?["driver_id"]?.stringValue
        self.driver_uid = driver_detail?["uid"]?.stringValue
        
        self.ride_status = detail["status"]?.string ?? ""
        self.cd_status = detail["cd_status"]?.stringValue
        self.p_amount = detail["p_amount"]?.stringValue
        let date = detail["date_created"]?.string ?? ""
        self.date_created = date.convertTimeWithTimeZone( formate: DateFormate.dateWithTime)
        self.driver_rating = detail["driver_rating"]?.intValue ?? 0
        
        let driver_current_loc = driver_detail?["driver_current_loc"]?.dictionaryValue
        let coordinates = driver_current_loc?["coordinates"]?.array ?? []
        if !coordinates.isEmpty{
            
            self.driver_lat = coordinates.last!.doubleValue
            self.driver_long = coordinates.first!.doubleValue

        }

         self.drop = detail["drop"]!.arrayValue
         self.dropLocations = detail["drop"]!.arrayObject as? JSONDictionaryArray ?? [[:]]
        
        for res in self.drop{
        
            self.drop_address = self.drop_address + res["address"].stringValue + "\n"
            let lat = res["latitude"].stringValue
            let lon = res["longitude"].stringValue
            self.drop_lat_long.append("\(lat),\(lon)|")

            self.dropLatLongArray.append(JSON(["lat":lat,"long":lon]))
        }

        let pick = detail["pickup"]?.dictionaryValue
        
        self.pickup_address = pick?["address"]?.stringValue
        self.pickup_lat = pick!["latitude"]!.doubleValue
        self.pickup_long = pick!["longitude"]!.doubleValue

        self.ride_id = detail["ride_id"]?.string ?? detail["_id"]?.stringValue
        UserDefaults.save(self.ride_id, forKey: NSUserDefaultsKeys.RIDE_ID)
        let user_detail = detail["user_detail"]?.dictionaryValue
        let vehicle = user_detail?["vehicle"]?.dictionaryValue
        self.vehicle_no = vehicle?["no"]?.stringValue
        self.vehicle_model = vehicle?["model"]?.stringValue
        self.vehicle_type = vehicle?["type"]?.stringValue
        self.vehicle_desc = vehicle?["desc"]?.stringValue
        
        
    }
    
    init() {
        
        
    }
}
