//
//  PickDropTableViewCell.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 10/25/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class PickDropTableViewCell: UITableViewCell {

    // MARK: =========
    // MARK: IBOutlets
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var locationTypeLabel: UILabel!
    
    // MARK: ==================================
    // MARK: TableViewCell Life Cycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()

        self.circleView.layer.cornerRadius = (IsIPad ? 5.5:4)
    }
    
    // MARK: =========
    // MARK: Private Methods
    func populate(at index: Int, with address: String) {
        
        if index == 0 {
            self.locationTypeLabel.text = "From:"
        } else {
            self.locationTypeLabel.text = "To:"
        }
        self.addressLabel.text = address
        self.addressLabel.sizeToFit()
    }
}
