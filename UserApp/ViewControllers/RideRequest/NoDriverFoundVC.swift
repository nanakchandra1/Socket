//
//  NoDriverFoundVC.swift
//  UserApp
//
//  Created by Appinventiv on 29/11/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import UIKit

protocol RetryRideRequestDelegate: class {
    
    func retryDidTap()
}

class NoDriverFoundVC: BaseViewController {

    //MARK: Outlets
    @IBOutlet weak var noDriverLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    
    
    //MARK: Properties
    weak var delegate : RetryRideRequestDelegate?
    
    //MARK: View life cycle
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubViews()
    }

    
    //MARK: IBAction
    //MARK: 
    @IBAction func dismissTap(_ sender: UIButton) {
        
        self.animatedDisapper()
    }
    
    @IBAction func retryTap(_ sender: UIButton) {
        
        self.delegate?.retryDidTap()
        self.animatedDisapper()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


//MARK: Private functions
extension NoDriverFoundVC{

    func setupSubViews(){
    
        self.retryButton.setTitle("RETRY", for: .normal)
        
    }
    
    func animatedDisapper(){
        
        UIView.animate(withDuration: 0.2) {
            
            self.containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            
            self.view.alpha = 0
        }
        
        delay(0.2) { 
            
            self.dismiss(animated: false, completion: nil)

        }
    }
}
