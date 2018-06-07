//
//  MyProfileViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/12/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import SDWebImage

enum MobileNumberState {
    case edit, normal
}

class MyProfileViewController: UIViewController {
    
    // MARK: Constants
    //MARK:- =================================================

    let fieldArray = ["Name", "Email", "Contact Number", "Gender", "DOB"]
    let profileDetailImages = ["my_profile_name", "my_profile_mail", "my_profile_call", "profile_setup_gender", "profile_setup_dob"]
    
    // MARK: Variables
    //MARK:- =================================================

    var userDetailsDict: [String:String] = [:]
    var imageCache = ""
    
    // MARK: IBOutlets
    //MARK:- =================================================
    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var myProfileTableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userBlurImageView: UIImageView!
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationView.setMenuButton()
        
        // Delegating Table View
        self.myProfileTableView.dataSource = self
        self.myProfileTableView.delegate = self
        self.initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if CurrentUser.full_name != nil{
            self.userNameLabel.text = CurrentUser.full_name?.uppercased()
        }
        self.setProfileData()
        
        if imageCache != (CurrentUser.user_image ?? "") {
            self.userBlurImageView.image = UIImage(named: "ic_place_holder")
        }
        
        self.myProfileTableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.userImageView.layer.cornerRadius = self.userImageView.frame.width/2
    }
    
    // MARK: Private Methods
    //MARK:- =================================================

    func initialSetup() {
        
        // Customising Outlets
        self.userImageView.layer.borderWidth = IsIPad ? 4.5:2.5
        self.userImageView.layer.borderColor = UIColor(red: 115/255, green: 125/255, blue: 134/255, alpha: 1).cgColor
        self.userImageView.clipsToBounds = true
        
        self.tableHeaderView.frame.size.height = IsIPad ? 260:195
        
    }
    
    func setProfileData(){
        
        
            if let imageUrl = CurrentUser.getUserImage {
                
                self.userImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_place_holder"), options: [], completed: { (image, error, _, url) in
                    
                    if error == nil {
                        
                        let cacheKey = ("userBlurredImage" + (CurrentUser.user_image ?? ""))
                        self.imageCache = (CurrentUser.user_image ?? "")
                        
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
            else{
                self.userBlurImageView.backgroundColor = UIColor.black
            }
        
        
        if CurrentUser.full_name != nil{
            self.userNameLabel.text = CurrentUser.full_name?.uppercased()
            self.userDetailsDict["Name"] = CurrentUser.full_name
        }
        if CurrentUser.email != nil{
            self.userDetailsDict["Email"] = CurrentUser.email
        }
        if CurrentUser.mobile != nil{
            self.userDetailsDict["Contact Number"] = CurrentUser.mobile
        }
        if CurrentUser.gender != nil{
            
            self.userDetailsDict["Gender"] = CurrentUser.gender?.capitalized
        }
        if CurrentUser.dob != nil{
            self.userDetailsDict["DOB"] = setDateFormat(CurrentUser.dob!)
        }
    }
    
    func setDateFormat(_ date: String) -> String{
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date = dateformatter.date(from: date)
        dateformatter.dateFormat = "yyyy-MM-dd"
        if date != nil{
            let dateStr = dateformatter.string(from: date!)
            return dateStr
        }
        return ""
    }
    
    func editMobileBtnTapped(){
        
        let mobileVerificationScene =  getStoryboard("Main").instantiateViewController(withIdentifier: "MobileVerificationViewController") as! MobileVerificationViewController
        mobileVerificationScene.mobileNumberText = CurrentUser.mobile ?? ""
        mobileVerificationScene.code = CurrentUser.country_code ?? ""
        mobileVerificationScene.mobileNumberState = MobileNumberState.edit
        self.navigationController?.pushViewController(mobileVerificationScene, animated: true)
    }
    
    // MARK: IBActions
    //MARK:- =================================================

    @IBAction func editProfileBtnTapped(_ sender: UIButton) {
        
        let editScene =  getStoryboard("User").instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        self.navigationController?.pushViewController(editScene, animated: true)
        
    }
    
    
}

// MARK: TableView DataSource Life Cycle Methods
//MARK:- =================================================

extension MyProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.fieldArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyProfileTableViewCell", for: indexPath) as! MyProfileTableViewCell
        
        
        cell.populateCell(withImageName: profileDetailImages[indexPath.row], withLabelText: self.fieldArray[indexPath.row], withTextFieldText: (userDetailsDict[self.fieldArray[indexPath.row]] ?? ""))
        
        if indexPath.row != 2{
            
            cell.editMobileBtn.isHidden = true
        } else{
            
            cell.editMobileBtn.isHidden = false
            cell.editMobileBtn.addTarget(self, action: #selector(self.editMobileBtnTapped), for: .touchUpInside)
        }
        
        if indexPath.row == self.fieldArray.count-1 {
            cell.separaterView.isHidden = true
        } else {
            cell.separaterView.isHidden = false
        }
        return cell
    }
    
}

// MARK: TableView Delegate Life Cycle Methods
//MARK:- =================================================

extension MyProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return IsIPad ? 82:55
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return IsIPad ? 82:55
    }
}

// Class for Table View Cell (Not resued anyWhere)
// MARK: My Profile Cell
//MARK:- =================================================

class MyProfileTableViewCell: UITableViewCell {
    
    // IBOutlets
    @IBOutlet weak var myProfileImageView: UIImageView!
    @IBOutlet weak var myProfileNameLabel: UILabel!
    @IBOutlet weak var myProfileTextField: UITextField!
    @IBOutlet weak var editMobileBtn: UIButton!
    @IBOutlet weak var separaterView: UIView!
    
    // Table View Cell Life Cycle Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.myProfileImageView.image = nil
        self.myProfileNameLabel.text = nil
        self.myProfileTextField.text = nil
    }
    
    // Private Methods
    func populateCell(withImageName imageName: String, withLabelText labelText: String, withTextFieldText textFieldText: String) {
        
        self.myProfileImageView.image = UIImage(named: imageName)
        self.myProfileNameLabel.text = labelText
        self.myProfileTextField.text = textFieldText
        
    }
}
