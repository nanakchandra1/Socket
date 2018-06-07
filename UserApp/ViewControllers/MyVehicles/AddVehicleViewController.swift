//
//  AddVehicleViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/27/16.
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


enum AddVehicleState {
    case login,myVehicle
}

class AddVehicleViewController: UIViewController {
    
    // MARK: Enums
    //MARK:- =================================================

    enum VehicleType: Int {
        
        case car
        case bike
        
        var description: String {
            switch self {
            case .car: return "Car"
            case .bike   : return "Bike"
            }
        }
    }
    
    // MARK: IBOutlets
    //MARK:- =================================================
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var vehicleTableView: UITableView!
    @IBOutlet weak var vehicleTableViewTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var addVehicleView: UIView!
    @IBOutlet weak var pickerBgView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    // MARK: Constants
    let placeholderArray = ["Vehicle Model", "Vehicle Type", "Vehicle Number", "Description"]
    
    // MARK:- Variables
    //MARK:- =================================================

    lazy var toolbarView = UIToolbar()
    var allVehiclesDetail = JSONDictionaryArray()
    var vehicleDetailDict = [String: String]()
    var addvehicleState = VehicleAddState.new
    var editedVehicleDetail = JSONDictionary()
    var index:Int!
    var sender = AddVehicleState.login
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bottomConstraint.constant = -150
        self.initialSetup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.sender == .myVehicle {
            
            self.addVehicleView.isHidden = true
            self.vehicleTableViewTopLayoutConstraint.constant = 0
            self.view.layoutIfNeeded()
            
        } else {
            
            self.addVehicleView.isHidden = false
            self.vehicleTableViewTopLayoutConstraint.constant = (IsIPad ? 60:80)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.addvehicleState == VehicleAddState.add{
            mfSideMenuContainerViewController.panMode = MFSideMenuPanModeNone

            self.nextBtn.setTitle("Save", for: UIControlState())
            self.nextBtn.backgroundColor = UIColor(red: 48 / 255, green: 120 / 255, blue: 67 / 255, alpha: 1)
            self.bgImageView.backgroundColor = UIColor(red: 18 / 255, green: 18 / 255, blue: 18 / 255, alpha: 1)
            self.backBtn.setImage(UIImage(named: "forgot_password_back_arrow"), for: UIControlState())
        }
        else if self.addvehicleState == VehicleAddState.edit{
            mfSideMenuContainerViewController.panMode = MFSideMenuPanModeNone

            self.nextBtn.setTitle("Update", for: UIControlState())
            self.nextBtn.backgroundColor = UIColor(red: 48 / 255, green: 120 / 255, blue: 67 / 255, alpha: 1)
            self.bgImageView.backgroundColor = UIColor(red: 18 / 255, green: 18 / 255, blue: 18 / 255, alpha: 1)
            self.backBtn.setImage(UIImage(named: "forgot_password_back_arrow"), for: UIControlState())
        }
        else{
            self.nextBtn.setTitle("Next", for: UIControlState())
            self.bgImageView.image = UIImage(named: "splash_bg")
        }

        
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
        if CurrentUser.token != nil && CurrentUser.full_name != nil && CurrentUser.isLoggedIn {

            mfSideMenuContainerViewController.panMode = MFSideMenuPanModeDefault
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        
        let selectedRow = self.pickerView.selectedRow(inComponent: 0)
        
        self.vehicleDetailDict["Vehicle Type"] = VehicleType(rawValue: selectedRow)!.description
        
        self.vehicleTableView.reloadRows(at: [IndexPath(row: 1, section: 0 )], with: .none)
        

        UIView.animate(withDuration: 1, animations: {
            self.bottomConstraint.constant = -150
            }, completion: { (true) in
        })
        
    }
    
    
    @IBAction func pickerViewCancelBtnTapped(_ sender: UIButton) {
        
        UIView.animate(withDuration: 1, animations: {
            self.bottomConstraint.constant = -150
            }, completion: { (true) in
        })
        
    }
    
    
    // MARK:- Private methods
    //MARK:- =================================================

    func dismissKeyboard(_ sender: AnyObject)
    {
        self.view.endEditing(true)
    }
    
    func initialSetup() {
        
        self.vehicleTableView.dataSource = self
        self.vehicleTableView.delegate = self
        self.vehicleTableView.estimatedRowHeight = 80
        
        self.vehicleTableView.register(UINib(nibName: "VehicleTableViewCell", bundle: nil), forCellReuseIdentifier: "VehicleTableViewCell")
        self.vehicleTableView.register(UINib(nibName: "VehicleDescriptionTableViewCell", bundle: nil), forCellReuseIdentifier: "VehicleDescriptionTableViewCell")
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        
        // Customising toolbar and pickerView
        self.toolbarView = UIToolbar()
        self.toolbarView.backgroundColor = UIColor.white
        
        self.pickerView.backgroundColor = UIColor.white
        
        
        if !self.allVehiclesDetail.isEmpty{
            
            if let no = self.allVehiclesDetail[index]["no"] as? String,let type = self.allVehiclesDetail[index]["type"] as? String,let model = self.allVehiclesDetail[index]["model"] as? String{
                
                
                let desc = self.allVehiclesDetail[index]["desc"] as? String
                printlnDebug(index)
                
                self.vehicleDetailDict["Vehicle Number"] = no
                self.vehicleDetailDict["Vehicle Type"] = type.lowercased()
                self.vehicleDetailDict["Vehicle Model"] = model
                self.vehicleDetailDict["Description"] = desc ?? ""
                self.vehicleTableView.reloadData()
                self.allVehiclesDetail.remove(at: index)
            }
        }
    }
    
    
    func getJsonObject(_ Detail: AnyObject) -> String{
        var data = Data()
        do {
            data = try JSONSerialization.data(
                withJSONObject: Detail ,
                options: JSONSerialization.WritingOptions(rawValue: 0))
        }
        catch{
        }
        let paramData = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        return paramData
    }
    
    
    // MARK:- IBActions
    //MARK:- =================================================

    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnTapped(_ sender: UIButton) {
        
        if self.vehicleDetailDict["Vehicle Model"]?.characters.count < 1{
            showToastWithMessage(VehicleRelatedString.vehicleModel)
            return
        }
        if self.vehicleDetailDict["Vehicle Type"]?.characters.count < 1{
            showToastWithMessage(VehicleRelatedString.vehicleType)
            return
        }
        if self.vehicleDetailDict["Vehicle Number"]?.characters.count < 1{
            showToastWithMessage(VehicleRelatedString.vehicleNo)
            return
        }
        
        CommonClass.startLoader("")
        
        var params = JSONDictionary()
        
        params["action"] = "add"
        params["vehicle_name"] = "Vehicle Name"
        params["vehicle_type"] = self.vehicleDetailDict["Vehicle Type"]!.lowercased()
        params["vehicle_no"] = self.vehicleDetailDict["Vehicle Number"]!
        params["vehicle_model"] = self.vehicleDetailDict["Vehicle Model"]!
        
        if let description = self.vehicleDetailDict["Description"]{
         
            params["vehicle_desc"] = description
            
        }
        
        printlnDebug(params)
        
        if self.addvehicleState == VehicleAddState.new{
            
            ServiceController.add_update_VehicleApi(params, SuccessBlock: { (success,json) in
                CommonClass.stopLoader()
                
                if success{
                    
                    UserDefaults.save(true , forKey: NSUserDefaultsKeys.ISUSERLOGGEDIN)
                    UserDefaults.save("y" , forKey: NSUserDefaultsKeys.VEHICLES)
                    CommonClass.reconnectSocket()

                    CommonClass.gotoLandingPage()

                }
                
            }) { (error) in
                CommonClass.stopLoader()
                printlnDebug(error)
            }
        }
        else if self.addvehicleState == VehicleAddState.add{
            
            ServiceController.update_remove_VehicleApi(params, SuccessBlock: { (success,json) in

                CommonClass.stopLoader()
                
                if success{
                    
                    showToastWithMessage(VehicleRelatedString.vehicleAdded)
                    self.navigationController?.popViewController(animated: true)

                }
                }, failureBlock: { (error) in
                    
                    CommonClass.stopLoader()
                    printlnDebug(error)
            })
        }
        else{
            var temp_params = JSONDictionary()
            var param = JSONDictionary()
            isvehecleAdd = true
            sdeletedVehicle = self.index

            temp_params["name"] = "HardCoded Vehicle Name"
            temp_params["type"] = self.vehicleDetailDict["Vehicle Type"]!.lowercased()
            temp_params["no"] = self.vehicleDetailDict["Vehicle Number"]!
            temp_params["model"] = self.vehicleDetailDict["Vehicle Model"]!
            
            if let description = self.vehicleDetailDict["Description"]{
                
                temp_params["desc"] = description
            }
            
            printlnDebug(temp_params)
            
            self.allVehiclesDetail.insert(temp_params, at: self.index)
            
            param["action"] = "edit"
            param["vehicles"] = self.getJsonObject(self.allVehiclesDetail as AnyObject)
            
            ServiceController.update_remove_VehicleApi(param, SuccessBlock: { (success,json) in
                CommonClass.stopLoader()
                
                if success{
                    
                    showToastWithMessage("Vehicle Edited")
                    self.navigationController?.popViewController(animated: true)

                }
                
                }, failureBlock: { (error) in
                    
                    CommonClass.stopLoader()
            })
        }
    }
}

// MARK:- TableView Datasource Life Cycle Methods
//MARK:- =================================================

extension AddVehicleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 3 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleDescriptionTableViewCell", for: indexPath) as! VehicleDescriptionTableViewCell
            
            cell.populateCell(withVehicleDict: self.vehicleDetailDict)
            cell.vehicleDescriptionTextView.delegate = self
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleTableViewCell", for: indexPath) as! VehicleTableViewCell
            cell.openPickerBtn.addTarget(self, action: #selector(self.onTapTextField(_:)), for: UIControlEvents.touchUpInside)
            cell.populateCell(withPlaceholderText: self.placeholderArray[indexPath.row], withVehicleDict: self.vehicleDetailDict)
            cell.vehicleDetailTextField.delegate = self
            
            if indexPath.row == 1{
                cell.openPickerBtn.isHidden = false
            }else{
                cell.openPickerBtn.isHidden = true

            }
            return cell
        }
    }
    
    func onTapTextField(_ sender: UIButton){
        self.view.endEditing(true)

        UIView.animate(withDuration: 1, animations: {
            self.bottomConstraint.constant = 0
            }, completion: { (true) in
        })

    }
    
}

// MARK:- TableView Delegate Life Cycle Methods
//MARK:- =================================================

extension AddVehicleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 3 {
            
            return IsIPad ? 160:120
        }
        return IsIPad ? 80:60
    }
}

// MARK:- TextField Delegate Life Cycle Methods
//MARK:- =================================================

extension AddVehicleViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let cell = textField.superview?.superview as! VehicleTableViewCell
        let indexPath = self.vehicleTableView.indexPath(for: cell)
        
        if indexPath?.row != 1 {
            
            UIView.animate(withDuration: 1, animations: {
                self.bottomConstraint.constant = -150
                }, completion: { (true) in
            })
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        
        let cell = textField.superview?.superview as! VehicleTableViewCell
        let indexPath = self.vehicleTableView.indexPath(for: cell)!
        
        let userEnteredString = textField.text
        
        let newString = (userEnteredString! as NSString).replacingCharacters(in: range, with: string) as NSString
        
        switch self.placeholderArray[indexPath.row] {
            
        case "Vehicle Name":
            self.vehicleDetailDict["Vehicle Name"] = String(newString)
            
        case "Vehicle Number":
            self.vehicleDetailDict["Vehicle Number"] = String(newString)
            
        case "Vehicle Model":
            self.vehicleDetailDict["Vehicle Model"] = String(newString)
            
        default:
            break
        }
        
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 25
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let cell = textField.superview?.superview as? VehicleTableViewCell else { return true }
        let indexPath = self.vehicleTableView.indexPath(for: cell)!
        
        if (textField.returnKeyType == UIReturnKeyType.next) && (indexPath.row != 2) {
            
            if let nextCell = self.vehicleTableView.cellForRow(at: IndexPath(row: indexPath.row+1, section: indexPath.section)) as? VehicleTableViewCell {
                
                nextCell.vehicleDetailTextField.becomeFirstResponder()
            }
            
        } else {
            
            if let nextCell = self.vehicleTableView.cellForRow(at: IndexPath(row: indexPath.row+1, section: indexPath.section)) as? VehicleDescriptionTableViewCell {
                
                nextCell.vehicleDescriptionTextView.becomeFirstResponder()
                return false
            }
            
        }
        return true
    }
    
}

// MARK:- TextView Delegate Life Cycle Methods
//MARK:- =================================================

extension AddVehicleViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 1, animations: {
            self.bottomConstraint.constant = -150
            }, completion: { (true) in
        })
        if textView.font == UIFont(name: "SFUIDisplay-Light", size: (IsIPad ? 20:11.5)) {
            
            textView.text = ""
            textView.font = UIFont(name: "SFUIDisplay-Regular", size: (IsIPad ? 20:11.5))
        }
    }
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if range.location == 0 && text == " " {
            
            return false
        }
        
        let userEnteredString = textView.text
        
        let newString = (userEnteredString! as NSString).replacingCharacters(in: range, with: text) as NSString
        
        self.vehicleDetailDict["Description"] = String(newString)
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == nil || textView.text!.isEmpty {
            
            //self.vehicleDetailDict["Description"] = nil
            textView.font = UIFont(name: "SFUIDisplay-Light", size: (IsIPad ? 20:11.5))
            self.vehicleTableView.reloadRows(at: [IndexPath(row: 3, section: 0 )], with: .none)
        }
    }
}

// MARK:- UIPickerView DataSource Methods
//MARK:- =================================================

extension AddVehicleViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return VehicleType(rawValue: row)?.description
        
    }
    
}

// MARK:- UIPickerView delegate Methods
//MARK:- =================================================

extension AddVehicleViewController: UIPickerViewDelegate {
    
    
}
