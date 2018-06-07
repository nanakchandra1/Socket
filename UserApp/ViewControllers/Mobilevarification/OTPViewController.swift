//
//  OTPViewController.swift
//  DriverApp
//
//  Created by saurabh on 06/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import IQKeyboardManager

class OTPViewController: BaseViewController {
    
    // MARK: Variables
    //MARK:- =================================================

    var OTP: String!
    var mobileNumberText:String!
    var code:String!
    
    // MARK: IBOutlets
    //MARK:- =================================================

    
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var dontWorryLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var enterOtpMsmLbl: UILabel!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var resendBtn: UIButton!
    
    @IBOutlet weak var firstDigitTextField: UITextField!
    @IBOutlet weak var secondDigitTextField: UITextField!
    @IBOutlet weak var thirdDigitTextField: UITextField!
    @IBOutlet weak var fourthDigitTextField: UITextField!
    @IBOutlet weak var bgViewcenterConstant: NSLayoutConstraint!

    @IBOutlet weak var firstDotView: UIView!
    @IBOutlet weak var centerDotView: UIView!
    @IBOutlet weak var lastDotView: UIView!
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if OTP != nil{
            //showToastWithMessage("Your OTP is: \(self.OTP!)")

        }
        self.initialSetup()
        
        self.firstDigitTextField.delegate = self
        self.secondDigitTextField.delegate = self
        self.thirdDigitTextField.delegate = self
        self.fourthDigitTextField.delegate = self
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        
        self.firstDigitTextField.text = "\u{200B}"
        self.secondDigitTextField.text = "\u{200B}"
        self.thirdDigitTextField.text = "\u{200B}"
        self.fourthDigitTextField.text = "\u{200B}"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.firstDigitTextField.text = nil
        self.secondDigitTextField.text = nil
        self.thirdDigitTextField.text = nil
        self.fourthDigitTextField.text = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private Methods
    //MARK:- =================================================

    
    func initialSetup() {
        
        let cornerRadius: CGFloat = IsIPad ? 5:3.5
        let slope: CGFloat = IsIPad ? 70:50
        
        self.cancelBtn.addSlope(withColor: UIColor.gray, ofWidth: slope, ofHeight: slope)
        if self.cancelBtn.imageView != nil {
            
            self.cancelBtn.bringSubview(toFront: self.cancelBtn.imageView!)
        }
        self.cancelBtn.imageEdgeInsets = IsIPad ? UIEdgeInsetsMake(0, 28, 22, 0):UIEdgeInsetsMake(0, 22, 18, 0)
        
        // Cutomising TextFields View
        self.textFieldView.layer.borderWidth = 1.5
        self.textFieldView.layer.borderColor = UIColor.lightGray.cgColor
        self.textFieldView.layer.cornerRadius = cornerRadius
        self.textFieldView.clipsToBounds = true
        
        // Cutomising Buttons
        self.verifyBtn.layer.cornerRadius = cornerRadius
        self.resendBtn.layer.cornerRadius = cornerRadius
        
        self.firstDotView.layer.cornerRadius = cornerRadius
        self.centerDotView.layer.cornerRadius = cornerRadius
        self.lastDotView.layer.cornerRadius = cornerRadius
    }
    
    
    
    func keyboardWillShow(_ notification: Notification) {
        
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if UIScreen.main.bounds.height < CGFloat(667){
            self.bgViewcenterConstant.constant = -50
        }
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.bgViewcenterConstant.constant = 0
        }
    }    

    // Check is all field details are valid
    func isAllFieldsVerified() -> Bool {
        
        if self.firstDigitTextField.text == "\u{200B}" || self.secondDigitTextField.text == "\u{200B}" || self.thirdDigitTextField.text == "\u{200B}" || self.fourthDigitTextField.text == "\u{200B}"{
            
            showToastWithMessage(LoginPageStrings.enetr_valid_otp)
            return false
            
        }
        
        return true
    }
    
    
    // MARK: IBActions
    //MARK:- =================================================

    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func verifyBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if isAllFieldsVerified() {
            
            // #Warning: Need code for navigation
            self.verifyOTP()
        }
    }
    
    @IBAction func resendBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        self.firstDigitTextField.text = "\u{200B}"
        self.secondDigitTextField.text = "\u{200B}"
        self.thirdDigitTextField.text = "\u{200B}"
        self.fourthDigitTextField.text = "\u{200B}"
        self.resendOTPAction()
    }
    
    
    // MARK: Web APIs
    func resendOTPAction() {
        
        guard CommonClass.isConnectedToNetwork else{
            return
        }
        var params = JSONDictionary()
        CommonClass.startLoader("")
        
         params["mobile"] = self.code + self.mobileNumberText as AnyObject
        
        ServiceController.forgotPassowrdApi(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()
            

        }) { (error) in
            
            CommonClass.stopLoader()
        }

    }

    
    func verifyOTP() {
        
        guard CommonClass.isConnectedToNetwork else{
            showToastWithMessage(NO_INTERNET)
            return
        }
        
        var params = JSONDictionary()
        
         params["action"] = "mobile"
         params["mobile"] = self.code + self.mobileNumberText
         params["otp"] = (self.firstDigitTextField.text! + self.secondDigitTextField.text! + self.thirdDigitTextField.text! + self.fourthDigitTextField.text!)

        CommonClass.startLoader("")

        ServiceController.varifyforgotPassowrdOtpApi(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()
            
            if success{
                let result = json["result"]
                userdata.saveJSONDataToUserDefault(result)
                let updatePasswordVc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "UpdatePasswordViewController") as! UpdatePasswordViewController
                updatePasswordVc.mobileNumberText = self.mobileNumberText
                updatePasswordVc.code = self.code
                self.navigationController?.pushViewController(updatePasswordVc, animated: true)

            }

        }) { (error) in
            
            CommonClass.stopLoader()
        }
    }
}

// MARK: Text field delegate life cycle methods
//MARK:- =================================================


extension OTPViewController: UITextFieldDelegate {
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField == self.firstDigitTextField)
        {
            if (range.length == 0)
            {
                textField.text = string
                self.secondDigitTextField.becomeFirstResponder()
            }
            else
            {
                textField.text = "\u{200B}"
            }
        }
        else if (textField == self.secondDigitTextField)
        {
            if (range.length == 0)
            {
                textField.text = string
                self.thirdDigitTextField.becomeFirstResponder()
            }
            else
            {
                textField.text = "\u{200B}"
                self.firstDigitTextField.becomeFirstResponder()
            }
        }
        else if (textField == self.thirdDigitTextField)
        {
            if (range.length == 0)
            {
                textField.text = string
                self.fourthDigitTextField.becomeFirstResponder()
            }
            else
            {
                textField.text = "\u{200B}"
                self.secondDigitTextField.becomeFirstResponder()
            }
        }
        else if (textField == self.fourthDigitTextField)
        {
            if (range.length == 0)
            {
                textField.text = string
                textField.resignFirstResponder()
            }
            else
            {
                textField.text = "\u{200B}"
                self.thirdDigitTextField.becomeFirstResponder()
            }
        }
        
        return false
    }
}
