//
//  PromotionsVC.swift
//  UserApp
//
//  Created by Appinventiv on 24/11/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import SwiftyJSON
class PromotionsVC: UIViewController {

    //MARK:- IBOutlets
    //MARK:- =================================================

    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var navigationTitle: UILabel!

    @IBOutlet weak var couponBgView: UIView!
    @IBOutlet weak var couponTextField: UITextField!
    @IBOutlet weak var promotionTableview: UITableView!
    @IBOutlet weak var applycouponBtn: UIButton!
    @IBOutlet weak var appliedLbl: UILabel!
    
    //MARK:- Properties
    //MARK:- =================================================

    
    var promotions = JSONDictionaryArray()
    var isApplied = false
    
    
    
    //MARK:- View life cycle
    //MARK:- =================================================

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appliedLbl.isHidden = true
        self.promotionTableview.delegate = self
        self.promotionTableview.dataSource = self
        self.couponTextField.delegate = self
        self.couponBgView.layer.cornerRadius = 3
        self.applycouponBtn.layer.cornerRadius = 3
        if let coupon = CurrentUser.my_coupon as? JSONDictionary{
            
            if !coupon.isEmpty{
            
                if let code = coupon["cp_code"] as? String{
                    self.couponTextField.text = code
                    self.setApplyBtnState("Change", state: true)
                }
            }
        }
        self.navigationView.setMenuButton()
        self.getPromotions()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var tapGasture =  UITapGestureRecognizer()
        tapGasture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { (notification:Notification!) -> Void in
            
            self.view.addGestureRecognizer(tapGasture)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil,
                                                                
                                                                queue: OperationQueue.main) {_ in
                                                                    
                                                                    self.view.removeGestureRecognizer(tapGasture)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- Methods
    //MARK:- =================================================

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func dismissKeyboard(_ sender: AnyObject)
    {
        self.view.endEditing(true)
    }

    
    func getPromotions(){
        
        CommonClass.startLoader("")

        ServiceController.promotionApi(["":""], SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()

            if success{
                
                let result = json["result"].arrayValue
                
                print_debug(result)
                
                self.promotions = json["result"].arrayObject as? JSONDictionaryArray ?? [ ]
                
                print_debug(self.promotions)
                self.promotionTableview.reloadData()
                showNodata(self.promotions, tableView: self.promotionTableview, msg: NO_PROMOTION, color: .white)

                let couponDetail = json["coupon"].dictionaryValue
                let myCoupons = couponDetail["myCoupon"]?.arrayValue
                
                if couponDetail.isEmpty{
                    
                    self.setApplyBtnState("Apply", state: false)
                    UserDefaults.removeFromUserDefaultForKey(NSUserDefaultsKeys.MY_COUPON)
                    return
                }
                
                if !myCoupons!.isEmpty{
                    
                    self.couponTextField.text = myCoupons?.first!["cp_code"].stringValue
                    
                    self.setApplyBtnState("Change", state: true)
                    
                    UserDefaults.save(myCoupons?.first! as AnyObject, forKey: NSUserDefaultsKeys.MY_COUPON)
                    
                    
                }else{
                    
                    UserDefaults.removeFromUserDefaultForKey(NSUserDefaultsKeys.MY_COUPON)
                    self.setApplyBtnState("Apply", state: false)
                }
            }

        }) { (error) in
            
            CommonClass.stopLoader()
        }
    }
    
    func setApplyBtnState(_ title_str: String, state: Bool){
        
        self.couponTextField.isEnabled = !state
        self.appliedLbl.isHidden = !state
        self.isApplied = state
        if !state{
            self.couponTextField.text = ""
        }
        self.applycouponBtn.setTitle(title_str, for: UIControlState())

    }
    
    
    @IBAction func applyBtnTapped(_ sender: UIButton) {
        self.view.endEditing(true)

        if !self.isApplied{
        if self.couponTextField.text == ""{
            showToastWithMessage(LoginPageStrings.enter_coupon)
            return
        }
        
       var params = JSONDictionary()
        
        params["couponCode"] = self.couponTextField.text! as AnyObject
        CommonClass.startLoader("")
        ServiceController.applyCouponsAPI(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()

            if success{
                
              let result = json["result"].dictionary ?? ["":""]
              let mycoupon = result["myCoupon"]?.arrayObject ?? [["":""]]
                
                if !mycoupon.isEmpty{
                    
                    UserDefaults.save(mycoupon.first! as AnyObject, forKey: NSUserDefaultsKeys.MY_COUPON)
                }
            self.setApplyBtnState("Change", state: true)
                
            }
        }) { (error) in
            
            CommonClass.stopLoader()
        }
        
        }else{
            
            self.setApplyBtnState("Apply", state: false)

        }
    }

}


//MARK:- Textfield delegate
//MARK:- =================================================


extension PromotionsVC: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
}

//MARK:- Tableview delegate and datasource
//MARK:- =================================================


extension PromotionsVC: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.promotions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionCell", for: indexPath) as! PromotionCell
        
        if let msg = self.promotions[indexPath.row]["message"] as? String{
            cell.couponLbl.text = msg
        }
        if let code = self.promotions[indexPath.row]["coupon_code"] as? String{
            cell.promoCodeLbl.text = "Promo Code: \(code)"
        }
        if let date_created =  self.promotions[indexPath.row]["date_created"] as? String{
            
            let date = date_created.convertTimeWithTimeZone( formate: DateFormate.dateWithTime)
            
            cell.dateLbl.text = date
        }

        return cell
    }
}



//MARK:- TableView cell Classes
//MARK:- =================================================


class PromotionCell: UITableViewCell {
    
    @IBOutlet weak var couponLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var promoCodeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    
    
}
