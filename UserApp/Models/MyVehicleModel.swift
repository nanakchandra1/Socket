//
//  MyVehicleModel.swift
//  UserApp
//
//  Created by Appinventiv on 06/10/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON


class MyVehiclesModel{

    
    var vehicle_no: String!
    var vehicle_type: String!
    var vehicle_model: String!
    var vehicle_desc :String!
    
    init(data: JSON) {
        
        self.vehicle_no = data["no"].stringValue
        self.vehicle_type = data["type"].stringValue
        self.vehicle_model = data["model"].stringValue
        self.vehicle_desc = data["desc"].stringValue

    }

    init() {
        
    }
}
