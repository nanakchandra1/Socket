//
//  VehicleDescriptionTableViewCell.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/27/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class VehicleDescriptionTableViewCell: UITableViewCell {

    // MARK: IBOutlets
    @IBOutlet weak var vehicleDescriptionTextView: UITextView!
    
    // MARK: TableView Life Cycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()

        self.vehicleDescriptionTextView.autocapitalizationType = .sentences
        self.vehicleDescriptionTextView.returnKeyType = .default
        self.vehicleDescriptionTextView.textContainerInset = UIEdgeInsets(top: 12, left: 5, bottom: 12, right: 5)
        self.vehicleDescriptionTextView.font = UIFont(name: "SFUIDisplay-Light", size: (IsIPad ? 20:11.5))
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.vehicleDescriptionTextView.text = nil
    }
    
    // Private Methods
    func populateCell(withVehicleDict vehicleDict: [String: String] ) {
        
        if vehicleDict["Description"] == nil || vehicleDict["Description"] == "" {
            
            self.vehicleDescriptionTextView.text = "Description (optional)"
            self.vehicleDescriptionTextView.font = UIFont(name: "SFUIDisplay-Light", size: (IsIPad ? 20:11.5))
            
        } else  {
          
            self.vehicleDescriptionTextView.text = vehicleDict["Description"]
            self.vehicleDescriptionTextView.font = UIFont(name: "SFUIDisplay-Regular", size: (IsIPad ? 20:11.5))
        }
    }
}
