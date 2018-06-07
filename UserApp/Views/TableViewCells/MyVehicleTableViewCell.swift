//
//  MyVehicleTableViewCell.swift
//  UserApp
//
//  Created by Aakash Srivastav on 10/4/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class MyVehicleTableViewCell: UITableViewCell {
    
    // MARK:
    // MARK: IBOutlets
    @IBOutlet weak var vehicleNameLabel: UILabel!
    @IBOutlet weak var vehicleTypeLabel: UILabel!
    @IBOutlet weak var vehicleNumberLabel: UILabel!
    @IBOutlet weak var vehicleModelLabel: UILabel!
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var vehicleDescriptionLabel: UILabel!
    @IBOutlet weak var btnBgView: UIView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    // MARK:
    // MARK: Table View Cell Life Cycle Mehtods
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = 3
    }
    
    // MARK:
    // MARK: Private Methods
    func populateCell(withVehicle vehicle: MyVehiclesModel) {
        
        self.vehicleTypeLabel.text = vehicle.vehicle_type
        self.vehicleNumberLabel.text = vehicle.vehicle_no
        self.vehicleNameLabel.text = vehicle.vehicle_model
        
        if vehicle.vehicle_desc.isEmpty{
        
            self.vehicleDescriptionLabel.text = "No Description"
        }else{
        
            self.vehicleDescriptionLabel.text = vehicle.vehicle_desc

        }
    }
    
}
