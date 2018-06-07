//
//  UserSupportViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/20/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class UserSupportViewController: UIViewController {

    // MRAK: IBOulets
    //MARK:- =================================================
    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var supportEmailLabel: UILabel!
    @IBOutlet weak var supportNumberLabel: UILabel!
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
