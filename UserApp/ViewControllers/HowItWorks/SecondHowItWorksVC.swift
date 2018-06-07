//
//  SecondTutorialViewController.swift
//  UserApp
//
//  Created by Aakash Srivastav on 10/6/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class SecondHowItWorksVC: UIViewController {
    
    @IBOutlet weak var getAssignedLbl: UILabel!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var descLbl: UILabel!
    
    // MARK: View controllerlife cycle methods
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.initialSetup()
    }
    
    // MARK: Private methods
    func initialSetup() {
        
        //gradientColor(self.gradientView)
    }
}
