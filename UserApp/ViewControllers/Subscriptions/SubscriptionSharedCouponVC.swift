//
//  SubscriptionSharedCouponVC.swift
//  UserApp
//
//  Created by Appinventiv on 01/12/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import SwiftyJSON

class SubscriptionSharedCouponVC: UIViewController {
 
    //MARK:- IBOutlets
    //MARK:- =================================================

    @IBOutlet var couponsTableView: UITableView!
    
    
    
    //MARK:- Properties
    //MARK:- =================================================

    var sharedCoupons = JSONArray()
    
    

    //MARK:- View life cycle
    //MARK:- =================================================

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.couponsTableView.delegate = self
        self.couponsTableView.dataSource = self
        self.couponsTableView.register(UINib(nibName: "SubscriptionCouponCell" ,bundle: nil), forCellReuseIdentifier: "SubscriptionCouponCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        availableCoupons()
    }

  
    
    //MARK:- Methods
    //MARK:- =================================================

    
    func availableCoupons(){
        CommonClass.startLoader("")
        self.sharedCoupons.removeAll()
        ServiceController.getAvailableAPI({ (success,json) in
            
        let result = json["result"].array ?? [["":""]]
            
            for coupon in result {
                
                let status = coupon["cpCreatedUserShareStatus"].intValue
                
                    if status == 1{
                        
                        self.sharedCoupons.append(coupon)
                    }
                
            }

            CommonClass.stopLoader()
            self.couponsTableView.reloadData()
            showNodata(self.sharedCoupons, tableView: self.couponsTableView, msg: NO_SHARED_COUPON, color: .white)

        }) { (error) in
            CommonClass.stopLoader()
        }
    }

    
    func onTapUnshareBtn(_ sender: UIButton) {
        
        guard let indexPath = sender.tableViewIndexPath(self.couponsTableView) else { return }
        let undshareCoupon = self.sharedCoupons[indexPath.row]
        
        sender.setImage(UIImage(named: "signup_checkbox"), for: UIControlState())
        
        self.unshareCouponWith(undshareCoupon, at: indexPath)
    }
    
    
    func unshareCouponWith(_ coupon: JSON, at indexPath: IndexPath) {
        
        var params = JSONDictionary()
        params["actType"] = "0"
        params["couponId"] = coupon["_id"]
        
        ServiceController.shareCouponsApi(params, SuccessBlock: { (success,json) in
            if success{
                self.sharedCoupons.remove(at: indexPath.row)
                self.couponsTableView.reloadData()
            }
            
            }, failureBlock: { (error) in
                printlnDebug(error)
        })
    }
    
}


//MARK:- Tableview datasource and delegate
//MARK:- =================================================


extension SubscriptionSharedCouponVC: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sharedCoupons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "SubscriptionCouponCell", for: indexPath) as! SubscriptionCouponCell
        
            cell.couponCodeLbl.text = self.sharedCoupons[indexPath.row]["cp_code"].string ?? ""
        let date = self.sharedCoupons[indexPath.row]["cp_end_date"].string ?? ""
            cell.expiryDateLbl.text = "Expiry: " + date.convertTimeWithTimeZone( formate: DateFormate.dateWithTime)
        
        cell.shareBtn.isHidden = true
        
        cell.checkboxBtn.addTarget(self, action: #selector(SubscriptionSharedCouponVC.onTapUnshareBtn(_:)), for: UIControlEvents.touchUpInside)

        cell.checkboxBtn.setImage(UIImage(named: "signup_checkbox_tick"), for: UIControlState())
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

}
