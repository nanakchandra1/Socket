//
//  SubscriptionCouponCell.swift
//  UserApp
//
//  Created by Appinventiv on 01/12/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class SubscriptionCouponCell: UITableViewCell {

    @IBOutlet weak var couponCodeLbl: UILabel!
    @IBOutlet weak var expiryDateLbl: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var roundView: UIView!
    
    @IBOutlet weak var checkboxBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
