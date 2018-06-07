//
//  NearbyUserDriverModel.swift
//  DriverApp
//
//  Created by Appinventiv on 15/11/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

struct  NearbyUserDriverModel{
    
    var email : String!
    var _id : String!
    var name : String!
    var image : String!
    var lat : Double!
    var long : Double!
    
    init(with data: JSON) {
        
        self.email = data["email"].stringValue
        self._id = data["_id"].stringValue
        self.name = data["name"].stringValue
        self.image = data["image"].stringValue
        
        let coordinates = data["location"]["coordinates"].arrayValue
        
        self.lat = coordinates[1].doubleValue
        self.long = coordinates[0].doubleValue
    }
    
}




//{
//    "email" : "newuser@gmail.com",
//    "_id" : "5a094ef5f63ccf48e6215049",
//    "name" : "New User",
//    "image" : "\/uploads\/user\/image-1510638968979.jpg",
//    "location" : {
//        "type" : "Point",
//        "coordinates" : [
//        77.3760918,
//        28.6296315
//        ]
//    }
//}
