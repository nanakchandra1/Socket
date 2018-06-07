//
//  ChangePasswordViewController.swift
//  ChangePasswordScreen
//
//  Created by Aakash Srivastav on 10/4/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    // MARK: IBOutlets
    //MARK:- =================================================
    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var navigationTitle: UILabel!

    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var changePasswordTableView: UITableView!
    
    // MARK: Constants
    //MARK:- =================================================

    let fieldArray = ["Current Password", "New Password", "Confirm New Password"]
    
    // MARK: Variables
    //MARK:- =================================================

    var userDetailsDict = [String: String]()
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialSetup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }

    // MARK: IBActions
    //MARK:- =================================================

    @IBAction func changePasswordBtnTapped(_ sender: UIButton) {
        
        if self.isAllFieldsVerified() {
            
            var params = JSONDictionary()
            
            params["old_password"] = self.userDetailsDict["Current Password"] 
            params["new_password"] = self.userDetailsDict["New Password"]
            params["confirm_password"] = self.userDetailsDict["Confirm New Password"]
            params["action"] = "change"
            CommonClass.startLoader("")
            
            ServiceController.updatePasswordApi(params, SuccessBlock: { (success,json) in
            
                CommonClass.stopLoader()

                if success{
                    
                self.navigationController?.popViewController(animated: true)
                    
                }
                
            }) { (error) in
                
                CommonClass.stopLoader()
            }
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Private Methods
    //MARK:- =================================================

    func initialSetup() {
        
        self.changePasswordTableView.dataSource = self
        self.changePasswordTableView.delegate = self
        self.changePasswordTableView.isScrollEnabled = false
        
        self.changePasswordTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.view.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    
    func isAllFieldsVerified() -> Bool {
        
        if (self.userDetailsDict["Current Password"] == nil) || (self.userDetailsDict["Current Password"] ?? "").isEmpty {
            
            showToastWithMessage(ChangePasswordStrings.currentPass)
            return false
            
        } else if self.userDetailsDict["Current Password"]!.characters.count < 7 {
            
            showToastWithMessage(ChangePasswordStrings.passMinLength)
            return false
            
        } else if self.userDetailsDict["Current Password"]!.characters.count > 32 {
            
            showToastWithMessage(ChangePasswordStrings.passMaxLength)
            return false
            
        } else if (self.userDetailsDict["New Password"] == nil) || self.userDetailsDict["New Password"]!.isEmpty {
            
            showToastWithMessage(ChangePasswordStrings.newPass)
            return false
            
        } else if self.userDetailsDict["New Password"]!.characters.count < 7 {
            
            showToastWithMessage(ChangePasswordStrings.passMinLength)
            return false
            
        } else if self.userDetailsDict["New Password"]!.characters.count > 32 {
            
            showToastWithMessage(ChangePasswordStrings.passMaxLength)
            return false
            
        } else if (self.userDetailsDict["Confirm New Password"] == nil) || self.userDetailsDict["Confirm New Password"]!.isEmpty {
            
            showToastWithMessage(ChangePasswordStrings.confirmPass)
            return false
            
        } else if self.userDetailsDict["Confirm New Password"] != self.userDetailsDict["New Password"] {
            
            showToastWithMessage(ChangePasswordStrings.newPass_confirmPass_NotMatch)
            return false
            
        } else if self.userDetailsDict["Confirm New Password"] == self.userDetailsDict["Current Password"] {
            
            showToastWithMessage(ChangePasswordStrings.currentPass_confirmPass_NotMatch)
            return false
            
        }
        return true
    }
}

// MARK: TableView dataSource and Delegate Life Cycle Methods
//MARK:- =================================================

extension ChangePasswordViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChangePasswordTableViewCell", for: indexPath) as! ChangePasswordTableViewCell
        
        cell.populateCell(withLabel: self.fieldArray[indexPath.row], withText: self.userDetailsDict[self.fieldArray[indexPath.row]] ?? "")
        
        cell.changePasswordTextField.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return IsIPad ? 100:75
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return IsIPad ? 100:75
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = UIColor.white
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
}

// MARK: TextField Delegate Life Cycle Methods
//MARK:- =================================================

extension ChangePasswordViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        
        let cell = textField.superview?.superview as! ChangePasswordTableViewCell
        let indexPath = self.changePasswordTableView.indexPath(for: cell)!
        
        let userEnteredString = textField.text
        let newString = (userEnteredString! as NSString).replacingCharacters(in: range, with: string) as NSString
        
        switch self.fieldArray[indexPath.row] {
            
        case "Current Password":
            self.userDetailsDict[self.fieldArray[indexPath.row]] = String(newString)
            
        case "New Password":
            self.userDetailsDict[self.fieldArray[indexPath.row]] = String(newString)
            
        case "Confirm New Password":
            self.userDetailsDict[self.fieldArray[indexPath.row]] = String(newString)
            
        default:
            break
        }
        
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 25
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let cell = textField.superview?.superview as? ChangePasswordTableViewCell else { return true }
        let indexPath = self.changePasswordTableView.indexPath(for: cell)!
        
        if textField.returnKeyType == UIReturnKeyType.next {
            
            if let nextCell = self.changePasswordTableView.cellForRow(at: IndexPath(row: indexPath.row+1, section: indexPath.section)) as? ChangePasswordTableViewCell {
                
               nextCell.changePasswordTextField.becomeFirstResponder()
            }
            
        } else {
            
            textField.resignFirstResponder()
            
        }
        return true
    }
}

//MARK:- tableview cell classess
//MARK:- =================================================

class ChangePasswordTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var changePasswordLabel: UILabel!
    @IBOutlet weak var changePasswordTextField: UITextField!
    
    // MARK: Table View Cell Life Cycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.changePasswordTextField.layer.cornerRadius = IsIPad ? 5:3
        self.changePasswordTextField.layer.borderColor = UIColor.black.cgColor
        self.changePasswordTextField.layer.borderWidth = 1
        self.changePasswordTextField.isSecureTextEntry = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.changePasswordLabel.text = nil
        self.changePasswordTextField.text = nil
    }
    
    // MARK: Private Methods
    func populateCell(withLabel labelText: String, withText text: String) {
        
        if labelText == "Confirm New Password" {
            self.changePasswordTextField.returnKeyType = .done
        } else {
            self.changePasswordTextField.returnKeyType = .next
        }
        
        self.changePasswordLabel.text = labelText
        self.changePasswordTextField.text = text
    }
}
