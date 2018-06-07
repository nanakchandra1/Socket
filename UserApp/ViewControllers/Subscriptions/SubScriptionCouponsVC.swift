//
//  SubScriptionCouponsVC.swift
//  UserApp
//
//  Created by Appinventiv on 01/12/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

protocol ScrollDelegate {
    //func changeSlider(state: String)
    func setAvailableCouponCount(_ count: String)
}



class SubScriptionCouponsVC: UIViewController,ScrollDelegate {

    //MARK:- IBOutlets
    //MARK:- =================================================

    
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var navigationTitle: UILabel!
    @IBOutlet var availableBtn: UIButton!
    @IBOutlet var sharedBtn: UIButton!
    @IBOutlet weak var generateCouponBgView: UIView!
    @IBOutlet weak var generateViewHeightConst: NSLayoutConstraint!
    @IBOutlet var availableCouponsCountLbl: UILabel!
    @IBOutlet var generateCouponBtn: UIButton!
    @IBOutlet weak var noteLbl: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var pagerView: UIView!
    @IBOutlet weak var pagerViewLeadingConstant: NSLayoutConstraint!

    //MARK:- Properties
    //MARK:- =================================================
    var availVC: SubscriptionAvailableCouponVC!
    var sharedVC: SubscriptionSharedCouponVC!

    
    //MARK:- View life cycle
    //MARK:- =================================================

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pagerViewLeadingConstant.constant = 0
        self.scrollView.delegate = self
        self.addChildView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.getCoupons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addChildView()
    }


    //MARK:- IBActions
    //MARK:- =================================================

    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func generateCouponsTapped(_ sender: UIButton) {
        generateCoupons()
    }
    
    @IBAction func availableTapped(_ sender: UIButton) {
        self.generateCouponBgView.isHidden = false
        self.generateViewHeightConst.constant = 80
        setupAvailView()
    }
    
    
    @IBAction func sharedTapped(_ sender: UIButton) {
        self.generateCouponBgView.isHidden = true
        self.generateViewHeightConst.constant = 0
        shareLayout()
    }
    

    
    // MARK: Private Methods
    //MARK:- =================================================

    
    func addChildView(){
        
        //set up scroll view
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        self.scrollView.contentSize.width = screenWidth * 2
        self.scrollView.isPagingEnabled = true
        
        self.setupAvailView()
        
    }

    
    
    func setupAvailView(){
        
        self.pagerViewLeadingConstant.constant = 0
        
        let avil = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionAvailableCouponVC") as! SubscriptionAvailableCouponVC
       // availVC.scrollDelegate = self
        avil.view.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: self.scrollView.frame.height)
        self.scrollView.addSubview(avil.view)
        self.addChildViewController(avil)
        UIView.animate(withDuration: 0.0001, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            
            self.scrollView.contentOffset.x = 0
            
        }) { (animate : Bool) -> Void in
            
            if let childvc = self.childViewControllers as? [UIViewController]{
                for ch in childvc{
                    
                    if ch.isKind(of: SubscriptionSharedCouponVC.self){
                        ch.view.removeFromSuperview()
                        ch.removeFromParentViewController()
                    }
                }
            }
        }
    }
    
    
    
    func shareLayout(){
        
        self.pagerViewLeadingConstant.constant = screenWidth / 2
        self.view.layoutIfNeeded()
        
        let share = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionSharedCouponVC") as! SubscriptionSharedCouponVC
        share.view.frame = CGRect(x: self.view.frame.width , y: 0, width: self.view.frame.width, height: self.scrollView.frame.height)
        
        self.scrollView.addSubview(share.view)
        self.addChildViewController(share)
        
        
        UIView.animate(withDuration: 0.0001, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            
            self.scrollView.contentOffset.x = self.view.frame.width
            
            
        }) { (animate : Bool) -> Void in
            
            if let childvc = self.childViewControllers as? [UIViewController]{
                for ch in childvc{
                    
                    if ch.isKind(of: SubscriptionAvailableCouponVC.self){
                        ch.view.removeFromSuperview()
                        ch.removeFromParentViewController()
                    }
                }
            }
        }
    }
    
    
    
    func generateCoupons(){
        
        CommonClass.startLoader("")
        
        var params = JSONDictionary()
        
        params["action"] = "user" as AnyObject
        
        ServiceController.subsViewCoupons(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()

            if success{
                
                self.setupAvailView()
                
            }
            
        }) { (error) in
            
            CommonClass.stopLoader()

        }
    }


    func setAvailableCouponCount(_ count: String) {
        self.availableCouponsCountLbl.text = "Coupon Available: \(count)"
    }
    
}

//MARK:- Scrollview delegate
//MARK:- =================================================


extension SubScriptionCouponsVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pagerViewLeadingConstant.constant = self.scrollView.contentOffset.x/2
        
        if self.pagerViewLeadingConstant.constant == screenWidth / 2{
            shareLayout()
            
        }
        else if self.pagerViewLeadingConstant.constant == 0{
            setupAvailView()
        }

    }
}

