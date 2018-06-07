//
//  PaymentMethodViewController.swift
//  UserApp
//
//  Created by Aakash Srivastav on 10/12/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

enum Sender {
    case choosePayment
    case sideMenu
}

enum CouponCodeStatus {
    case apply, change
}

class PaymentMethodViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: IBOutlets
    //MARK:- =================================================
    
    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var navigationTitle: UILabel!

    @IBOutlet weak var paymentTableView: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var addCardBtn: UIButton!
    
    // MARK: Constants
    //MARK:- =================================================
    
    let paymentTypeArray = [CASH.localized, CARD.localized]
    let paymentImageArray = ["payment_method_cash","payment_method_card"]
    var selectedIndex: IndexPath?
    var editedIndex: IndexPath?
    var filledCircle = UIImage(named: "booking_circle_filled")
    var blankCircle = UIImage(named: "booking_circle")
    
    
    // MARK: Variables
    //MARK:- =================================================
    
    var delegate: SetPaymentModeDelegate?
    var sender = Sender.sideMenu
    var coupon_status = CouponCodeStatus.apply
    var cardDetail = JSONDictionaryArray()
    var promoCode = ""
    var ApplyCoupon = false
    var isApplied = false
    var paymentMode = "Cash"
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let stripe =  CurrentUser.stripe, stripe != ""{
            
            self.getCardDetails(stripe)
        }
        
        self.ApplyCoupon = false
        
        if self.sender == .sideMenu{
            
            self.addCardBtn.isHidden = false
            
        }else{
            
            self.addCardBtn.isHidden = true
            
        }
        
        //self.paymentTableView.reloadData()
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
    
    
    
    // MARK: IBActions
    //MARK:- =================================================
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func addCardBtnTapped(_ sender: UIButton) {
        
        let transactionScene = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "TransactionDetailViewController") as! TransactionDetailViewController
        self.navigationController?.pushViewController(transactionScene, animated: true)
    }
    
    
    // MARK: Private Methods
    //MARK:- =================================================
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func dismissKeyboard(_ sender: AnyObject)
    {
        self.view.endEditing(true)
    }
    
    
    
    func initialSetup() {
        
        self.paymentTableView.dataSource = self
        
        self.paymentTableView.delegate = self
        
        self.paymentMode = CurrentUser.p_mode ?? "Cash"
        
        if sender == .sideMenu {
            
            self.backBtn.isHidden = true
            
            navigationView.setMenuButton()
        }
        
    }
    
    func promoCodeBtnTapped(_ sender: UIButton){
        
        self.ApplyCoupon = true
        
        self.paymentTableView.reloadData()
        
        
    }
    
    
    func getCardDetails(_ stripe: String){
        
        var params = JSONDictionary()
        
        CommonClass.startLoader("")
        
        params["stripe"] = stripe
        
        ServiceController.saveCardDetailAPI(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()
            
            if success{
                
                let result = json["result"].arrayObject ?? [["":""]]
                self.cardDetail = result as! JSONDictionaryArray
                self.paymentTableView.reloadData()
                
            }
        }) { (error) in
            
            CommonClass.stopLoader()
        }
        
    }
    
    
    func removeCard(_ index: Int){
        
        var cardDetail = JSONDictionaryArray()
        cardDetail = self.cardDetail
        cardDetail.remove(at: index - 1)
        var params = JSONDictionary()
        if let stripe = CurrentUser.stripe, stripe != "" {
            
            params["stripe"] = stripe
            if let cardId = self.cardDetail[index - 1]["id"]{
                params["cardID"] = cardId
            }
            
        }
        
        CommonClass.startLoader("")
        
        ServiceController.removeSaveCardApi(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()
            
            if success{
                
                self.cardDetail.remove(at: index - 1)
                self.paymentTableView.reloadData()
                
            }
            
        }) { (error) in
            
            CommonClass.stopLoader()
            
        }
    }
    
    
    
    func applyCouponBtnTapped(_ sender: UIButton){
        
        self.view.endEditing(true)
        if self.coupon_status == .apply{
            if self.promoCode == ""{
                showToastWithMessage(LoginPageStrings.enter_coupon)
                return
            }
            
            var params = JSONDictionary()
            
            params["couponCode"] = self.promoCode
            
            CommonClass.startLoader("")
            
            ServiceController.applyCouponsAPI(params, SuccessBlock: { (success,json) in
                
                CommonClass.stopLoader()
                
                if success{
                    self.coupon_status = .change
                    CommonClass.stopLoader()
                    self.paymentTableView.reloadData()
                }
            }) { (error) in
                
                CommonClass.stopLoader()
            }
        }else{
            self.coupon_status = .apply
            self.promoCode = ""
            self.paymentTableView.reloadData()
        }
    }
    
    
    func setDefaultPaymentMethod(_ p_mode: String,p_image: String){
        
        var params = JSONDictionary()
        
        params["p_mode"] = p_mode
        
        CommonClass.startLoader("")
        
        ServiceController.setDefaultPayMethodAPI(params, SuccessBlock: { (success,json) in
            CommonClass.stopLoader()
            
            if success{
                let message = json["message"].stringValue
                UserDefaults.save(p_mode as AnyObject, forKey: NSUserDefaultsKeys.P_MODE)
                
                self.paymentMode = p_mode
                showToastWithMessage(message)
                self.paymentTableView.reloadData()
            }
            
        }) { (error) in
            
            CommonClass.stopLoader()
            
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        CommonClass.delay(0.2) {
            self.promoCode = textField.text!
        }
        return true
    }
    
}

// MARK: Table View Delegate and datasource
//MARK:- =================================================

extension PaymentMethodViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sender == .sideMenu{
            return self.cardDetail.count + 1
        }else{
            return self.cardDetail.count + 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if self.sender == .sideMenu{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentTableViewCell", for: indexPath) as! PaymentTableViewCell
            
            
            if indexPath.row == 0{
                
                cell.deleleBtn.isHidden = true
                cell.tapEditBtn.isHidden = true
                cell.paymentTypeLabel.text = PaymentMode.cash
                cell.paymentTypeImageView.image = UIImage(named: "payment_method_cash")
                
                if self.paymentMode.lowercased() == PaymentMode.cash.lowercased(){
                    
                    cell.checkImage.image = self.filledCircle
                    
                }else{
                    
                    cell.checkImage.image = self.blankCircle
                    
                }

            }else{
                
                
                
                    if self.editedIndex == indexPath {
                        
                        cell.deleleBtn.isHidden = false
                        
                    }else{
                        
                        cell.deleleBtn.isHidden = true
                    }
                
                
                    let id = self.cardDetail[indexPath.row - 1]["id"] as? String ?? ""
                    
                    if self.paymentMode == id{
                        
                        cell.tapEditBtn.isHidden = true

                        cell.checkImage.image = self.filledCircle
                        
                    }else{
                        
                        cell.tapEditBtn.isHidden = false

                        cell.checkImage.image = self.blankCircle
                        
                    }

                    
                    cell.tapEditBtn.addTarget(self, action: #selector(self.editBtnTapped(_:)), for: UIControlEvents.touchUpInside)
                    
                    cell.deleleBtn.addTarget(self, action: #selector(self.deleteBtnTapped(_:)), for: UIControlEvents.touchUpInside)
                    
                    cell.paymentTypeLabel.text = "Card :  **** \(self.cardDetail[indexPath.row - 1]["last4"]!)"
                    
                    cell.paymentTypeImageView.image = UIImage(named: "payment_method_card")
                    
            }
            return cell
            
        }else{
            
            if indexPath.row == self.cardDetail.count + 1 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "PromoCodeBtnCell", for: indexPath) as! PromoCodeBtnCell
                cell.couponCodeTextField.delegate = self
                cell.promoCodeBtn.addTarget(self, action: #selector(self.promoCodeBtnTapped(_:)), for: UIControlEvents.touchUpInside)
                cell.applyCouponCodeBtn.addTarget(self, action: #selector(self.applyCouponBtnTapped(_:)), for: UIControlEvents.touchUpInside)
                
                if self.coupon_status == .change{
                    
                    cell.applyCouponCodeBtn.setTitle("Change", for: UIControlState())
                    cell.couponCodeTextField.isEnabled = false
                    cell.appliedLbl.isHidden = false
                    
                }else{
                    
                    cell.applyCouponCodeBtn.setTitle("Apply", for: UIControlState())
                    cell.couponCodeTextField.isEnabled = true
                    cell.couponCodeTextField.text = ""
                    cell.appliedLbl.isHidden = true
                    
                }
                
                return cell
                
                
            }else{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentTableViewCell", for: indexPath) as! PaymentTableViewCell
                
                
                if indexPath.row == 0{
                    
                    cell.tapEditBtn.isHidden = true
                    
                    cell.deleleBtn.isHidden = true
                    
                    cell.paymentTypeLabel.text = PaymentMode.cash
                    
                    cell.paymentTypeImageView.image = UIImage(named: "payment_method_cash")
                    
                    
                    if self.paymentMode.lowercased() == PaymentMode.cash.lowercased(){
                        
                        cell.checkImage.image = self.filledCircle
                        
                    }else{
                        
                        cell.checkImage.image = self.blankCircle
                        
                    }
                    
                }else{
                    
                    let id = self.cardDetail[indexPath.row - 1]["id"] as? String ?? ""
                    
                    if self.paymentMode == id{
                        
                        cell.checkImage.image = self.filledCircle
                        
                    }else{
                        
                        cell.checkImage.image = self.blankCircle
                        
                    }
                    
                    cell.tapEditBtn.isHidden = true
                    cell.deleleBtn.isHidden = true
                    cell.paymentTypeLabel.text = "Card :  **** \(self.cardDetail[indexPath.row - 1]["last4"]!)"
                    cell.paymentTypeImageView.image = UIImage(named: "payment_method_card")
                    
                }
                return cell
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.sender == .sideMenu{
            
            return 60
            
        }else{
            if indexPath.row == self.cardDetail.count + 1{
                return 114
            }else{
                return 60
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        self.editedIndex = nil
        
        if self.selectedIndex == indexPath{
            
            self.selectedIndex = nil
            
        }else{
            
            self.selectedIndex = indexPath
        }
        
        
        if self.sender == .choosePayment{
            
            if indexPath.row == self.cardDetail.count + 1{
                return
            }else{
                
                if indexPath.row == 0{
                    self.delegate?.setPaymentMode(self.paymentTypeArray.first!, paymentImage: self.paymentImageArray.first!)
                    self.navigationController?.popViewController(animated: true)
                    
                    
                }else{
                    self.delegate?.setPaymentMode(self.cardDetail[self.selectedIndex!.row - 1]["id"] as? String ?? "", paymentImage: self.paymentImageArray.last!)
                    self.navigationController?.popViewController(animated: true)
                    
                }
            }
            
            
        }
        
        
        
        if self.sender == .sideMenu{
            
            
            if indexPath.row == 0{
                self.setDefaultPaymentMethod(self.paymentTypeArray.first!, p_image: self.paymentImageArray.first!)
                
            }else{
                self.setDefaultPaymentMethod(self.cardDetail[self.selectedIndex!.row - 1]["id"] as? String ?? "", p_image: self.paymentImageArray.last!)
                
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        UIView.animate(withDuration: 0.8, animations: {
            cell.contentView.alpha = 1.0
        })
        
    }
    
    
    func deleteBtnTapped(_ sender: UIButton){
        
        if let indexPath = sender.tableViewIndexPath(self.paymentTableView) {
            
            self.removeCard(indexPath.row)
            self.editedIndex = nil
            self.paymentTableView.reloadData()
            
        }
        
    }
    
    func editBtnTapped(_ sender: UIButton){
        
        self.selectedIndex = nil
        if let indexPath = sender.tableViewIndexPath(self.paymentTableView) {
            sender.isSelected = !sender.isSelected
            
            if self.editedIndex == indexPath{
                
                self.editedIndex = nil
                
            }else{
                self.editedIndex = indexPath
                
            }
            self.paymentTableView.reloadData()
        }
        
    }
    
    
    
}

//MARK:- Tableview cell classess
//MARK:- =================================================
class PaymentTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var paymentTypeImageView: UIImageView!
    @IBOutlet weak var paymentTypeLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet var checkImage: UIImageView!
    
    @IBOutlet weak var deleleBtn: UIButton!
    @IBOutlet weak var tapEditBtn: UIButton!
    // MARK: Table View Cell Life Cycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.bgView.layer.cornerRadius = 3
    }
    
    // MARK: Private Methods
    func populateCell(withPaymentType paymentName: String, paymentTypeImage imageName: String) {
        
        self.paymentTypeLabel.text = paymentName
        self.paymentTypeImageView.image = UIImage(named: imageName)
    }
}

class PromoCodeBtnCell: UITableViewCell {
    
    @IBOutlet weak var promoCodeBtn: UIButton!
    
    @IBOutlet weak var couponCodeTextField: UITextField!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var appliedLbl: UILabel!
    @IBOutlet weak var applyCouponCodeBtn: UIButton!
    
}

