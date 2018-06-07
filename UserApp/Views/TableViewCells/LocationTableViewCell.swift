//
//  PickUpTableViewCell.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/21/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    // MARK: IBOutlets
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var locationTypeLabel: UILabel!
    @IBOutlet weak var locationAddressLabel: UILabel!
    
    @IBOutlet weak var addMoreLocationBtn: UIButton!
    @IBOutlet weak var editLocationBtn: UIButton!
    @IBOutlet weak var deleteLocationBtn: UIButton!
    
    
    // MARK: Table View Cell Life Cycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.dotView.layer.cornerRadius = IsIPad ? 5:3.5
        self.dotView.backgroundColor = UIColor(red: 215/255, green: 45/255, blue: 53/255, alpha: 1)
        
        self.locationAddressLabel.sizeToFit()
        self.editLocationBtn.isHidden = true

        self.deleteLocationBtn.layer.cornerRadius = 3
        self.deleteLocationBtn.layer.borderColor = UIColor(red: 129/255, green: 129/255, blue: 129/255, alpha: 0.3).cgColor
        self.deleteLocationBtn.layer.borderWidth = 1
        
        self.editLocationBtn.layer.cornerRadius = 3
        self.editLocationBtn.layer.borderColor = UIColor(red: 129/255, green: 129/255, blue: 129/255, alpha: 0.3).cgColor
        self.editLocationBtn.layer.borderWidth = 1
        
        self.addMoreLocationBtn.layer.cornerRadius = 3
        self.addMoreLocationBtn.layer.borderColor = UIColor(red: 129/255, green: 129/255, blue: 129/255, alpha: 0.3).cgColor
        self.addMoreLocationBtn.layer.borderWidth = 1
    }
    
    // MARK: Private Methods
    func populate(atIndex index: Int, withNumberOfLocations locations: Int, withLocationAddress address: String?) {
        
        if (address != ChooseLocationTitle.chooseDrop) {
        
            self.showEditing()
            
        } else {
           
            self.showAdding()
        }
                
        if locations < 2 {
            
            self.locationTypeLabel.text = DROP_OFF.localized
            
        } else {
            
            self.locationTypeLabel.text = "\(DROP_OFF.localized) \(index+1)"
        }
        
        self.locationAddressLabel.text = address
    }
    
    // Shows edit location and delete location button and hide add more location button
    func showEditing() {
        
//        self.editLocationBtn.hidden = false
        self.addMoreLocationBtn.isHidden = true
        //self.deleteLocationBtn.hidden = false
    }
    
    // Shows Add more location button and hides edit location and delete location button
    func showAdding() {
        
//        self.editLocationBtn.hidden = true
        self.addMoreLocationBtn.isHidden = false
        //self.deleteLocationBtn.hidden = true
    }
    
}
