//
//  ViewController.swift
//  DriverApp
//
//  Created by Saurabh Shukla on 9/6/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import MFSideMenu
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class LoginViewController: BaseViewController {
    
    //MARK:IBOutlets
    //MARK:- =================================================
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet var showPassBtn: UIButton!
    
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        
        if isIPhoneSimulator {
        
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.loginBtn.layer.cornerRadius = self.loginBtn.bounds.height / 2
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.emailTextField.text = nil
        self.passwordTextField.text = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: Private Methods
    //MARK:- =================================================
    
    
    func initialSetup() {
        
        // Setting Attributed placeholder to textfields
        
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email Address".localized, attributes:[NSForegroundColorAttributeName: UIColor.white])
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password".localized, attributes:[NSForegroundColorAttributeName: UIColor.white])
        self.loginBtn.layer.borderWidth = 1
        self.loginBtn.layer.borderColor = UIColor(red: 59/255, green: 19/255, blue: 73/255, alpha: 1).cgColor
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    func isAllFieldsVerified() -> Bool {
        
        if (self.emailTextField.text == nil || self.emailTextField.text!.isEmpty) && (self.passwordTextField.text == nil || self.passwordTextField.text!.isEmpty) {
            
            showToastWithMessage(LoginPageStrings.enterCredentials)
            
            return false
            
        } else if (self.emailTextField.text == nil) || self.emailTextField.text!.isEmpty{
            
            showToastWithMessage(LoginPageStrings.enterEmail)
            
            return false
            
        } else if !isValidEmail(self.self.emailTextField.text!) {
            
            showToastWithMessage(LoginPageStrings.enterValidEmail)
            
            return false
            
        } else if (self.passwordTextField.text == nil || self.passwordTextField.text!.isEmpty) {
            
            showToastWithMessage(LoginPageStrings.enetrPass)
            
            return false
            
        } else if self.passwordTextField.text?.characters.count < 7 {
            
            showToastWithMessage(ChangePasswordStrings.passMinLength)
            
            return false
            
        } else if self.passwordTextField.text?.characters.count > 32 {
            
            showToastWithMessage(ChangePasswordStrings.passMaxLength)
            
            return false
        }
        
        return true
    }
    
    
    // MARK: IBActions
    //MARK:- =================================================
    
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    @IBAction func showPassTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected{
            self.passwordTextField.isSecureTextEntry = false
            
        }
        else{
            self.passwordTextField.isSecureTextEntry = true
        }
        
    }
    
    
    @IBAction func loginBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if self.isAllFieldsVerified() {
            
            var params = JSONDictionary()
            
            //params["action"] = "login"
            params["email"] = self.emailTextField.text!
            params["password"] = self.passwordTextField.text!
            params["device_id"] = DeviceUUID
            params["device_token"] = APPDELEGATEOBJECT.device_Token
            params["device_model"] = DeviceModelName
            params["platform"] = OS_PLATEFORM
            params["os_version"] = SystemVersion_String
            
            CommonClass.startLoader("")
            print_debug(params)
            ServiceController.loginApi(params, SuccessBlock: { (success,json) in
                
                CommonClass.stopLoader()
                
                let code = json["statusCode"].int ?? 0
                let message = json["message"].stringValue
                let result = json["result"]
                let vehicles = result["vehicles"].array ?? []
                
                let userDetail = UserInfoModel(json: json)
                
                userdata.saveJSONDataToUserDefault(result)
                
                    if code == 200 {
                    
                        guard !vehicles.isEmpty else{
                            
                            let obj = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "AddVehicleViewController") as! AddVehicleViewController
                            self.navigationController?.pushViewController(obj, animated: true)

                            return
                        }
                        
                        UserDefaults.save(true as AnyObject, forKey: NSUserDefaultsKeys.ISUSERLOGGEDIN)
                        UserDefaults.removeFromUserDefaultForKey(NSUserDefaultsKeys.SOCIAL_ID)
                        CommonClass.reconnectSocket()

                        CommonClass.gotoLandingPage()
                        
                    }else if code == 219{
                        
                        showToastWithMessage(message)
                        let vc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "MobileVerificationViewController") as! MobileVerificationViewController
                        vc.email = userDetail.email!
                        vc.mobileNumberText = userDetail.phone!
                        vc.code = userDetail.country_code!
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    }else{
                        
                        showToastWithMessage(message)
                        
                    }
            }) { (error: Error) in
                printlnDebug(error)
                CommonClass.stopLoader()
            }
        }
    }
    
    
    @IBAction func forgotPasswordBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        let vc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}


//MARK:- Textfield delegate
//MARK:- =================================================


extension LoginViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.passwordTextField{
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 25
        }else{
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == UIReturnKeyType.next {
            
            self.passwordTextField.becomeFirstResponder()
            
        } else {
            
            textField.resignFirstResponder()
            
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField === self.emailTextField {
            
            self.emailTextField.text = self.emailTextField.text!
            self.emailTextField.text = self.emailTextField.text!
        } else {
            
            self.passwordTextField.text = self.passwordTextField.text!
        }
    }
}

