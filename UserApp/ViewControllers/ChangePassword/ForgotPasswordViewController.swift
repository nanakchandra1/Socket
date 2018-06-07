//
//  ForgotPasswordViewController.swift
//  DriverApp
//
//  Created by saurabh on 06/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import IQKeyboardManager

class ForgotPasswordViewController: BaseViewController {
    
    // MARK: Constants
    
    
    // MARK: Variables
    
    
    // MARK: IBOutlets
    //MARK:- =================================================

    @IBOutlet weak var dontWorryLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var enterMobileMsmLbl: UILabel!

    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var textFieldBorderView: UIView!
    
    @IBOutlet weak var firstDotView: UIView!
    @IBOutlet weak var centerDotView: UIView!
    @IBOutlet weak var bgViewCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var lastDotView: UIView!
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialSetup()
        
        self.mobileNumberTextField.delegate = self
        self.countryCodeTextField.delegate = self
        
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.mobileNumberTextField.text = nil
        self.countryCodeTextField.text = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private methods
    //MARK:- =================================================

    
    
    func initialSetup() {
        
        let cornerRadius: CGFloat = IsIPad ? 5:3.5
        
        // Customising buttons and label
        self.sendBtn.layer.cornerRadius = cornerRadius
        
        self.textFieldBorderView.layer.cornerRadius = cornerRadius
        self.textFieldBorderView.layer.borderColor = UIColor.lightGray.cgColor
        self.textFieldBorderView.layer.borderWidth = 1.5
        
        // Drawing traingle for slant View
        
        let slope: CGFloat = IsIPad ? 70:50
        
        self.cancelBtn.addSlope(withColor: UIColor.gray, ofWidth: slope, ofHeight: slope)
        
        if self.cancelBtn.imageView != nil {
            
            self.cancelBtn.bringSubview(toFront: self.cancelBtn.imageView!)
        }
        self.cancelBtn.imageEdgeInsets = IsIPad ? UIEdgeInsetsMake(0, 28, 22, 0):UIEdgeInsetsMake(0, 22, 18, 0)
        
        self.firstDotView.layer.cornerRadius = cornerRadius
        self.centerDotView.layer.cornerRadius = cornerRadius
        self.lastDotView.layer.cornerRadius = cornerRadius
    }
    
    
    func keyboardWillShow(_ notification: Notification) {
        
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            if UIScreen.main.bounds.height < CGFloat(667){
                self.bgViewCenterConstraint.constant = -50
            }
        }
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.bgViewCenterConstraint.constant = 0
        }
    }
    


    // Check is all field details are valid
    func isAllFieldsVerified() -> Bool {
        
        if self.countryCodeTextField.text == nil || self.countryCodeTextField.text!.isEmpty {
            
            showToastWithMessage(ProfileStrings.selectCountryCode)
            return false
            
        } else if (self.mobileNumberTextField.text == nil) || self.mobileNumberTextField.text!.isEmpty {
            
            showToastWithMessage(ProfileStrings.enterMobile)
            return false
            
        } else if !isValidPhoneNumber(self.mobileNumberTextField.text!) {
            
            showToastWithMessage(ProfileStrings.validMobile)
            return false
        }
        
        return true
    }
    
    
    
    
    // MARK: IBActions
    //MARK:- =================================================

    @IBAction func sendBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if isAllFieldsVerified() {
            
            // #Warning: Need code for navigation
            self.sendOTPAction()
        }
        
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        removeFromUserDefaults(NSUserDefaultKey.UserId)
        removeFromUserDefaults(NSUserDefaultKey.UserInfoDict)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        removeFromUserDefaults(NSUserDefaultKey.UserId)
        removeFromUserDefaults(NSUserDefaultKey.UserInfoDict)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: Web APIs
    
    func sendOTPAction() {
        
        guard CommonClass.isConnectedToNetwork else{
            
            showToastWithMessage(NO_INTERNET)
            
            return
        }
        
        CommonClass.startLoader("")
        
        var params = JSONDictionary()
        
        params["mobile"] =  self.countryCodeTextField.text! + self.mobileNumberTextField.text!
        
        
        ServiceController.forgotPassowrdApi(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()
            
            if success{
                
                let otpVc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
                
//                if let otp = json["temp_code"].stringValue{
//                    
//                    otpVc.OTP = otp
//                    
//                }
                
                otpVc.mobileNumberText = self.mobileNumberTextField.text!
                otpVc.code =  self.countryCodeTextField.text!
                self.navigationController?.pushViewController(otpVc, animated: true)

            }

        }) { (error) in
            
                printlnDebug(error)
                CommonClass.stopLoader()

        }

    }
    
}





// MARK: Text Field Delegate Life Cycle Methods
//MARK:- =================================================


extension ForgotPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
            if textField === self.countryCodeTextField{
                
                let vc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "CountryListVC") as! CountryListVC
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
                return false

            }
            
        return true
    }
    
    
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let txt = textField.text{
            
            let maxLength = 10
            let currentString: NSString = txt as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
            
        }
        
        return true
        
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField === self.countryCodeTextField{
            textField.resignFirstResponder()

        }
        return true
    }
    
    
}


// MARK: UIPickerView Delegate  Methods
//MARK:- =================================================


extension ForgotPasswordViewController: ShowCountryDetailDelegate {
    
    func getCountryDetails(_ text:String!,countryName:String!,Max_NSN_Length:Int!,Min_NSN_Length:Int!,countryShortName : String!){
        self.countryCodeTextField.text = text
    }
}

