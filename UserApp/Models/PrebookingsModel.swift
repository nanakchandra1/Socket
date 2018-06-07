//
//  PrebookingsModel.swift
//  UserApp
//
//  Created by Appinventiv on 13/10/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

class PrebookingsModel{
    
    var status: String!
    var user_name: String!
    var user_image: String!
    var pickup: String!
    var p_amount: String!
    var start_time: String!
    var date_created:String!
    var dropCount: Int!
    var drop1: String!
    var drop2: String!
    var drop3: String!
    var drop4: String!
    
    var last4: String!
    var trip_time: String!
    var rideId:String!

    
    init(data: JSON){
        
        self.status = data["status"].stringValue
        self.user_name = data["user_name"].stringValue
        self.user_image = data["user_image"].stringValue
        self.pickup = data["pickup"]["address"].stringValue
        self.p_amount = data["p_amount"].stringValue
        self.start_time = data["start_time"].stringValue
        self.date_created = data["date_created"].stringValue

        let id = data["_id"].stringValue
        
        self.rideId = id
        
        self.last4 = id.substring(from: id.characters.index(id.endIndex, offsetBy: -6))
        
        self.trip_time = data["trip_time_f"].stringValue

        
        let drop = data["drop"].arrayValue
        
        self.dropCount = drop.count
        
        switch drop.count {
            
        case 1:
            
            self.drop1 = drop.first?["address"].stringValue
            
        case 2:
            self.drop1 = drop.first?["address"].stringValue
            self.drop2 = drop.last?["address"].stringValue
            
        case 3:
            
            self.drop1 = drop.first?["address"].stringValue
            self.drop2 = drop[1]["address"].stringValue
            self.drop3 = drop.first?["address"].stringValue
            
        case 4:
            
            self.drop1 = drop.first?["address"].stringValue
            self.drop2 = drop[1]["address"].stringValue
            self.drop3 = drop[2]["address"].stringValue
            self.drop4 = drop.last?["address"].stringValue
            
        default:
            
            fatalError("DROP LIMIT EXCEED")
        }
        
    }
    
    
    
    init(){
        
    }
    
    func userImage() -> String {
        
        return imgUrl + self.user_image
    }
    
}
