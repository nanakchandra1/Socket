//
//  VehicleDetailcell.swift
//  UserApp
//
//  Created by Appinventiv on 23/11/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

class VehicleDetailcell: UITableViewCell {
    
    // MARK:
    // MARK: IBOutlets
    @IBOutlet weak var vehicleNameLabel: UILabel!
    @IBOutlet weak var vehicleTypeLabel: UILabel!
    @IBOutlet weak var vehicleNumberLabel: UILabel!
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var vehicleDescriptionLabel: UILabel!
    
    // MARK:
    // MARK: Table View Cell Life Cycle Mehtods
    override func awakeFromNib() {
        super.awakeFromNib()
        self.vehicleNameLabel.textColor = UIColor.black
        //self.contentView.layer.cornerRadius = 3
    }
    
    // MARK:
    // MARK: Private Methods
    func populateCell(withVehicle vehicle: MyVehiclesModel) {
        
        self.vehicleNameLabel.text = vehicle.vehicle_model.uppercased()
        self.vehicleTypeLabel.text = vehicle.vehicle_type
        self.vehicleNumberLabel.text = vehicle.vehicle_no
        
        if vehicle.vehicle_desc.isEmpty{
            
            self.vehicleDescriptionLabel.text = "No Description"

        }else{
            
            self.vehicleDescriptionLabel.text = vehicle.vehicle_desc

        }
    }
    
}
