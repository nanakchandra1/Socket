//
//  MyProfileViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/12/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation
import Photos

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Constants
    //MARK:- =================================================

    let fieldArray = ["NAME", "GENDER", "DOB"]
    
    // MARK: Variables
    //MARK:- =================================================

    var userDetailsDict: [String:String] = [:]
    var profileImage: UIImage?
    var genderState:GenderSelectionState = .none
    
    lazy var imagePicker = UIImagePickerController()
    
    // MARK: IBOutlets
    //MARK:- =================================================
    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var editProfileTableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userBlurImageView: UIImageView!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var datePickerHightConstaints: NSLayoutConstraint!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    //MARK:- View life cycle
    //MARK:- =================================================
    override func viewDidLoad() {
        super.viewDidLoad()


        // Delegating Table View
        self.editProfileTableView.dataSource = self
        self.editProfileTableView.delegate = self
        
        self.initialSetup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.userImageView.layer.cornerRadius = self.userImageView.frame.width/2
        self.cameraBtn.layer.cornerRadius = self.cameraBtn.frame.width/2
        
//        let angle = Float(Double.pi)
//        let x = self.userImageView.frame.width/2 * CGFloat(cosf(angle))
//        let y = self.userImageView.frame.width/2 * CGFloat(sinf(angle))
        
//        self.cameraBtn.center = CGPoint(x: (self.userImageView.center.x + x), y: (self.userImageView.center.y + y))
    }
    
    // MARK: Private Methods
    //MARK:- =================================================

    func initialSetup() {
        
        // Customising Outlets
        self.tableHeaderView.frame.size.height = IsIPad ? 260:185
        self.userImageView.clipsToBounds = true
        self.userImageView.layer.borderColor = UIColor(red: 115/255, green: 125/255, blue: 134/255, alpha: 1).cgColor
        self.userImageView.layer.borderWidth = IsIPad ? 4.5:2.5
        self.cameraBtn.clipsToBounds = true
        self.cameraBtn.layer.borderColor = UIColor.lightGray.cgColor
        self.cameraBtn.layer.borderWidth = IsIPad ? 2.5:1.5
        self.datePickerHightConstaints.constant = -300
        self.imagePicker.delegate = self
        
        self.datePicker.maximumDate = Date()
        
        if let imageUrl = CurrentUser.getUserImage {
            
                self.userImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_place_holder"), options: [], completed: { (image, error, _, url) in
                    
                    if error == nil {
                        
                        let cacheKey = ("userBlurredImage" + (CurrentUser.user_image ?? ""))
                        
                        SDImageCache.shared().queryDiskCache(forKey: cacheKey, done: { (cachedImage, _) in
                            
                            if cachedImage != nil {
                                
                                self.userBlurImageView.image = cachedImage
                                
                            } else {
                                
                                SDImageCache.shared().store(image?.blurEffect(60), forKey: cacheKey)
                                self.userBlurImageView.image = image?.blurEffect(60)
                            }
                        })
                    }
                })
            }
            else {
                self.userBlurImageView.backgroundColor = UIColor.black
            }
        
        
        if CurrentUser.full_name != nil{
            
            self.userNameLabel.text = CurrentUser.full_name?.uppercased()
            self.userDetailsDict["NAME"] =  CurrentUser.full_name
        }
        
        if CurrentUser.gender != nil{
            
            if CurrentUser.gender?.lowercased() == "m" || CurrentUser.gender?.lowercased() == "male"{
                self.genderState = GenderSelectionState.male
                self.editProfileTableView.reloadData()
            }else if CurrentUser.gender?.lowercased() == "f" || CurrentUser.gender?.lowercased() == "female"{
                self.genderState = GenderSelectionState.female
                self.editProfileTableView.reloadData()
            }
            self.userDetailsDict["GENDER"] =  CurrentUser.gender
        }
        
        self.userDetailsDict["DOB"] =  CurrentUser.getDob

        self.editProfileTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.view.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    
    
    func isAllFieldsVerified() -> Bool {
        
        if self.userDetailsDict["NAME"] == nil || self.userDetailsDict["NAME"]!.isEmpty {
            
            showToastWithMessage(ProfileStrings.nameRequired)
            return false
            
        }
        
        return true
    }
    
    func onTapMaleCircle(_ sender: UIButton){
        self.genderState = GenderSelectionState.male
        self.editProfileTableView.reloadData()
    }
    
    func onTapFemaleCircle(_ sender: UIButton){
        self.genderState = GenderSelectionState.female
        self.editProfileTableView.reloadData()
    }
    
    func getDate_of_birth(){
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.datePicker.maximumDate = Foundation.Date()
        let Date = dateFormatter.string(from: self.datePicker.date)
        self.userDetailsDict["DOB"] = Date
        self.editProfileTableView.reloadData()
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
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.userImageView.image = fixOrientationforImage(pickedImage)
            self.profileImage = fixOrientationforImage(pickedImage)
            
            self.userBlurImageView.image = fixOrientationforImage(pickedImage).blurEffect(60)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: IBActions
    @IBAction func saveBtnTapped(_ sender: UIButton) {
        
        var params = JSONDictionary()
        
        if isAllFieldsVerified(){
            
            params["name"] = self.userDetailsDict["NAME"]
            params["dob"] = self.userDetailsDict["DOB"]
            if self.genderState == GenderSelectionState.male{
                params["gender"] = "male"
            }
            else if self.genderState == GenderSelectionState.female{
                
                params["gender"] = "female"
            }
            
            params["action"] = "profile"
            
            CommonClass.startLoader("")
            
            var image:[String: UIImage]?

            if self.profileImage != nil{
                
                image = ["user_image": self.profileImage!]
            }
            
            ServiceController.editProfile(params, userImage: image, SuccessBlock: { (success,json) in
                
                CommonClass.stopLoader()
                
                if success{
                    
                    let result = json["result"]
                    
                    userdata.saveJSONDataToUserDefault(result)

                    let cacheKey = ("userBlurredImage" + (CurrentUser.user_image ?? ""))
                    SDImageCache.shared().removeImage(forKey: cacheKey, fromDisk: true)
                    
                    self.navigationController?.popViewController(animated: true)
                    
                }
            }) { (error) in
                
                CommonClass.stopLoader()
                
            }
        }
    }
    
    
    //MARK:- IBActions
    //MARK:- =================================================

    @IBAction func backBtnTapped(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cameraBtnTapped(_ sender: UIButton) {
     
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
    
    // MARK: Web APIs
    func saveUserDetailsAction() {
        
        // #Warning: Save user details service here
    }
    
    @IBAction func datePickreDoneButtonTapped(_ sender: UIButton) {
        
        self.getDate_of_birth()
        UIView.animate(withDuration: 1, animations: {
            self.datePickerHightConstaints.constant = -300
            }, completion: { (true) in
        })
    }
    
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        
        UIView.animate(withDuration: 1, animations: {
            self.datePickerHightConstaints.constant = -300
            }, completion: { (true) in
        })
    }
    
    
}

// MARK: TableView DataSource Life Cycle Methods
//MARK:- =================================================

extension EditProfileViewController: UITableViewDataSource {
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.fieldArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileTableViewCell", for: indexPath) as! EditProfileTableViewCell
        
        cell.populateCell(withLabelText: self.fieldArray[indexPath.row], withTextFieldText: (userDetailsDict[self.fieldArray[indexPath.row]] ?? ""))
        
        cell.editProfileTextField.delegate = self
        
        if indexPath.row == 1 {
            
            cell.editProfileTextField.isHidden = true
            cell.genderView.isHidden = false
            
            cell.maleCircleBtn.addTarget(self, action: #selector(self.onTapMaleCircle(_:)), for: UIControlEvents.touchUpInside)
            cell.femaleCircleBtn.addTarget(self, action: #selector(self.onTapFemaleCircle(_:)), for: UIControlEvents.touchUpInside)
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
            
        } else {
            
            cell.genderView.isHidden = true
            cell.editProfileTextField.isHidden = false
        }
        
        return cell
    }
    
}

// MARK: TableView Delegate Life Cycle Methods
//MARK:- =================================================

extension EditProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return IsIPad ? 100:74
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return IsIPad ? 100:74
    }
    
}

// MARK: TextField Delegate Life Cycle Methods
//MARK:- =================================================

extension EditProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let cell = textField.superview?.superview as! EditProfileTableViewCell
        let indexPath = self.editProfileTableView.indexPath(for: cell)!
        
        if indexPath.row == 2 {
            
            self.datePicker.datePickerMode = UIDatePickerMode.date
            self.datePickerHightConstaints.constant = 0
            return false
        }
        else{
            self.datePickerHightConstaints.constant = -300

        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let cell = textField.superview?.superview as! EditProfileTableViewCell
        let indexPath = self.editProfileTableView.indexPath(for: cell)!
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        
        let userEnteredString = textField.text
        let newString = (userEnteredString! as NSString).replacingCharacters(in: range, with: string) as NSString
        
        switch self.fieldArray[indexPath.row] {
            
        case "DOB":
            self.userDetailsDict["DOB"] = "\(newString)"
            
        case "NAME":
            self.userDetailsDict["NAME"] = "\(newString)"
            
        default:
            break
        }
        
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 25
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}

// Class for Table View Cell (Not resued anyWhere)
// MARK: My Profile Cell
//MARK:- =================================================


class EditProfileTableViewCell: UITableViewCell {
    
    // IBOutlets
    @IBOutlet weak var editProfileNameLabel: UILabel!
    @IBOutlet weak var editProfileTextField: UITextField!
    
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var maleCircleBtn: UIButton!
    @IBOutlet weak var femaleCircleBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.editProfileTextField.layer.cornerRadius = 2
        self.editProfileTextField.clipsToBounds = true
        self.editProfileTextField.layer.borderColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1).cgColor
        self.editProfileTextField.layer.borderWidth = 1.2
        self.editProfileTextField.returnKeyType = .done
        self.editProfileTextField.autocapitalizationType = .words
    }
    
    // Table View Cell Life Cycle Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.editProfileNameLabel.text = nil
        self.editProfileTextField.text = nil
    }
    
    // Private Methods
    func populateCell(withLabelText labelText: String, withTextFieldText textFieldText: String) {
        
        self.editProfileNameLabel.text = labelText
        self.editProfileTextField.text = textFieldText
    }
}
