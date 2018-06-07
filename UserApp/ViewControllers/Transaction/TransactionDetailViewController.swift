//
//  TransactionDetailViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 10/24/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import Foundation
import Stripe
import IQKeyboardManager
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



class TransactionDetailViewController: UIViewController {

    

    
    // MARK: =====
    // MARK: Enums
    enum PickerType {
        
        case month
        case year
        case none
    }
    
    enum Month: Int {
        
        case january
        case february
        case march
        case april
        case may
        case june
        case july
        case august
        case september
        case october
        case november
        case december
        
        var description: String {
            
            switch self {
                
            case .january: return "January"
            case .february: return "February"
            case .march: return "March"
            case .april: return "April"
            case .may: return "May"
            case .june: return "June"
            case .july: return "July"
            case .august: return "August"
            case .september: return "September"
            case .october: return "October"
            case .november: return "November"
            case .december: return "December"
                
            }
        }
    }
    
    // MARK: ========
    // MARK: IBOulets
    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var topHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var cardNoLbl: UILabel!
    @IBOutlet weak var expiryLbl: UILabel!
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var yearLbl: UILabel!
    @IBOutlet weak var cvvLbl: UILabel!
    @IBOutlet weak var nameOnCardTextField: TextField!
    @IBOutlet weak var firstCardNumberTextField: TextField!
    @IBOutlet weak var expiryMonthTextField: TextField!
    @IBOutlet weak var expiryYearTextField: TextField!
    @IBOutlet weak var cvvNumberTextField: TextField!
    @IBOutlet weak var cardNameView: UIView!
    @IBOutlet weak var cardNoView: UIView!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var yearView: UIView!
    @IBOutlet weak var cvvView: UIView!
    
    
    
    @IBOutlet weak var payNowBtn: UIButton!
    
    // MARK: =========
    // MARK: Variables
    
    var activeTextField: UITextField?
    lazy var pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 146))
    lazy var pickerDoneView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40))
    lazy var pickerDoneButton = UIButton(frame: CGRect(x: screenWidth/2, y: 0, width: screenWidth/2, height: 40))
    lazy var pickerCancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth/2, height: 40))
    
    var pickerType: PickerType = .none
    var currentYear: Int = 0
    var cardNumber = ""
    var cardDetails = JSONDictionaryArray()
    var amt : String!
    
    
    fileprivate var isallFieldsVerified: Bool {
        
        if self.firstCardNumberTextField.text == "" {
            showToastWithMessage(AddCardString.enterCardNo)
            return false
        }

        if self.firstCardNumberTextField.text!.characters.count < 16 {
            showToastWithMessage(AddCardString.validCardNo)
            return false
        }
        if !self.expiryMonthTextField.hasText {
            showToastWithMessage(AddCardString.enterMonth)
            return false
        }
        if !self.expiryYearTextField.hasText {
            showToastWithMessage(AddCardString.enterYear)
            return false
        }
        if !self.cvvNumberTextField.hasText {
            showToastWithMessage(AddCardString.enterCvv)
            return false
        }
        if self.cvvNumberTextField.text?.characters.count < 3 {
            showToastWithMessage(AddCardString.validCvv)
            return false
        }
        
        return true
    }
    
    

    // MARK: =================================
    // MARK: ViewController Life Cycle Methods
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialSetup()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    
    
    // MARK: =========
    // MARK: IBActions
    
    
    
    @IBAction func payNowBtnTapped(_ sender: UIButton) {
        
            self.view.endEditing(true)
        guard CommonClass.isConnectedToNetwork else{
            showToastWithMessage(NO_INTERNET)
            return
        }
        
            if isallFieldsVerified {
        
                CommonClass.startLoader("")
                let cardParams = STPCardParams()
        
                cardParams.number = self.firstCardNumberTextField.text!
        
                cardParams.expYear = UInt((self.expiryYearTextField.text)!)!
        
                cardParams.expMonth = UInt((self.expiryMonthTextField.text)!)!
        
                cardParams.cvc = self.cvvNumberTextField.text
                cardParams.name = self.nameOnCardTextField.text
        
                STPAPIClient.shared().createToken(withCard: cardParams) { (token, error) in
        
                    if let error = error {
                        
                        printlnDebug(error)
                        if let msg = error._userInfo?["NSLocalizedDescription"] as? String{
                            showToastWithMessage(msg)
                        }
                        CommonClass.stopLoader()
                        
                    } else if let token = token {
                        
                        printlnDebug(token)
                        var params = JSONDictionary()
                        params["token"] = token
                        printlnDebug(params)
        
                        ServiceController.addUserCardAPI(params, SuccessBlock: { (success,json) in
                            
                            CommonClass.stopLoader()

                            if success{
                                let result = json["result"].dictionary ?? ["":""]
                                let stripe = result["stripe"]?.string ?? ""
                                
                                UserDefaults.save(stripe as AnyObject, forKey: NSUserDefaultsKeys.STRIPE_ID)
                            
                            self.navigationController?.popViewController(animated: true)
                            
                            }
                            }, failureBlock: { (error) in
                                
                                CommonClass.stopLoader()
                                
                        })
                    }
                }
            }

    }
    
    
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    
    // MARK: ===============
    // MARK: Private Methods
    
    func keyboardWillShow(_ notification: Notification) {
        
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue, (self.activeTextField != nil) {
            
            if screenHeight < CGFloat(667){
                UIView.animate(withDuration: 0.25, animations: {
                    
                    self.topHeightConstraint.constant = 10
                    self.view.layoutIfNeeded()
                }) 
            }
        }
    }
    
    
    
    func keyboardWillHide(_ notification: Notification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
                self.bringViewToInitialPosition()
            
        }
    }
    
    
    
    func bringViewToInitialPosition() {
        
        UIView.animate(withDuration: 0.25, animations: {
            
            self.topHeightConstraint.constant = 25
            self.view.layoutIfNeeded()
        }) 
    }
    
    
    
    func initialSetup() {
        
        self.nameOnCardTextField.delegate = self
        self.firstCardNumberTextField.delegate = self
        self.expiryMonthTextField.delegate = self
        self.expiryYearTextField.delegate = self
        self.cvvNumberTextField.delegate = self
        
        
        
        let borderColor = UIColor(colorLiteralRed: 41/255.0, green: 41/255.0, blue: 41/255.0, alpha: 1).cgColor
        let borderWidth: CGFloat = 1
        let cornerRadius: CGFloat = 3


        self.cardNameView.layer.cornerRadius = cornerRadius
        self.cardNoView.layer.cornerRadius = cornerRadius
        self.monthView.layer.cornerRadius = cornerRadius
        self.yearView.layer.cornerRadius = cornerRadius
        self.cvvView.layer.cornerRadius = cornerRadius
        self.payNowBtn.layer.cornerRadius = cornerRadius

        
        self.cardNameView.layer.borderColor = borderColor
        self.cardNoView.layer.borderColor = borderColor
        self.monthView.layer.borderColor = borderColor
        self.yearView.layer.borderColor = borderColor
        self.cvvView.layer.borderColor = borderColor
        
        
        self.cardNameView.layer.borderWidth = borderWidth
        self.cardNoView.layer.borderWidth = borderWidth
        self.monthView.layer.borderWidth = borderWidth
        self.yearView.layer.borderWidth = borderWidth
        self.cvvView.layer.borderWidth = borderWidth
        
        let pickerHeight: CGFloat = (IsIPad ? 216:146)
        let pickerBtnHeight: CGFloat = (IsIPad ? 60:40)
        
        self.pickerDoneView.frame.size.height = pickerBtnHeight
        self.pickerDoneButton.frame.size.height = pickerBtnHeight
        self.pickerCancelButton.frame.size.height = pickerBtnHeight
        self.pickerView.frame.size.height = pickerHeight
        
        self.pickerDoneView.backgroundColor = UIColor(red: 194/255.0, green: 0/255.0, blue: 52/255.0, alpha: 1)
        self.pickerView.backgroundColor = UIColor.white
        self.pickerDoneButton.tintColor = UIColor.white
        self.pickerCancelButton.tintColor = UIColor.white
        
        
//        let doneBtnAttributedTitle = NSAttributedString(string: "Done", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "SFUIDisplay-Medium", size: (IsIPad ? 20.0:13.0))!])
//        self.pickerDoneButton.setAttributedTitle(doneBtnAttributedTitle, forState: .Normal)
//        
//        let cancelBtnAttributedTitle = NSAttributedString(string: "Cancel", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "SFUIDisplay-Medium", size: (IsIPad ? 20:13))!])
//        self.pickerCancelButton.setAttributedTitle(cancelBtnAttributedTitle, forState: .Normal)
        
        self.pickerDoneButton.setTitle("DONE", for: UIControlState())
        self.pickerCancelButton.setTitle("CANCEL", for: UIControlState())

        let separatorView = UIView(frame: pickerDoneView.frame)
        separatorView.frame.size.width = 1
        separatorView.center = pickerDoneView.center
        separatorView.backgroundColor = UIColor.white

        self.pickerDoneView.addSubview(self.pickerDoneButton)
        self.pickerDoneView.addSubview(self.pickerCancelButton)
        self.pickerDoneView.addSubview(separatorView)

        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        
        self.pickerDoneButton.addTarget(self, action: #selector(pickerDoneTapped(_:)), for: .touchUpInside)
        self.pickerCancelButton.addTarget(self, action: #selector(pickerCancelTapped(_:)), for: .touchUpInside)
        
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year], from: date)
        
        self.currentYear =  components.year!
    }
    
    
    
    
    func pickerDoneTapped(_ sender: UIButton) {
        
        if pickerType == .month {
            self.expiryMonthTextField.text = String(format: "%02d", 1+self.pickerView.selectedRow(inComponent: 0))
        } else {
            self.expiryYearTextField.text = "\(self.currentYear+self.pickerView.selectedRow(inComponent: 0))"
        }
        self.view.endEditing(true)
    }
    
    
    
    func pickerCancelTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
    }
    
}



// MARK: ==========================
// MARK: TextField Delegate Methods
extension TransactionDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
            if textField === self.expiryMonthTextField {
                
                self.pickerType = .month
                self.pickerView.reloadAllComponents()
                if textField.hasText {
                    self.pickerView.selectRow(Int(textField.text!)!-1, inComponent: 0, animated: true)
                } else {
                    self.pickerView.selectRow(0, inComponent: 0, animated: true)
                }
                
                textField.inputView = self.pickerView
                textField.inputAccessoryView = self.pickerDoneView
                
            } else if textField === self.expiryYearTextField {
                
                self.pickerType = .year
                self.pickerView.reloadAllComponents()
                if textField.hasText {
                    self.pickerView.selectRow(Int(textField.text!)!-currentYear, inComponent: 0, animated: true)
                } else {
                    self.pickerView.selectRow(0, inComponent: 0, animated: true)
                }
                
                textField.inputView = self.pickerView
                textField.inputAccessoryView = self.pickerDoneView
                
            } else {
                textField.inputView = nil
                textField.inputAccessoryView = nil
            }
        return true
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField === self.cvvNumberTextField {
            self.activeTextField = textField
        } else {
            self.activeTextField = nil
            self.bringViewToInitialPosition()
        }
    
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        
        if textField === self.nameOnCardTextField{
            if range.location < 30{
                return true
            }else{
                return false
            }
        }
        
        else if textField === self.firstCardNumberTextField {
            
            if range.location < 17 {
                return true

            }else{
                return false

            }
        }
        
        else if textField === self.cvvNumberTextField {
            if range.location < 4{
                return true
            }
         else {
                return false
        }
    }
        
        return true
    
    }
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField === self.nameOnCardTextField {
            self.firstCardNumberTextField.becomeFirstResponder()
        } else if textField === self.firstCardNumberTextField {
            self.expiryMonthTextField.becomeFirstResponder()
        } else if textField === self.expiryMonthTextField {
            self.expiryYearTextField.becomeFirstResponder()
        } else if textField === self.expiryYearTextField {
            self.cvvNumberTextField.becomeFirstResponder()
        } else if textField === self.cvvNumberTextField {
            textField.resignFirstResponder()
        }
        return false
    }
    
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    
}




// MARK: ==========================================
// MARK: PickerView DataSource and Delegate Methods



extension TransactionDetailViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerType == .year {
            return 30
        }
        return 12
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerType == .year {
            return "\(self.currentYear+row)"
        }
        return Month(rawValue: row)?.description
        
    }
}
