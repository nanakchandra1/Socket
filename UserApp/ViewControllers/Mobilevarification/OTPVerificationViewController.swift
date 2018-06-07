//
//  OTPVerificationViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/8/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import MFSideMenu

protocol ClearTextFieldDelegate: class {
    func clearTextFeild()
}

class OTPVerificationViewController: UIViewController {
    
    // MARK: Variables
    //MARK:- =================================================

    var OTP = ""
    var mobileNumberText = ""
    var emailStr = ""
    var code = ""
    var mobileNumberState = MobileNumberState.normal
    weak var delegate: ClearTextFieldDelegate?
    
    // MARK: IBOutlets
    //MARK:- =================================================

    
    @IBOutlet weak var phoneImageView: UIImageView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var enterVarificationCodeLbl: UILabel!
    
    @IBOutlet weak var firstDigitTextField: UITextField!
    @IBOutlet weak var secondDigitTextField: UITextField!
    @IBOutlet weak var thirdDigitTextField: UITextField!
    @IBOutlet weak var fourthDigitTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var resendOTPBtn: UIButton!
    @IBOutlet weak var changeMobileNumberBtn: UIButton!
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialSetup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // showToastWithMessage("Your OTP is: \(self.OTP)")
                    self.firstDigitTextField.text = ""
                    self.secondDigitTextField.text = ""
                    self.thirdDigitTextField.text = ""
                    self.fourthDigitTextField.text = ""

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.firstDigitTextField.text = "\u{200B}"
        self.secondDigitTextField.text = "\u{200B}"
        self.thirdDigitTextField.text = "\u{200B}"
        self.fourthDigitTextField.text = "\u{200B}"
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private Methods
    //MARK:- =================================================

    
    func initialSetup () {
        
        let textFieldCornerRadius: CGFloat = IsIPad ? 5:3
        let btnCornerRadius: CGFloat = (IsIPad ? 70:45)/2
        
        // Customising buttons
        self.resendOTPBtn.layer.cornerRadius = btnCornerRadius
        self.resendOTPBtn.layer.borderWidth = 1
        self.resendOTPBtn.layer.borderColor = UIColor(red: 187/255, green: 103/255, blue: 327/255, alpha: 0.33).cgColor
        
        self.changeMobileNumberBtn.layer.cornerRadius = btnCornerRadius
        self.changeMobileNumberBtn.layer.borderWidth = 1
        self.changeMobileNumberBtn.layer.borderColor = UIColor(red: 187/255, green: 103/255, blue: 327/255, alpha: 0.33).cgColor
        
        self.firstDigitTextField.delegate = self
        self.secondDigitTextField.delegate = self
        self.thirdDigitTextField.delegate = self
        self.fourthDigitTextField.delegate = self
        
        self.firstDigitTextField.layer.cornerRadius = textFieldCornerRadius
        self.secondDigitTextField.layer.cornerRadius = textFieldCornerRadius
        self.thirdDigitTextField.layer.cornerRadius = textFieldCornerRadius
        self.fourthDigitTextField.layer.cornerRadius = textFieldCornerRadius
        
        self.scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.view.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    
    func verifyOTPAction() {
        
        self.OTP = (self.firstDigitTextField.text ?? "") + (self.secondDigitTextField.text ?? "") + (self.thirdDigitTextField.text ?? "") + (self.fourthDigitTextField.text ?? "")
        
        if self.OTP.characters.count>=4 {
            
            self.verifyOTP()
        }
    }
    
    // Check is all field details are valid
    func isAllFieldsVerified() -> Bool {
        
        if self.OTP.isEmpty {
            
            showToastWithMessage(LoginPageStrings.eneter_otp)
            return false
            
        } else if self.OTP.characters.count < 4 {
            
            showToastWithMessage(LoginPageStrings.enetr_valid_otp)
            return false
        }
        
        return true
    }
    
    // MARK: IBActions
    
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
//        guard self.navigationController != nil, let viewControllers = self.navigationController?.viewControllers else { return }
//        
//        for viewController in viewControllers {
//            
//            if viewController.isKindOfClass(LoginWithMediaVC) {
//                
//                self.navigationController?.popToViewController(viewController, animated: true)
//            }
//        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func resendOTPBtnTapped(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        self.resendOTPAction()
    }
    
    @IBAction func changeMobileNumberBtnTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        
//        print(userDefaultsForKey(NSUserDefaultKey.UserInfoDict))
//        
//        if isAllFieldsVerified() {
//           
//            if let userInfoDict = userDefaultsForKey(NSUserDefaultKey.UserInfoDict) as? [String:AnyObject]{
//                
//                if let code = userInfoDict["code"]{
//                    
//                    if "\(code)" == "219"{
//                        let obj = self.storyboard?.instantiateViewControllerWithIdentifier("MobileVerificationViewController") as! MobileVerificationViewController
//                        self.navigationController?.pushViewController(obj, animated: true)
//                    }
//                    else{
//                        self.navigationController?.popViewControllerAnimated(true)
//                    }
//                }
//            }
//        }
        
        self.delegate?.clearTextFeild()
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Web APIs
    func resendOTPAction() {
        
        self.firstDigitTextField.text = "\u{200B}"
        self.secondDigitTextField.text = "\u{200B}"
        self.thirdDigitTextField.text = "\u{200B}"
        self.fourthDigitTextField.text = "\u{200B}"
        
        guard CommonClass.isConnectedToNetwork else{
            return
        }
        CommonClass.startLoader("")
        var params = [String:AnyObject]()
        
        if CurrentUser.email != nil &&  CurrentUser.mobile != nil && CurrentUser.country_code != nil{
            
            params["email"] = CurrentUser.email! as AnyObject
            params["phone"] = CurrentUser.mobile! as AnyObject
            params["country_code"] = CurrentUser.country_code! as AnyObject
            
        }
        else{
            
            params["email"] = self.emailStr as AnyObject
            params["phone"] = self.mobileNumberText as AnyObject
            params["country_code"] = self.code as AnyObject
            
        }
        
        
        params["action"] = "email" as AnyObject
        
        
        ServiceController.sendOTPApi(params, SuccessBlock: { (success,json) in
            CommonClass.stopLoader()
            
        }, failureBlock: { (error) in
            CommonClass.stopLoader()
        })
        
    }

    func verifyOTP() {
        
        guard CommonClass.isConnectedToNetwork else{
            return
        }
        CommonClass.startLoader("")
        var params = [String:AnyObject]()
        
            //printlnDebug(CurrentUser.userData!)
        
        params["action"] = "email" as AnyObject
        params["otp"] = self.OTP as AnyObject
        
        if self.emailStr != "" && self.mobileNumberText != "" && self.code != ""{
            
            params["email"] = self.emailStr as AnyObject
            params["phone"] = self.mobileNumberText as AnyObject
            params["country_code"] = self.code as AnyObject
            
        }else if CurrentUser.email != nil &&  CurrentUser.mobile != nil && CurrentUser.country_code != nil{
            
            params["email"] = CurrentUser.email! as AnyObject
            params["phone"] = CurrentUser.mobile! as AnyObject
            params["country_code"] = CurrentUser.country_code! as AnyObject
            
        }

        printlnDebug(params)
        
        ServiceController.verifyOTPApi(params, SuccessBlock: { (success,json) in
            
            printlnDebug(json)

            if success{
                
            CommonClass.stopLoader()
            
                let result = json["result"]
                userdata.saveJSONDataToUserDefault(result)

            if self.mobileNumberState == MobileNumberState.normal{
            
                
                if CurrentUser.isVehicle{
                    
                    
                    UserDefaults.save(true as AnyObject, forKey: NSUserDefaultsKeys.ISUSERLOGGEDIN)
                    
                        CommonClass.gotoLandingPage()
                        
                    }else{
                        
                        let obj = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "AddVehicleViewController") as! AddVehicleViewController
                        self.navigationController?.pushViewController(obj, animated: true)

                    }
                    
                } else {
                    
                    let obj = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "AddVehicleViewController") as! AddVehicleViewController
                    self.navigationController?.pushViewController(obj, animated: true)
                }
            
            }
            else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }) { (error) in
                printlnDebug(error)
        }
        
    }
    

    
}

// MARK: Text field delegate life cycle methods
//MARK:- =================================================


extension OTPVerificationViewController: UITextFieldDelegate {
    
    
    
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
                self.verifyOTPAction()
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
