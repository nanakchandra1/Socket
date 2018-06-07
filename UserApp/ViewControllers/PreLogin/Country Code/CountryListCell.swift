//
//  CountryListCell.swift
//  WAIN Application
//
//  Created by Appinventiv on 13/01/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class CountryListCell: UITableViewCell {

    @IBOutlet weak var isdCodeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var chekImage: UIImageView!
    @IBOutlet weak var separaterView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.separaterView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        self.isdCodeLabel.backgroundColor = UIColor.lightGray
        self.isdCodeLabel.layer.cornerRadius = 5.0
    }

}
