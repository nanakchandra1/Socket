//
//  UserInfoModel.swift
//  UserApp
//
//  Created by Appinventiv on 07/11/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserInfoModel{

    var name: String!
    var dob: String!
    var type: String!
    var is_mobile_verified: String!
    var email: String!
    var mobile: String!
    var stripe: String!
    var gender: String!
    var merchant_id: String!
    var default_pmode: String!
    var notification_status: String!
    var country: String!
    var phone: String!
    var country_code: String!
    var image: String!
    var vehicles = [JSON]()

    
    init() {
        
    }
    
    
    init(json: JSON) {
        
        let detail = json["result"].dictionaryValue
        self.name = detail["name"]?.stringValue
        self.dob = detail["dob"]?.string ?? ""
        self.type = detail["type"]?.stringValue
        self.is_mobile_verified = detail["is_mobile_verified"]?.stringValue
        self.email = detail["email"]?.stringValue
        self.mobile = detail["mobile"]?.stringValue
        self.stripe = detail["stripe"]?.stringValue
        self.gender = detail["gender"]?.stringValue
        self.merchant_id = detail["merchant_id"]?.stringValue
        self.default_pmode = detail["default_pmode"]?.stringValue
        self.notification_status = detail["notification_status"]?.stringValue
        self.country = detail["country"]?.stringValue
        self.phone = detail["phone"]?.stringValue
        self.country_code = detail["country_code"]?.stringValue
        self.image = detail["image"]?.stringValue
        self.country_code = detail["country_code"]?.stringValue
        self.vehicles = detail["name"]?.array ?? []

    }

}



//"accessToken": 5a0186f138dc78144d7b3a26, "userObject": {
//    "savedlocs" : [
//    
//    ],
//    "dob" : null,
//    "vehicles" : [
//    {
//    "model" : "Guests",
//    "type" : "car",
//    "desc" : "Ref high",
//    "no" : "JEHBFHU"
//    },
//    {
//    "model" : "Unit",
//    "type" : "car",
//    "desc" : "Iojciomi6v yuh yuh but in you bhu ugly by Bibb yuh u in inhibit hub uh in in in you bug bin u nu",
//    "no" : "IUGIO"
//    }
//    ],
//    "merchant_created" : "2017-06-26T07:39:25.225Z",
//    "otp" : "5368",
//    "type" : "merchant",
//    "balance" : 2,
//    "date_updated" : "2017-06-26T05:43:46.466Z",
//    "is_deleted" : "0",
//    "is_email_verified" : 0,
//    "image" : "user_image-1498455826464",
//    "country_code" : "+213",
//    "password" : "$2a$05$tHQMvmnQobFhKrqIznoEW.0NvM9YDoQbL5PVqye0TW1uSZoXcXYgC",
//    "phone" : "8130302339",
//    "myCoupon" : [
//    
//    ],
//    "is_mobile_verified" : 0,
//    "used_coupons" : [
//    
//    ],
//    "name" : "Test",
//    "email" : "test@gmail.com",
//    "mobile" : "+2138130302339",
//    "stripe" : "cus_AufVDN6cfytCVD",
//    "gender" : "male",
//    "merchant_id" : "WAV-MER-1498462765",
//    "average_rating" : 4.5,
//    "status" : "1",
//    "default_pmode" : "card_1AYqAPC7P6PBCadS5mUOarGE",
//    "_id" : "59509f12b4b8ce10716188a4",
//    "date_created" : "2017-06-26T05:43:46.466Z",
//    "image_type" : "",
//    "notification_status" : "1",
//    "__v" : 0,
//    "previous_due" : 0,
//    "country" : "singapore"
//}
