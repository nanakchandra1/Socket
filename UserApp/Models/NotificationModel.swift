//
//  NotificationModel.swift
//  UserApp
//
//  Created by Appinventiv on 12/10/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON

class NotificationModel{

    var title: String!
    var date_created: String!
    var message: String!
    var urltext: String!
    var url: String!
    var image: String!

    
    init(_ data: JSON) {
        
        self.title = data["title"].stringValue
        let date = data["date_created"].stringValue
        self.date_created = date.convertTimeWithTimeZone( formate: DateFormate.dateWithTime)
        self.message = data["message"].stringValue
        self.urltext = data["urltext"].stringValue
        self.url = data["url"].stringValue
        self.image = data["image"].stringValue

        
    }
    
    
}
