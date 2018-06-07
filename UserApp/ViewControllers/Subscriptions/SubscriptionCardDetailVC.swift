
//
//  SubscriptionCardDetailVC.swift
//  UserApp
//
//  Created by Appinventiv on 01/12/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import Stripe
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


protocol ShowTotalAmountDelegate: class {
    func showAmount(_ amount: String)
}

enum CardDetailType{
    case saved,enter
}


enum CreditCardType: CustomStringConvertible {
    case amex, dinersClub, discover, jcb, masterCard, visa, unknown
    
    var description: String {
        switch self {
        case .amex:
            return "American Express"
        case .dinersClub:
            return "Diners Club"
        case .discover:
            return "Discover"
        case .jcb:
            return "JCB"
        case .masterCard:
            return "MasterCard"
        case .visa:
            return "Visa"
        case .unknown:
            return "Unknown"
        }
    }
}

class SubscriptionCardDetailVC: UIViewController {
    
    //MARK:- IBOutlets
    //MARK:- =================================================
    
    
    @IBOutlet var navigationTitle: UILabel!
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var cardDetailLbl: UILabel!
    @IBOutlet var enterCardDetailLbl: UILabel!
    @IBOutlet var cardNoTaextField: UITextField!
    @IBOutlet var expiryDateLbl: UITextField!
    @IBOutlet var cVVTextField: UITextField!
    @IBOutlet var detailBgView: UIView!
    @IBOutlet weak var selectCardLbl: UILabel!
    @IBOutlet var payNowBtn: UIButton!
    @IBOutlet var saveCardDetailTableView: UITableView!
    
    //MARK:- Properties
    //MARK:- =================================================
    
    
    var saveCardDetails = JSONDictionaryArray()
    var amount: String!
    weak var delegate:ShowTotalAmountDelegate!
    var cardDetailtype: CardDetailType = .enter
    var cardNo = ""
    var index:Int!
    var selectedIndexPath:IndexPath?
    var editSelectedIndexPath:IndexPath?
    
    
    
    fileprivate var isallFieldsVerified: Bool {
        
        if !self.cardNoTaextField.hasText{
            showToastWithMessage(AddCardString.enterCardNo)
            return false
        }
        
        if self.cardDetailtype == .enter{
            
            if self.cardNoTaextField.text!.characters.count < 16 {
                showToastWithMessage(AddCardString.validCardNo)
                return false
            }
        }
        if !self.expiryDateLbl.hasText {
            showToastWithMessage(AddCardString.enterExpiry)
            return false
        }
        if !self.cVVTextField.hasText {
            showToastWithMessage(AddCardString.enterCvv)
            return false
        }
        
        if self.cVVTextField.text?.characters.count < 3 {
            showToastWithMessage(AddCardString.validCvv)
            return false
        }
        
        return true
    }
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cardNoTaextField.delegate = self
        self.payNowBtn.layer.cornerRadius = 3
        self.expiryDateLbl.delegate = self
        self.cVVTextField.delegate = self
        self.saveCardDetailTableView.delegate = self
        self.saveCardDetailTableView.dataSource = self
        
        if let stripe = CurrentUser.stripe, stripe != "" {
            
            self.getCardDetail(stripe)
        }
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
    }
    
    
    
    //MARK:- IBActions
    //MARK:- =================================================
    
    
    @IBAction func backBtntapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func payNowBtnTapped(_ sender: UIButton) {
        
        if isallFieldsVerified{
            
            if self.cardDetailtype == .enter{
                
                self.makeEnteredCardDetailPayment()
                
            }else{
                
                var params = JSONDictionary()
                params["action"] = "save_card" as AnyObject
                params["token"] = self.saveCardDetails[index]["id"]!
                params["stripe_id"] = CurrentUser.stripe! as AnyObject
                params["amount"] = self.amount as AnyObject
                self.makePayment(params)
                
            }
        }
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
    
    
    
}



//MARK:- Private methods
//MARK:- =================================================


private extension SubscriptionCardDetailVC{
    
    func getCardDetail(_ stripe: String){
        
        CommonClass.startLoader("")
        var params = JSONDictionary()
        
        params["stripe"] = stripe as AnyObject
        
        ServiceController.saveCardDetailAPI(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()
            
            if success{
                
                let result = json["result"].arrayObject ?? [["":""]]
                self.saveCardDetails = result as! JSONDictionaryArray
                self.saveCardDetailTableView.reloadData()
                
            }
        }) { (error) in
            
            CommonClass.stopLoader()
        }
    }
    
    
    func makeEnteredCardDetailPayment(){
        
        CommonClass.startLoader("")
        print_debug(self.cardNoTaextField.text)
        let cardParams = STPCardParams()
        
        cardParams.number = self.cardNoTaextField.text!
        
        cardParams.expMonth = UInt((self.expiryDateLbl.text?.components(separatedBy: "/")[0])!)!
        
        cardParams.expYear = UInt((self.expiryDateLbl.text?.components(separatedBy: "/")[1])!)!
        
        cardParams.cvc = self.cVVTextField.text
        
        STPAPIClient.shared().createToken(withCard: cardParams) { (token, error) in
            
            if let error = error {
                print_debug(error)
                CommonClass.stopLoader()
            } else if let token = token {
                print_debug(token)
                var params = JSONDictionary()
                params["token"] = token
                params["action"] = "new_card" as AnyObject
                params["amount"] = self.amount as AnyObject
                print_debug(params)
                self.makePayment(params)
            }
        }
    }
    
    
    func makePayment(_ params: JSONDictionary){
        
        CommonClass.startLoader("")
        ServiceController.subsAddUserMonetApi(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()
            
            if success{
                
                let result = json["result"].dictionary ?? ["":""]
                let amnt = result["balance"]?.string ?? ""
                
                
                UserDefaults.save(amnt as AnyObject, forKey: NSUserDefaultsKeys.SUBSCRIPTION_AMNT)
                
                self.navigationController?.popToRootViewController(animated: true)
                
            }
            
        }, failureBlock: { (error) in
            
            CommonClass.stopLoader()
        })
        
    }
    
    
    
    
    
    func removeCard(_ index: Int){
        
        var cardDetail = JSONDictionaryArray()
        cardDetail = self.saveCardDetails
        cardDetail.remove(at: index)
        var params = JSONDictionary()
        
        if let stripe = CurrentUser.stripe, stripe != "" {
            
            params["stripe"] = stripe
            if let cardId = self.saveCardDetails[index]["id"]{
                params["cardID"] = cardId
            }
            
        }
        
        
        ServiceController.removeSaveCardApi(params, SuccessBlock: { (success,json) in
            
            if success{
                
                self.saveCardDetails.remove(at: index)
                self.saveCardDetailTableView.reloadData()
            }
            
        }) { (error) in
            
        }
        
    }
    
    
    func getCardLengthFor(_ cardTypeStr: String) -> [Int] {
        
        if CreditCardType.amex.description == cardTypeStr {
            return [15]
        }
        else if CreditCardType.dinersClub.description == cardTypeStr {
            return [14, 15, 16]
        }
        else if CreditCardType.visa.description == cardTypeStr {
            return [13, 16]
        }
        else {
            return [16]
        }
    }
    
    
}


//MARK:- UITextfield delegate
//MARK:- =================================================


extension SubscriptionCardDetailVC: UITextFieldDelegate, STPPaymentCardTextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //        if textField == self.cardNoTaextField {
        //
        //            self.cardNoTaextField.hidden = true
        //            self.expiryDateLbl.text = ""
        //
        //            self.cardNumberView.clear()
        //            delay(0, closure: {
        //                self.cardNumberView.hidden = false
        //                self.cardNumberView.becomeFirstResponder()
        //            })
        //        }
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField === self.cardNoTaextField {
            
            if range.location > 16{
                
                self.expiryDateLbl.becomeFirstResponder()
                
                return false
            }
            else {
                return true
            }
            
        } else if textField === self.expiryDateLbl{
            
            if range.location == 2 {
                self.expiryDateLbl.text = (self.expiryDateLbl.text)! + "/"
                return true
            }
            else if range.location == 3 && string == "" {
                self.expiryDateLbl.text = self.expiryDateLbl.text?.replacingOccurrences(of: "/", with: "")
            }
            else if range.location > 6{
                self.cVVTextField.becomeFirstResponder()
                return false
            }else{
                return true
            }
            
        } else {
            if range.location < 4{
                return true
            }
            else {
                return false
            }
        }
        return true
    }
    
    
    
    
    
    func setCardDetailData(_ index: Int) {
        
        if let last4 = self.saveCardDetails[index]["last4"]{
            
            self.cardNoTaextField.text = "xxxx \(last4)"
            
        }
        
        self.expiryDateLbl.text = "\(self.saveCardDetails[index]["exp_month"]!)/\(self.saveCardDetails[index]["exp_year"]!)"
        self.cVVTextField.text = ""
    }
    
}



//MARK:- UITableview datasource and delegate
//MARK:- =================================================


extension SubscriptionCardDetailVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.saveCardDetails.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SaveCardCell", for: indexPath) as! SaveCardCell
        //        if let brand = self.saveCardDetails[indexPath.row]["brand"] as? String{
        //            //cell.cardTypeBtn.text = brand
        //        }
        
        cell.cardLbl.text = "**** \(self.saveCardDetails[indexPath.row]["last4"] as? String ?? "")"
        if self.selectedIndexPath == indexPath{
            cell.radioBtn.setImage(UIImage(named: "booking_circle_filled"), for: UIControlState())
        }else{
            cell.radioBtn.setImage(UIImage(named: "booking_circle"), for: UIControlState())
        }
        
        if cell.editBtn.isSelected && self.editSelectedIndexPath == indexPath{
            
            cell.deleteBtn.isHidden = false
            
        }else{
            cell.deleteBtn.isHidden = true
        }
        
        cell.editBtn.addTarget(self, action: #selector(self.editBtnTapped(_:)), for: UIControlEvents.touchUpInside)
        cell.deleteBtn.addTarget(self, action: #selector(self.deleteBtnTapped(_:)), for: UIControlEvents.touchUpInside)
        cell.radioBtn.addTarget(self, action: #selector(self.radioBtnTapped(_:)), for: UIControlEvents.touchUpInside)
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.editSelectedIndexPath = nil
        self.saveCardDetailTableView.reloadData()
    }
    
    
    //MARK:- Target Methods
    
    
    func editBtnTapped(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
        if let indexPath = sender.tableViewIndexPath(self.saveCardDetailTableView){
            
            if sender.isSelected{
                self.editSelectedIndexPath = indexPath
            }else{
                self.editSelectedIndexPath = indexPath
            }
            self.saveCardDetailTableView.reloadData()
        }
    }
    
    func deleteBtnTapped(_ sender: UIButton){
        
        if let indexPath = sender.tableViewIndexPath(self.saveCardDetailTableView){
            if !self.saveCardDetails.isEmpty{
                self.editSelectedIndexPath = nil
                self.removeCard(indexPath.row)
            }
        }
    }
    
    
    
    func radioBtnTapped(_ sender: UIButton){
        
        self.editSelectedIndexPath = nil
        if let indexPath = sender.tableViewIndexPath(self.saveCardDetailTableView){
            self.selectedIndexPath = indexPath
            self.cardDetailtype = .saved
            self.index = indexPath.row
            self.setCardDetailData(indexPath.row)
            self.saveCardDetailTableView.reloadData()
        }
    }
    
}


//MARK:- Tableview cell classess
//MARK:- =================================================


class SaveCardCell: UITableViewCell {
    
    @IBOutlet var radioBtn: UIButton!
    @IBOutlet var editBtn: UIButton!
    @IBOutlet var bgView: UIView!
    @IBOutlet var cardLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var cardTypeBtn: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
