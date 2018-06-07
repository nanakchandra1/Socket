//
//  RequestRideStaticServices.swift
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



// MARK: Web services call methods
//MARK:- =================================================

extension RequestARideViewController {
    
    
    
    func getVehicles(){
        
        var params = JSONDictionary()
        params["action"] = "view"
        ServiceController.getvehicleApi(params, SuccessBlock: { (success,json) in
            
            if success{
                
                let result = json["result"].arrayValue
                
                self.vehicleList = []
                
                if !result.isEmpty{
                    
                    self.seletedVehicle = MyVehiclesModel(data: result.first!)
                    
                    for res in result{
                        
                        let vehicleDetail = MyVehiclesModel(data: res)
                        self.vehicleList.append(vehicleDetail)
                        
                    }
                    
                    self.vehivleNameLabel.text = self.seletedVehicle.vehicle_model
                    
                    self.pickerView.selectRow(0, inComponent: 0, animated: true)
                    
                    isvehecleAdd = false
                    
                    
                }
            }
            
        }) { (error) in
            printlnDebug(error)
        }
        
    }
    
    
    
    func getPlaceDetail(_ placeID: String, dict: DictType) {
        
        let params = [ "placeid" : placeID, "key" : APIKeys.googleAPIKey ]
        
        ServiceController.getLatLong(params as [String : AnyObject], SuccessBlock: { (success,json) in
            
            let status = json["status"].string ?? ""
            
            if status == "OK" {
                
                let result = json["result"].dictionary ?? [:]
                let _ = result["formatted_address"]?.string ?? ""
                let geometry = result["geometry"]?.dictionary ?? [:]
                let location = geometry["location"]?.dictionary ?? [:]
                let latitude = location["lat"]?.double ?? 0
                let longitude = location["lng"]?.double ?? 0
                
                
                if dict == .drop {
                    
                    self.dropLocationDict[self.tappedIndex]["latitude"] = latitude
                    self.dropLocationDict[self.tappedIndex]["longitude"] = longitude
                    self.dropLocationDict[self.tappedIndex]["place_id"] = placeID
                    
                } else {
                    
                    
                    self.pickLocationDict["latitude"] = latitude
                    self.pickLocationDict["longitude"] = longitude
                    self.pickLocationDict["place_id"] = placeID
                }
                self.setMapZoomLevel()
                
                var destinationStr = ""
                
                for item in self.dropLocationDict{
                    
                    if let lat = item["latitude"]{
                        if let long = item["longitude"]{
                            
                            destinationStr.append("\(lat),\(long)|")
                        }
                    }
                }
                
                
                printlnDebug(destinationStr)
                
                
                let srcLat = self.pickLocationDict["latitude"]
                let srcLon = self.pickLocationDict["longitude"]
                let srcStr = "\(srcLat!),\(srcLon!)"
                self.calcEta(srcStr, destination: destinationStr)
                
                
            }
            
        }, failureBlock: { (error) in
            CommonClass.stopLoader()
        })
    }
    
    
    
    func getFare(_ tot:Int){
        
        
        let params : JSONDictionary = ["trip_type":"valet","estimated_distance": "\(self.estimatedDistance)","estimated_time": "\(tot)","no_of_drops" : "\(self.dropLocationDict.count - 1)","current_city":"singapore"]
        
        ServiceController.getRideFareApi(params, SuccessBlock: { (success,json) in
            
            if success{
                
                let result = json["result"].dictionary ?? ["":""]
                
                let fare  = result["total_fare"]?.string ?? ""
                self.tripFareLabel.text = "$\(fare)"
                
            }
            
        }) { (error) in
            printlnDebug(error)
        }
    }

    func getEta() {
        
        var destinationStr = ""
        
        for item in self.dropLocationDict{
            
            if let lat = item["latitude"]{
                if let long = item["longitude"]{
                    
                    destinationStr.append("\(lat),\(long)|")
                }
            }
        }
        
        
        printlnDebug(destinationStr)
        
        
        let srcLat = self.pickLocationDict["latitude"]
        let srcLon = self.pickLocationDict["longitude"]
        let srcStr = "\(srcLat!),\(srcLon!)"
        
        self.setMapZoomLevel()
        
        self.calcEta(srcStr, destination: destinationStr)
        
        
    }
    
    
    func calcEta(_ source:String,destination:String){
        self.estimatedDistance = 0.0
        ServiceController.getEatApi(source, destination: destination, SuccessBlock: { (success, json) in
            
            if success{
                
                let status = json["status"].string ?? ""
                
                if status == "OK"{
                    
                    let data = json["rows"].array ?? [["":""]]
                    
                    guard let firstElement = data.first else{
                        fatalError("")
                    }
                    
                    if let elements = firstElement["elements"].array{
                        
                        var timeArray = [String]()
                        
                        for item in elements{
                            
                            let timeData = item["duration"].dictionary ?? ["":""]
                            
                            let time = timeData["text"]?.string ?? ""
                            
                            timeArray.append(time)
                            
                            let disData = item["distance"].dictionary ?? ["":""]
                            
                            let dis = disData["text"]?.string ?? ""
                            
                            if dis.contains(" m"){
                                let sepratedDis = dis.replacingOccurrences(of: " km", with: "").replacingOccurrences(of: " m", with: "").replacingOccurrences(of: ",", with: "")
                                self.estimatedDistance = Float(sepratedDis)! / 1000
                                
                            }else if dis.contains(" km"){
                                let sepratedDis = dis.replacingOccurrences(of: " km", with: "").replacingOccurrences(of: " m", with: "").replacingOccurrences(of: ",", with: "")
                                self.estimatedDistance = Float(sepratedDis)!
                            }
                            
                            
                        }
                        printlnDebug(timeArray)
                        printlnDebug(self.estimatedDistance)
                        
                        self.retriveTotalEat(timeArray)
                    }
                }
            }
        }) { (error) in
            
            
        }
        
    }
    
    
    
    func retriveTotalEat(_ timeArray:[String]){
        var hourArray = [String]()
        var minArray = [String]()
        
        for item in timeArray{
            
            if item.contains(" hours") && item.contains(" mins"){
                
                
                let str = item.replacingOccurrences(of: " hours", with: "").replacingOccurrences(of: " mins", with: "")
                
                let strArray = str.components(separatedBy: " ")
                
                hourArray.append(strArray[0])
                minArray.append(strArray[1])
                
            }else if item.contains(" hours") && item.contains(" min"){
                let str = item.replacingOccurrences(of: " hours", with: "").replacingOccurrences(of: " min", with: "")
                
                let strArray = str.components(separatedBy: " ")
                
                hourArray.append(strArray[0])
                minArray.append(strArray[1])
                
            }else if item.contains(" hour") && item.contains(" mins"){
                
                let str = item.replacingOccurrences(of: " hour", with: "").replacingOccurrences(of: " mins", with: "")
                
                let strArray = str.components(separatedBy: " ")
                
                hourArray.append(strArray[0])
                minArray.append(strArray[1])
                
            }else if item.contains(" hour") && item.contains(" min"){
                
                let str = item.replacingOccurrences(of: " hour", with: "").replacingOccurrences(of: " min", with: "")
                
                let strArray = str.components(separatedBy: " ")
                
                hourArray.append(strArray[0])
                minArray.append(strArray[1])
                
            }else if item.contains(" hours"){
                let str = item.replacingOccurrences(of: " hours", with: "")
                hourArray.append(str)
            }else if item.contains(" mins"){
                let str = item.replacingOccurrences(of: " mins", with: "")
                minArray.append(str)
            }else if item.contains(" hour"){
                let str = item.replacingOccurrences(of: " hour", with: "")
                hourArray.append(str)
            }else if item.contains(" min"){
                let str = item.replacingOccurrences(of: " min", with: "")
                minArray.append(str)
            }
            
        }
        
        printlnDebug(hourArray)
        printlnDebug(minArray)
        self.calculateNetTime(hourArray, minArray: minArray)
    }
    
    
    func calculateNetTime(_ hrArray : [String] , minArray : [String]){
        var total = 0
        
        for item in hrArray{
            
            if !item.contains("day") && !item.isEmpty{
                
                total = total + (Int(item)! * 60)
            }
        }
        
        
        for item in minArray{
            
            if !item.contains("day") && !item.isEmpty{
                
                total = total + Int(item)!
            }
        }
        
        printlnDebug(total)
        self.arrivalTimeLabel.text = "\(RideRelatedString.share_eta_Msg) \(total) mins"
        
        self.shareBtn.isUserInteractionEnabled = true
        
        self.getFare(total)
    }

}
