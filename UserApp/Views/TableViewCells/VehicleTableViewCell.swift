//
//  VehicleTableViewCell.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/27/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class VehicleTableViewCell: UITableViewCell {

    // MARK: IBOutlets
    @IBOutlet weak var vehicleDetailTextField: UITextField!
    @IBOutlet weak var dropDrownImageView: UIImageView!
    @IBOutlet weak var openPickerBtn: UIButton!
    
    // MARK: Table view cell life cycle methods
    override func awakeFromNib() {
        super.awakeFromNib()

        self.vehicleDetailTextField.editingRect(forBounds: bounds.insetBy(dx: 10, dy: 10))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.vehicleDetailTextField.text = nil
        self.dropDrownImageView.isHidden = true
    }
    
    // MARK: Private methods
    func populateCell(withPlaceholderText placeholderText: String, withVehicleDict vehicleDict: [String: String]) {
        
        self.vehicleDetailTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont(name: "SFUIDisplay-Light", size: IsIPad ? 20:11.5)!])
        
        self.vehicleDetailTextField.text = vehicleDict[placeholderText]
        
        switch placeholderText {
            
        case "Vehicle Model":
            self.vehicleDetailTextField.autocapitalizationType = .words
            self.dropDrownImageView.isHidden = true
            
        case "Vehicle Number":
            self.vehicleDetailTextField.autocapitalizationType = .allCharacters
            self.dropDrownImageView.isHidden = true
            
        case "Vehicle Type":
            self.dropDrownImageView.isHidden = false
            
        default:
            self.dropDrownImageView.isHidden = true
        }
    }
}
