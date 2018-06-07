//
//  LoactionPopUpVC.swift
//  UserApp
//
//  Created by Appinventiv on 06/01/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import UIKit

class LoactionPopUpVC: UIViewController {

    @IBOutlet weak var descLocLbl: UILabel!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var yesBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func yesBtnTapped(_ sender: UIButton) {
        
        self.turn_GPS_ON()
        dismiss(animated: true, completion: nil)


    }


    func turn_GPS_ON() {
        
        UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
    }

}
