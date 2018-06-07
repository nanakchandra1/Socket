//
//  PickUpTripDetailCell.swift
//  DriverApp
//
//  Created by Appinventiv on 14/11/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class PickUpTripDetailCell: UITableViewCell {

    // MARK: =========
    // MARK: IBOutlets
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var rateLbl: UILabel!
    @IBOutlet weak var fromCircleView: UIView!
    @IBOutlet weak var fromAddressLabel: UILabel!
    
    @IBOutlet weak var toCircleView1: UIView!
    @IBOutlet weak var toAddressLabel1: UILabel!
    
    @IBOutlet weak var toCircleView2: UIView!
    @IBOutlet weak var toAddressLabel2: UILabel!
    
    @IBOutlet weak var toCircleView3: UIView!
    @IBOutlet weak var toAddressLabel3: UILabel!
    
    @IBOutlet weak var toCircleView4: UIView!
    @IBOutlet weak var toAddressLabel4: UILabel!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // MARK: =========
    // MARK: Private Methods
    
    func setUpView(){
        
        self.fromCircleView.layer.cornerRadius = 4
        self.toCircleView1.layer.cornerRadius = 4
        self.toCircleView2.layer.cornerRadius = 4
        self.toCircleView3.layer.cornerRadius = 4
        self.toCircleView4.layer.cornerRadius = 4
        
        self.toCircleView1.layer.masksToBounds = true
        self.toCircleView2.layer.masksToBounds = true
        self.toCircleView3.layer.masksToBounds = true
        self.toCircleView4.layer.masksToBounds = true
        
        self.userImg.layer.cornerRadius = self.userImg.bounds.height / 2
        self.userImg.layer.borderWidth = 3
        self.userImg.layer.borderColor = UIColor.navigationBar.cgColor
        self.userImg.layer.masksToBounds = true
        
    }
    
    
    
    func hideShow(_ first: Bool, second: Bool, third: Bool, fourth: Bool){
        
        self.toAddressLabel1.isHidden = first
        self.toAddressLabel2.isHidden = second
        self.toAddressLabel3.isHidden = third
        self.toAddressLabel4.isHidden = fourth
        
        self.toCircleView1.isHidden = first
        self.toCircleView2.isHidden = second
        self.toCircleView3.isHidden = third
        self.toCircleView4.isHidden = fourth
        
    }
    
    
    func populate(at index: Int, with fromAddress: String, with toAddress: String) {
        
        self.fromCircleView.layer.cornerRadius = self.fromCircleView.bounds.height / 2
        self.fromAddressLabel.text = fromAddress
        
        
    }
    
}
