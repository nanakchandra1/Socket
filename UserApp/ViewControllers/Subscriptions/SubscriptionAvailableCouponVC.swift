//
//  SubscriptionAvailableCouponVC.swift
//  UserApp
//
//  Created by Appinventiv on 01/12/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import SwiftyJSON

class SubscriptionAvailableCouponVC: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet var couponsTableView: UITableView!
    
    //MARK:- Properties
    var availableCoupons = [JSON]()
    
    var scrollDelegate: ScrollDelegate?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.couponsTableView.delegate = self
        self.couponsTableView.dataSource = self
        
        self.couponsTableView.register(UINib(nibName: "SubscriptionCouponCell" ,bundle: nil), forCellReuseIdentifier: "SubscriptionCouponCell")
        getAvailableCoupons()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    //MARK:- Functions
    
    func getAvailableCoupons(){
        
        CommonClass.startLoader("")
        
        self.availableCoupons.removeAll()
        
        ServiceController.getAvailableAPI({ (success,json) in
            
            CommonClass.stopLoader()
            
            if success{
                
                let result = json["result"].array ?? [["":""]]
                
                for coupon in result {
                    
                    
                    let status = coupon["cpCreatedUserShareStatus"].int ?? 100
                    
                    if status == 0{
                        
                        self.availableCoupons.append(coupon)
                        
                    }
                }
                
                self.couponsTableView.reloadData()
                
                showNodata(self.availableCoupons, tableView: self.couponsTableView, msg: NO_AVAILABLE_COUPON, color: .white)
                
                self.scrollDelegate?.setAvailableCouponCount("\(self.availableCoupons.count)")
                
                if ((self.parent?.isKind(of: SubScriptionCouponsVC.self)) != nil){
                    
                    (self.parent as? SubScriptionCouponsVC)?.availableCouponsCountLbl.text = "Coupon Available: \(self.availableCoupons.count)"
                    
                }
                
            }else{
                
                showNodata(self.availableCoupons, tableView: self.couponsTableView, msg: NO_AVAILABLE_COUPON, color: .white)
                
            }
            
        }) { (error) in
            
            CommonClass.stopLoader()
        }
    }
    
    
    func onTapShareBtn(_ sender: UIButton){
        
        guard let indexPath = sender.tableViewIndexPath(self.couponsTableView) else { return }
        let shareCoupon = self.availableCoupons[indexPath.row]
        
        sender.setImage(UIImage(named: "signup_checkbox_tick"), for: UIControlState())
        
        
        self.shareCouponWith(shareCoupon, at: indexPath)
        
    }
    
    
    
    func shareCouponWith(_ coupon: JSON, at indexPath: IndexPath) {
        
        var params = JSONDictionary()
        params["actType"] = "1"
        params["couponId"] = coupon["_id"].string ?? ""
        
        printlnDebug(params)
        ServiceController.shareCouponsApi(params, SuccessBlock: { (success,json) in
            
            if success{
                
                self.availableCoupons.remove(at: indexPath.row)
                self.couponsTableView.reloadData()
                
                if ((self.parent?.isKind(of: SubScriptionCouponsVC.self)) != nil){
                    (self.parent as? SubScriptionCouponsVC)?.availableCouponsCountLbl.text = "Coupon Available: \(self.availableCoupons.count)"
                }
            }
        }, failureBlock: { (error) in
            printlnDebug(error)
        })
    }
    
    
    func unshareCoupon(_ coupon: JSON) {
        
        var couponToAppend = coupon
        couponToAppend["cpCreatedUserShareStatus"] = 0
        
        self.availableCoupons.append(couponToAppend)
        self.couponsTableView.reloadData()
    }
    
    func shareCouponUsingActivity(_ sender: UIButton) {
        
        guard let indexPath = sender.tableViewIndexPath(self.couponsTableView) else { return }
        let shareCoupon = self.availableCoupons[indexPath.row]
        
        let msg = "Enjoy the ride with WAV subscription coupon \(shareCoupon["cp_code"].string ?? "")"
        self.displayShareSheet(msg)
    }
    
    
    func displayShareSheet(_ shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }
}


extension SubscriptionAvailableCouponVC: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.availableCoupons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "SubscriptionCouponCell", for: indexPath) as! SubscriptionCouponCell
        
        cell.couponCodeLbl.text = self.availableCoupons[indexPath.row]["cp_code"].string ?? ""
        
        cell.roundView.layer.cornerRadius = 3
        
        let date = self.availableCoupons[indexPath.row]["cp_end_date"].string ?? ""
        
        cell.expiryDateLbl.text = "Expiry: " + date.convertTimeWithTimeZone( formate: DateFormate.dateWithTime)
        
        cell.shareBtn.addTarget(self, action: #selector(SubscriptionAvailableCouponVC.shareCouponUsingActivity(_:)), for: UIControlEvents.touchUpInside)
        cell.checkboxBtn.addTarget(self, action: #selector(SubscriptionAvailableCouponVC.onTapShareBtn(_:)), for: UIControlEvents.touchUpInside)
        cell.checkboxBtn.setImage(UIImage(named: "signup_checkbox"), for: UIControlState())
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}
