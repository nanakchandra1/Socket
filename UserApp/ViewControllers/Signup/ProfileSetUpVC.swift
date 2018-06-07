//
//  ProfileSetUpVC.swift
//  UserApp
//
//  Created by Appinventiv on 04/10/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
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


class ProfileSetUpVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK:- IBOutlets
    //MARK:- =================================================
    
    
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var signUpTableView: UITableView!
    @IBOutlet weak var datePickerHightConstaints: NSLayoutConstraint!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerDoneBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    //MARK:- Properties
    //MARK:- =================================================
    
    let fieldNameArr = ["Full Name","Email Address","Phone Number","Gender","D-O-B"]
    let fieldImageArr = ["signup_user","signup_email","signup_call","signup_gender","signup_dob"]
    var userEditDataDict = [String:String]()
    var genderState:GenderSelectionState = .none
    var profileImage:UIImage?
    var terms_condition = false
    var userMediaData = JSONDictionary()
    let imagePicker = UIImagePickerController()
    
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    
    override func viewDidLoad() {
        
        print_debug(userEditDataDict)
        super.viewDidLoad()
        self.datePickerHightConstaints.constant = -300
        self.signUpTableView.backgroundColor = UIColor.clear
        self.signUpTableView.delegate = self
        self.signUpTableView.dataSource = self
        self.imagePicker.delegate = self
        self.datePicker.maximumDate = Date()
        self.signUpTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var tapGasture =  UITapGestureRecognizer()
        tapGasture = UITapGestureRecognizer(target: self, action: #selector(SignUpVC.dismissKeyboard(_:)))
        
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.signUpTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK:- IBActions
    //MARK:- =================================================
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func datePickreDoneButtonTapped(_ sender: UIButton) {
        
        
        getDate_of_birth()
        UIView.animate(withDuration: 1, animations: {
            self.datePickerHightConstaints.constant = -300
            }, completion: { (true) in
        })
    }
    
    
    @IBAction func datePickerCancelBtnTapped(_ sender: UIButton) {
        
        UIView.animate(withDuration: 1, animations: {
            self.datePickerHightConstaints.constant = -300
            }, completion: { (true) in
        })
    }
    
    
    
    @IBAction func termsBtnTapped(_ sender: UIButton) {
        let aboutVC = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
        aboutVC.str = "TERMS & CONDITIONS"
        aboutVC.action = "terms-and-conditions"
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
    
    @IBAction func privacyBtnTapped(_ sender: UIButton) {
        let aboutVC = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
        aboutVC.str = "PRIVACY POLICY"
        aboutVC.action = "privacy-policy"
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
    
    func onTapMaleCircle(_ sender: UIButton){
        self.genderState = GenderSelectionState.male
        self.signUpTableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: UITableViewRowAnimation.none)
        
    }
    
    
    func onTapFemaleCircle(_ sender: UIButton){
        self.genderState = GenderSelectionState.female
        self.signUpTableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: UITableViewRowAnimation.none)
    }
    
    
    func codeTextFieldTapped(_ sender: UIButton){
        let vc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "CountryListVC") as! CountryListVC
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    func closeDatePicker() {
        
        UIView.animate(withDuration: 1, animations: {
            self.datePickerHightConstaints.constant = -300
            }, completion: { (true) in
        })
    }

    
    func dobTapped(_ sender: UIButton){
        
        self.view.endEditing(true)
        self.datePicker.datePickerMode = UIDatePickerMode.date
        self.datePickerHightConstaints.constant = 0
    }
    
    func onTapTerm_Condition(_ sender: UIButton){
        
        self.terms_condition = !self.terms_condition
        self.signUpTableView.reloadData()
        
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.view.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    
    func onTapEditImage(_ sender : UIButton){
        
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
        }
        
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    //Pic image from Gallery
    func openCamera(){
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            switch authStatus {
            case .authorized:
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.present(imagePicker, animated: true, completion: nil)
            case .denied, .restricted:
                self.alertToEncourageCameraAccess("Camera")
            case .notDetermined:
                self.requestForCameraAccessPermission()
            }
        }else{
            
            let alert = UIAlertView()
            alert.title = "Camera Unavailable"
            alert.message = "Please check to see if it is disconnected or in use by another application"
            alert.addButton(withTitle: "OK")
            alert.show()
        }
    }
    
    func alertToEncourageCameraAccess(_ service: String) {
        
        let alertController = UIAlertController (title: "", message: "You don't have permission to access the \(service). Please go to device settings and enable the \(service) permissions.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.openURL(url)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        self.present(alertController, animated: true, completion: nil);
        
    }
    
    
    
    func requestForCameraAccessPermission() {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { (granted) in
            if granted {
                self.openCamera()
            } else {
                self.alertToEncourageCameraAccess("Camera")
            }
        }
    }
    
    func openGallery() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = true
            
            self.galleryPermission()
            
        } else{
            let alert = UIAlertView()
            alert.title = "Gallery Unavailable"
            alert.message = "Please check to see if it is in use by another application"
            alert.addButton(withTitle: "OK")
            alert.show()
        }
    }
    
    
    
    //    MARK:- For Gallery Permission
    func galleryPermission() {
        
        let galleryAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch galleryAuthorizationStatus{
            
        case PHAuthorizationStatus.authorized:
            self.present(self.imagePicker, animated: true, completion: nil)
            
        case .restricted, .denied:
            self.alertToEncourageCameraAccess("Gallery")
            
        case.notDetermined:
            PHPhotoLibrary.requestAuthorization() { status in
                self.galleryPermission()
            }
        }
    }
    
    //imagePickerControllerdelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let cell = self.signUpTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ProfileSetupUserImageCell
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            cell.userImageView.image = fixOrientationforImage(pickedImage)
            cell.userPlaceholderImageView.isHidden = true
            self.profileImage = fixOrientationforImage(pickedImage)
            self.signUpTableView.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func onTapSignUpBtn(_ sender:UIButton){
        
        var params = JSONDictionary()
        
        if self.userEditDataDict["full_name"]?.characters.count < 1{
            showToastWithMessage(ProfileStrings.enter_name)
            return
        }
        if self.userEditDataDict["email"]?.characters.count < 1 {
            showToastWithMessage(LoginPageStrings.enterEmail)
            return
        }
        if !isValidEmail(self.userEditDataDict["email"] ?? ""){
            showToastWithMessage(LoginPageStrings.enterValidEmail)
            return
            
        }
        if self.userEditDataDict["country_code"]?.characters.count < 1{
            showToastWithMessage(ProfileStrings.selectCountryCode)
            return
        }
        if self.userEditDataDict["phone_number"]?.characters.count < 1{
            showToastWithMessage(ProfileStrings.enterMobile)
            return
        }
        if !isValidPhoneNumber(self.userEditDataDict["phone_number"] ?? ""){
            showToastWithMessage(ProfileStrings.validMobile)
            return
        }
        if !self.terms_condition{
            showToastWithMessage(ProfileStrings.trms_condition)
            return
        }
        
        params["name"] = self.userEditDataDict["full_name"] as AnyObject
        params["email"] = self.userEditDataDict["email"] as AnyObject
        params["country_code"] = self.userEditDataDict["country_code"] as AnyObject
        params["phone"] = self.userEditDataDict["phone_number"] as AnyObject

        if let id = self.userEditDataDict["google_id"]{
            params["google_id"] = id as AnyObject
            
        }
        if let id = self.userEditDataDict["fb_id"]{
            params["fb_id"] = id as AnyObject
            
        }
        if let id = self.userEditDataDict["twt_id"]{
            params["twt_id"] = id as AnyObject
            
        }
        
        if let dob = self.userEditDataDict["d_o_b"]{
            params["dob"] = dob as AnyObject
        }
        if self.genderState == GenderSelectionState.male{
            params["gender"] = "male" as AnyObject
        }
        else if self.genderState == GenderSelectionState.male{
            params["gender"] = "female" as AnyObject
        }
        
        params["device_id"] = DeviceUUID as AnyObject
        params["device_token"] = APPDELEGATEOBJECT.device_Token as AnyObject
        params["device_model"] = DeviceModelName as AnyObject
        params["platform"] = OS_PLATEFORM as AnyObject
        params["os_version"] = SystemVersion_String as AnyObject

        var image: [String:UIImage]?
        
        if self.profileImage != nil{
            
            image = ["user_image": self.profileImage!]
            
        }

        CommonClass.startLoader("")
        printlnDebug(params)
        
        ServiceController.signUpApi(params, userImage: image, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()

            if success{
                let result = json["result"]
                userdata.saveJSONDataToUserDefault(result)

                let obj = self.storyboard?.instantiateViewController(withIdentifier: "MobileVerificationViewController") as! MobileVerificationViewController
                obj.mobileNumberText = self.userEditDataDict["phone_number"] ?? ""
                obj.code = self.userEditDataDict["country_code"] ?? ""
                obj.email = self.userEditDataDict["email"] ?? ""
                
                self.navigationController?.pushViewController(obj, animated: true)
            }
        }) { (error) in
            
            CommonClass.stopLoader()
            
        }
        
        self.signUpTableView.reloadData()
        
        
    }
    
    
    
    //MARK:-  Functions
    //MARK:- =================================================
    
    func dismissKeyboard(_ sender: AnyObject)
    {
        self.view.endEditing(true)
    }
    
    func getDate_of_birth(){
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.datePicker.maximumDate = Foundation.Date()
        let Date = dateFormatter.string(from: self.datePicker.date)
        self.userEditDataDict["dob"] = Date
        self.signUpTableView.reloadData()
    }
    
        func setDateFormat(_ date: String) -> String{
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM/dd/yyyy"
        let date = dateformatter.date(from: date)
        dateformatter.dateFormat = "yyyy-MM-dd"
        if date != nil{
            let dateStr = dateformatter.string(from: date!)
            return dateStr
        }
        return ""
    }
    
}


//MARK:- UITable view delegate and datasource
//MARK:- =================================================

extension ProfileSetUpVC : UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
            
        case 0:
            
            if IsIPad{
                return 250
                
            } else {
                return screenHeight/3
            }
            
        case 1,2,3,4:
            if IsIPad{
                return 100
                
            } else{
                return 60
            }
            
            
        case 5:
            if IsIPad{
                return 200
            } else{
                return 145
            }
            
        default:
            
            fatalError("SignUP")
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSetupUserImageCell", for: indexPath) as! ProfileSetupUserImageCell
            
            if self.profileImage != nil{
                cell.userImageView.image = self.profileImage
                cell.userPlaceholderImageView.isHidden = true
            }
            else if let imageName = self.userEditDataDict["imageName"]{
                
                if let imageUrl = URL(string: imageName){
                    cell.userImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "profile_placeholder"))
                    cell.userPlaceholderImageView.isHidden = true
                    self.profileImage = cell.userImageView.image
                }
            }
            
            cell.fullNameTextField.delegate = self
            if let full_name = self.userEditDataDict["full_name"]{
                cell.fullNameTextField.text = full_name
            }
            
            cell.SymbolImage.image = UIImage(named: self.fieldImageArr[indexPath.row])
            
            cell.fullNameTextField.attributedPlaceholder = NSAttributedString(string: self.fieldNameArr[indexPath.row].localized, attributes:[NSForegroundColorAttributeName: UIColor.white])
            cell.selectUserImageBtn.addTarget(self, action: #selector(SignUpVC.onTapEditImage(_:)), for: UIControlEvents.touchUpInside)
            return cell
            
        case 1,4:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSetupUserInfoCell", for: indexPath) as! ProfileSetupUserInfoCell
            
            cell.userInfoTextfield.delegate = self
            if indexPath.row == 1{
                cell.tapButton.isHidden = true
                
                if let email = self.userEditDataDict["email"]{
                    cell.userInfoTextfield.isSecureTextEntry = false
                    cell.userInfoTextfield.text = email
                }
                
            }

            else if indexPath.row == 4{
                cell.tapButton.isHidden = false
                cell.tapButton.addTarget(self, action: #selector(ProfileSetUpVC.dobTapped(_:)), for: UIControlEvents.touchUpInside)
                cell.userInfoTextfield.isSecureTextEntry = false
                if let dob = self.userEditDataDict["dob"]{
                    cell.userInfoTextfield.text = dob
                }
                
            }
            cell.SymbolImage.image = UIImage(named: self.fieldImageArr[indexPath.row])
            cell.genderView.isHidden = true
            cell.userInfoTextfield.isEnabled = true
            cell.userInfoTextfield.attributedPlaceholder = NSAttributedString(string: self.fieldNameArr[indexPath.row].localized, attributes:[NSForegroundColorAttributeName: UIColor.white])
            
            return cell
            
        case 2:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSetupUpMobileCell", for: indexPath) as! ProfileSetupUpMobileCell
            cell.mobileTextField.delegate = self
            cell.backgroundColor = UIColor.clear
            if let phone_number = self.userEditDataDict["phone_number"]{
                cell.mobileTextField.text = phone_number
            }
            if let code = self.userEditDataDict["country_code"]{
                cell.countryCodeTextField.text = code
            }
            cell.countryCodeTextField.attributedPlaceholder = NSAttributedString(string: "Code".localized, attributes:[NSForegroundColorAttributeName: UIColor.white])
            cell.mobileTextField.attributedPlaceholder = NSAttributedString(string: "Mobile".localized, attributes:[NSForegroundColorAttributeName: UIColor.white])
            cell.countrycodeBtn.addTarget(self, action: #selector(ProfileSetUpVC.codeTextFieldTapped(_:)), for: UIControlEvents.touchUpInside)
            return cell
            
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSetupUserInfoCell", for: indexPath) as! ProfileSetupUserInfoCell
            
            cell.genderView.isHidden = false
            cell.userInfoTextfield.isEnabled = false
            cell.tapButton.isHidden = true
            
            cell.SymbolImage.image = UIImage(named: self.fieldImageArr[indexPath.row])
            
            cell.userInfoTextfield.attributedPlaceholder = NSAttributedString(string: self.fieldNameArr[indexPath.row].localized, attributes:[NSForegroundColorAttributeName: UIColor.white])
            cell.maleCircleBtn.addTarget(self, action: #selector(ProfileSetUpVC.onTapMaleCircle(_:)), for: UIControlEvents.touchUpInside)
            cell.femaleCircleBtn.addTarget(self, action: #selector(ProfileSetUpVC.onTapFemaleCircle(_:)), for: UIControlEvents.touchUpInside)
            
            if self.genderState == GenderSelectionState.none{
                cell.maleCircleBtn.setImage(UIImage(named: "signup_circle"), for: UIControlState())
                cell.femaleCircleBtn.setImage(UIImage(named: "signup_circle"), for: UIControlState())
            }
            else if self.genderState == GenderSelectionState.male{
                cell.maleCircleBtn.setImage(UIImage(named: "signup_circle_filled"), for: UIControlState())
                cell.femaleCircleBtn.setImage(UIImage(named: "signup_circle"), for: UIControlState())
                
            }
            else if self.genderState == GenderSelectionState.female{
                cell.maleCircleBtn.setImage(UIImage(named: "signup_circle"), for: UIControlState())
                cell.femaleCircleBtn.setImage(UIImage(named: "signup_circle_filled"), for: UIControlState())
            }
            return cell
            
        case 5:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSetupButtonCell", for: indexPath) as! ProfileSetupButtonCell
            if self.terms_condition {
                cell.acceptTermCondition.setImage(UIImage(named: "signup_checkbox_tick"), for: UIControlState())
            }
            else{
                cell.acceptTermCondition.setImage(UIImage(named: "signup_checkbox"), for: UIControlState())
            }
            
            cell.signUpBtn.addTarget(self, action: #selector(ProfileSetUpVC.onTapSignUpBtn(_:)), for: UIControlEvents.touchUpInside)
            
            cell.acceptTermCondition.addTarget(self, action: #selector(ProfileSetUpVC.onTapTerm_Condition(_:)), for: UIControlEvents.touchUpInside)
            
            return cell
            
        default:
            fatalError("SignUP")
        }
    }
}

//MARK:- UITextField delegate
//MARK:- =================================================

extension ProfileSetUpVC: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        closeDatePicker()
    }

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if let cellIndexPath = textField.tableViewIndexPath(self.signUpTableView) {
            
            if cellIndexPath.row == 1{
                
                if let enable = self.userMediaData["isEditable"] as? String, enable == "n"{
                    showToastWithMessage(ProfileStrings.email_not_change)
                    return false
                }
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        
        var maxLength = 30
        
        if let cellIndexPath = textField.tableViewIndexPath(self.signUpTableView), (cellIndexPath.row == 2) {
            
            maxLength = 10
        }
        
        if string == " " && range.location == 0{
            return false
        }
        
        CommonClass.delay(0.1) { () -> () in
            if let  cellIndexPath = textField.tableViewIndexPath(self.signUpTableView){
                
                if cellIndexPath.row == 0{
                    
                    self.userEditDataDict["full_name"] = textField.text
                }
                else if cellIndexPath.row == 1{
                    self.userEditDataDict["email"] = textField.text
                    
                }
                else if cellIndexPath.row == 2{
                    let cell = textField.tableViewCell() as! ProfileSetupUpMobileCell
                    if textField === cell.mobileTextField{
                        self.userEditDataDict["phone_number"] = textField.text
                    }
                }
                    
                else if cellIndexPath.row == 4{
                    self.userEditDataDict["dob"] = textField.text
                }
            }
        }
        
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= maxLength
    }
    
    // validate textfield data
    func validateInfo(_ textField :UITextField,string : String,range:NSRange) -> Bool {
        
        if range.length == 1 {
            return true
        }
        
        if string == " " && range.location == 0{
            return false
        }
        
        return true
    }
}

//MARK:- UITable view cell classes
//MARK:- =================================================

class ProfileSetupUserImageCell: UITableViewCell {
    
    @IBOutlet weak var selectUserImageBtn: UIButton!
    @IBOutlet weak var userPlaceholderImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var SymbolImage: UIImageView!
    @IBOutlet weak var fullNameTextField: UITextField!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        self.userImageView.layer.cornerRadius = 55
        self.userImageView.layer.masksToBounds = true
        self.selectUserImageBtn.layer.cornerRadius = self.selectUserImageBtn.frame.height / 2
    }
}

class ProfileSetupUserInfoCell: UITableViewCell {
    
    @IBOutlet weak var userInfoTextfield: UITextField!
    @IBOutlet weak var SymbolImage: UIImageView!
    @IBOutlet weak var tapButton: UIButton!
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var maleLbl: UILabel!
    @IBOutlet weak var maleCircleBtn: UIButton!
    @IBOutlet weak var femaleLbl: UILabel!
    @IBOutlet weak var femaleCircleBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        
        self.contentView.backgroundColor = UIColor.clear
    }
}

class ProfileSetupButtonCell: UITableViewCell {
    
    @IBOutlet weak var signUpBtn: UIButton!
    
    @IBOutlet weak var acceptTermCondition: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        
        self.contentView.backgroundColor = UIColor.clear
        
        self.signUpBtn.layer.borderWidth = 1
        self.signUpBtn.layer.cornerRadius = 20
        self.signUpBtn.layer.borderColor = UIColor(red: 59/255, green: 19/255, blue: 73/255, alpha: 1).cgColor
    }
    
}

class ProfileSetupUpMobileCell: UITableViewCell{
    
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var countrycodeBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}



// MARK: UIPickerView Delegate  Methods
//MARK:- =================================================


extension ProfileSetUpVC: ShowCountryDetailDelegate {
    
    func getCountryDetails(_ text:String!,countryName:String!,Max_NSN_Length:Int!,Min_NSN_Length:Int!,countryShortName : String!){
        
        self.userEditDataDict["country_code"] = text
        self.signUpTableView.reloadData()
        
    }
}



