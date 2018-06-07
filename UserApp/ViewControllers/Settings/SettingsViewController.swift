//
//  SettingsViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/20/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import MFSideMenu

class SettingsViewController: UIViewController {
    
    // MARK: IBOutlets
    //MARK:- =================================================
    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var logOutBtn: UIButton!
    
    // MARK: Constants
    //MARK:- =================================================
    
    let settingsArray = ["Notification", "Share App", "Support" , "About", "Saved Locations", "Change Password"]
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.setMenuButton()
        self.initialSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mfSideMenuContainerViewController.panMode = MFSideMenuPanModeDefault
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        mfSideMenuContainerViewController.panMode = MFSideMenuPanModeNone
    }
    
    // MARK: Private Methods
    //MARK:- =================================================
    
    func initialSetup() {
        
        self.settingsTableView.dataSource = self
        self.settingsTableView.delegate = self
        
        self.settingsTableView.rowHeight = IsIPad ? 70:54
    }
    
    func toggleNotification(_ sender: UIButton) {
        
        var params = JSONDictionary()
        
        if CurrentUser.notification_status == Status.zero{
            params["status"] = Status.one
            
        }else{
            params["status"] = Status.zero
            
        }
        CommonClass.startLoader("")
        
        ServiceController.notificationStatusApi(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()
            
            if success{
                
                if CurrentUser.notification_status == Status.zero{
                    UserDefaults.save(Status.one as AnyObject, forKey: NSUserDefaultsKeys.NOTIFICATION_STATUS)
                    
                }else{
                    UserDefaults.save(Status.zero as AnyObject, forKey: NSUserDefaultsKeys.NOTIFICATION_STATUS)
                    
                }
                self.settingsTableView.reloadData()
                
            }
        }) { (error) in
            
            CommonClass.stopLoader()
        }
        
        
    }
    
    // IBActions
    //MARK:- =================================================
    
    
    @IBAction func logoutBtnTapped(_ sender: UIButton) {
        
        CommonClass.startLoader("")
        guard CommonClass.isConnectedToNetwork else{
            CommonClass.stopLoader()
            showToastWithMessage(NetworkIssue.slow_Network)
            return
        }
        
        ServiceController.logOutApi({ (success, json) in
            
            CommonClass.stopLoader()

            if success{
            
                UserDefaults.clearUserDefaults()
                CommonClass.goToLogin()
            }
            
        }) { (error) in
            
            CommonClass.stopLoader()

            
        }
        
    }
    
    func displayShareSheet(_ shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }
    
}

// MARK: TableView Datasource Life Cycle Methods
//MARK:- =================================================

extension SettingsViewController: UITableViewDataSource , UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if CurrentUser.social_id == nil{
            return self.settingsArray.count
        }
        else{
            return self.settingsArray.count - 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as! SettingsTableViewCell
        
        cell.populate(withSettingName: self.settingsArray[indexPath.row])
        cell.notificationSwitchBtn.addTarget(self, action: #selector(self.toggleNotification(_:)), for: .touchUpInside)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            
            
        case 1:
            
            self.displayShareSheet("Invite your friends to join WAV: https://itunes.apple.com/us/app/wav-user/id1224595860?ls=1&mt=8")
        case 2:
            
            
            let obj = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "SupportViewController") as! SupportViewController
            self.navigationController?.pushViewController(obj, animated: true)
            
        case 3:
            
            let obj = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
            obj.str = "ABOUT"
            obj.action = "about-us"
            obj.naviBtnState = .back
            self.navigationController?.pushViewController(obj, animated: true)
            
        case 4:
            
            let obj = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "SavedLocationsVC") as! SavedLocationsVC
            self.navigationController?.pushViewController(obj, animated: true)
            
        case 5:
            
            let obj = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
            self.navigationController?.pushViewController(obj, animated: true)
            
            
        default:
            printlnDebug("error")
        }
    }
}


// MARK: Class for SettingsTableViewCell
//MARK:- =================================================

class SettingsTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var notificationSwitchBtn: UIButton!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.notificationSwitchBtn.isHidden = true
        self.arrowImageView.isHidden = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // MARK: Private Methods
    func populate(withSettingName settingName: String) {
        
        if settingName == "Notification" {
            
            if CurrentUser.notification_status == Status.zero{
                self.notificationSwitchBtn.setImage(UIImage(named: "settings_off_btn"), for: UIControlState())
                
            }else{
                self.notificationSwitchBtn.setImage(UIImage(named: "settings_on_btn"), for: UIControlState())
            }
            
            
            self.notificationSwitchBtn.isHidden = false
            self.arrowImageView.isHidden = true
            
        } else {
            
            self.notificationSwitchBtn.isHidden = true
            self.arrowImageView.isHidden = false
        }
        self.settingLabel.text = settingName
    }
    
}
