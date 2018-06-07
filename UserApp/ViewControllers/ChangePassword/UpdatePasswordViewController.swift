//
//  UpdatePasswordViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/8/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import IQKeyboardManager

class UpdatePasswordViewController: UIViewController {
    
    
    // MARK: IBOutlets
    //MARK:- =================================================
    
    @IBOutlet weak var dontWorryLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var newPassLbl: UILabel!
    @IBOutlet weak var confirmPassLbl: UILabel!

    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    
    @IBOutlet weak var firstDotView: UIView!
    @IBOutlet weak var centerDotView: UIView!
    @IBOutlet weak var bgViewCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var lastDotView: UIView!

    // MARK: Variables
    var mobileNumberText:String!
    var code:String!
    
    
    // MARK: view life cycle
    //MARK:- ******************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initialSetup()
        
        self.newPasswordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: Methods
    //MARK:- ******************************************************************
    
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

    
    func initialSetup() {
        
        let cornerRadius: CGFloat = IsIPad ? 5:3.5
        let slope: CGFloat = IsIPad ? 70:50
        
        // Customising buttons and label
        self.updateBtn.layer.cornerRadius = cornerRadius
        
        self.newPasswordTextField.layer.cornerRadius = cornerRadius
        self.newPasswordTextField.layer.borderColor = UIColor.lightGray.cgColor
        self.newPasswordTextField.layer.borderWidth = 1.5
        
        self.confirmPasswordTextField.layer.cornerRadius = cornerRadius
        self.confirmPasswordTextField.layer.borderColor = UIColor.lightGray.cgColor
        self.confirmPasswordTextField.layer.borderWidth = 1.5
        
        // Drawing traingle for slant View
        self.cancelBtn.addSlope(withColor: UIColor.gray, ofWidth: slope, ofHeight: slope)
        if self.cancelBtn.imageView != nil {
            
            self.cancelBtn.bringSubview(toFront: self.cancelBtn.imageView!)
        }
        self.cancelBtn.imageEdgeInsets = IsIPad ? UIEdgeInsetsMake(0, 28, 22, 0):UIEdgeInsetsMake(0, 22, 18, 0)
        
        self.firstDotView.layer.cornerRadius = cornerRadius
        self.centerDotView.layer.cornerRadius = cornerRadius
        self.lastDotView.layer.cornerRadius = cornerRadius
    }

    // Check is all field details are valid
    func isAllFieldsVerified() -> Bool {
        
        if (self.newPasswordTextField.text == nil) || self.newPasswordTextField.text!.isEmpty {
            
            showToastWithMessage(ChangePasswordStrings.newPass)
            return false
            
        } else if self.newPasswordTextField.text!.characters.count < 7 {
            
            showToastWithMessage(ChangePasswordStrings.passMinLength)
            return false
            
        } else if (self.confirmPasswordTextField.text == nil) || self.confirmPasswordTextField.text!.isEmpty {
            
            showToastWithMessage(ChangePasswordStrings.confirmPass)
            return false
            
        } else if self.newPasswordTextField.text! != self.confirmPasswordTextField.text! {
            
            showToastWithMessage(ChangePasswordStrings.newPass_confirmPass_NotMatch)
            return false
        }
        
        return true
    }

    // MARK: IBActions
    //MARK:- ******************************************************************
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func updateBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if isAllFieldsVerified() {
            
            // #Warning: Need code for navigation
            self.updatePasswordAction()
        }
    }

    @IBAction func cancelBtnTapped(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: Web APIs
    
    func updatePasswordAction() {
        
        guard CommonClass.isConnectedToNetwork else{
            return
        }
        
        CommonClass.startLoader("")
        
        var params = [String: AnyObject]()
        
        params["action"] = "reset" as AnyObject
        params["new_password"] = self.newPasswordTextField.text! as AnyObject
        params["confirm_password"] = self.newPasswordTextField.text! as AnyObject
        params["mobile"] = self.code + self.mobileNumberText as AnyObject
        
        ServiceController.updatePasswordApi(params, SuccessBlock: { (success,json) in
            CommonClass.stopLoader()
            
            if success{
            
                UserDefaults.clearUserDefaults()
                
                
                guard self.navigationController != nil, let viewControllers = self.navigationController?.viewControllers else { return }
                
                for viewController in viewControllers {
                    
                    if viewController.isKind(of: LoginViewController.self) {
                        
                        self.navigationController?.popToViewController(viewController, animated: true)
                    }
                }

            }
            
        }) { (error) in
            
            CommonClass.stopLoader()
        }
    }

}

// MARK: Text Field Delegate Life Cycle Methods


extension UpdatePasswordViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
         let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 25
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == UIReturnKeyType.next {
            
            self.confirmPasswordTextField.becomeFirstResponder()
            
        } else {
            
            textField.resignFirstResponder()
            
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField === self.newPasswordTextField {
            
            self.newPasswordTextField.text = self.newPasswordTextField.text!
        
        } else {
            
            self.confirmPasswordTextField.text = self.confirmPasswordTextField.text!
        }
    }
}
