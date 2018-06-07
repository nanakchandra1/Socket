//
//  MobileVerificationViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/8/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class MobileVerificationViewController: UIViewController, ClearTextFieldDelegate {
    
    // MARK: Variables

    var mobileNumberText = ""
    var email = ""
    var code = ""
    var mobileNumberState = MobileNumberState.normal
    
    // MARK: IBOutlets
    //MARK:- =================================================

    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var enterMobileLbl: UILabel!

    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var phoneImageView: UIImageView!
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.countryCodeTextField.attributedPlaceholder = NSAttributedString(string: "Code".localized, attributes:[NSForegroundColorAttributeName: UIColor.white])
        
        self.mobileNumberTextField.attributedPlaceholder = NSAttributedString(string: "Mobile Number".localized, attributes:[NSForegroundColorAttributeName: UIColor.white])
        self.initialSetup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.countryCodeTextField.text = nil
        self.mobileNumberTextField.text = nil
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private Methods
    //MARK:- =================================================

    
    func initialSetup() {
        
        
        self.mobileNumberTextField.text = self.mobileNumberText
        
        self.countryCodeTextField.text = self.code
        
        // Delegating TextFields
        self.countryCodeTextField.delegate = self
        self.mobileNumberTextField.delegate = self
        
        self.countryCodeTextField.addRightImage(withImageNamed: "mobile_verification_down_arrow")
        
        self.submitBtn.layer.cornerRadius = (IsIPad ? 70:45)/2
        self.submitBtn.layer.borderWidth = 1
        self.submitBtn.layer.borderColor = UIColor(red: 187/255, green: 103/255, blue: 327/255, alpha: 0.33).cgColor
        
        self.scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.view.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    
    func isAllFieldsVerifed() -> Bool {
        
        if self.countryCodeTextField.text == nil || self.countryCodeTextField.text!.isEmpty {
            
            showToastWithMessage(ProfileStrings.selectCountryCode)
            return false
            
        }
        else if self.mobileNumberTextField.text == nil || self.mobileNumberTextField.text!.isEmpty {
            
            showToastWithMessage(ProfileStrings.enterMobile)
            return false
            
        }
        else if !isValidPhoneNumber(self.mobileNumberTextField.text!) {
            
            showToastWithMessage(ProfileStrings.validMobile)
            return false
        }
        return true
    }
    
    func clearTextFeild() {
        
        self.mobileNumberTextField.text = ""
        self.countryCodeTextField.text = ""
    }
    
    // MARK: IBActions
    //MARK:- =================================================

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        removeFromUserDefaults(NSUserDefaultKey.UserId)
        removeFromUserDefaults(NSUserDefaultKey.UserInfoDict)
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func submitBtntapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if isAllFieldsVerifed() {
            
            // #Warning: Need code for naviagtion
            self.sendOTPAction()
        }
    }
    
    // MARK: Web APIs
    
    func sendOTPAction() {
        
        guard CommonClass.isConnectedToNetwork else{
            return
        }
        CommonClass.startLoader("")

        if self.mobileNumberState == MobileNumberState.normal{
            
            var params = JSONDictionary()
            
            printlnDebug(self.email)
            
            params["email"] = self.email
            params["action"] = "email"
            params["phone"] = self.mobileNumberTextField.text!
            params["country_code"] = self.countryCodeTextField.text!
            
        ServiceController.sendOTPApi(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()
            
            if success{
                
                let vc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "OTPVerificationViewController") as! OTPVerificationViewController
                
                vc.mobileNumberText = self.mobileNumberTextField.text!
                vc.code = self.countryCodeTextField.text!
                vc.mobileNumberState = self.mobileNumberState
                
                vc.emailStr = self.email
                
                self.navigationController?.pushViewController(vc, animated: true)

            }
            
        }) { (error) in
            
            printlnDebug(error)

        }
            
    }else{
        
            var param = JSONDictionary()
            
            param["action"] = "mobile"
            param["phone"] = self.mobileNumberTextField.text!
            param["country_code"] = self.countryCodeTextField.text!
            
            ServiceController.changeMobileEditProfileApi(param, SuccessBlock: { (success,json) in
                
                CommonClass.stopLoader()
                
                if success{
                
                    
                    let vc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "OTPVerificationViewController") as! OTPVerificationViewController
                    
                    vc.mobileNumberText = self.mobileNumberTextField.text!
                    vc.code = self.countryCodeTextField.text!
                    vc.mobileNumberState = self.mobileNumberState
                    
                    if CurrentUser.email != nil{
                        
                        vc.emailStr = CurrentUser.email!
                    }
                    
                    self.navigationController?.pushViewController(vc, animated: true)

                }

                }, failureBlock: { (error) in
                    CommonClass.stopLoader()
            })
        }
    }
    
}

// MARK: Text Field Delegate Methods
//MARK:- =================================================


extension MobileVerificationViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (textField.becomeFirstResponder())
        {
            //Do your own work on tapping textField.
            if textField === self.countryCodeTextField{
                
                let vc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "CountryListVC") as! CountryListVC
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }

        }
        if textField === self.countryCodeTextField{
            return false
        }
        return true
    }
    
    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        
////        let currentCharacterCount = textField.text?.characters.count ?? 0
////        if (range.length + range.location > currentCharacterCount){
////            return false
////        }
////        
////        let newLength = currentCharacterCount + string.characters.count - range.length
////        return newLength <= 10
//        
//    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField === self.mobileNumberTextField {
            
            self.mobileNumberTextField.text = self.mobileNumberTextField.text!
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == .done {
            
            textField.resignFirstResponder()
        }
        return true
    }
}


// MARK: UIPickerView Delegate  Methods
//MARK:- =================================================


extension MobileVerificationViewController: ShowCountryDetailDelegate {
    
    func getCountryDetails(_ text:String!,countryName:String!,Max_NSN_Length:Int!,Min_NSN_Length:Int!,countryShortName : String!){
        self.countryCodeTextField.text = text
    }
}
