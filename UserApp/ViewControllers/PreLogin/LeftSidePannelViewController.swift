//
//  LeftSidePannelViewController.swift
//  DriverApp
//
//  Created by saurabh on 08/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import SDWebImage
import MFSideMenu

var selectedIndex = 1


class LeftSidePannelViewController: UIViewController {
    
    //MARK:- Constant
    //MARK:- =================================================

    
    let menuSelectedImageArray = ["","sidepanel_home_select","sidepanel_wallet_red","sidepanel_history_red","sidepanel_notification_red","sidepanel_qus_red","sidepanel_settings_red","sidepanel_batch_red","sidepanel_edit_red","sidepanel_privacy_red","sidepanel_car_red"]
    
    let menuSelectedImageArray_subs = ["","sidepanel_home_select","sidepanel_wallet_red","sidepanel_history_red","sidepanel_notification_red","sidepanel_qus_red","sidepanel_settings_red","sidepanel_batch_red","sidepanel_star_red","sidepanel_edit_red","sidepanel_privacy_red","sidepanel_car_red"]

    
    let menuDeselectedImageArray = [" ","sidepanel_home_deselect","sidepanel_wallet", "sidepanel_history", "sidepanel_notification", "sidepanel_qus", "sidepanel_settings", "sidepanel_batch","sidepanel_edit","sidepanel_privacy","sidepanel_car"]
    
    let menuDeselectedImageArray_subs = [" ","sidepanel_home_deselect","sidepanel_wallet", "sidepanel_history", "sidepanel_notification", "sidepanel_qus", "sidepanel_settings", "sidepanel_batch","sidepanel_star","sidepanel_edit","sidepanel_privacy","sidepanel_car"]

    
    let menuNameArray = [" ","HOME","PAYMENT METHOD", "RIDE HISTORY", "NOTIFICATIONS", "HOW IT WORKS","SETTINGS", "PROMOTIONS","TERMS OF USE","PRIVACY POLICY","BE A DRIVER"]
    
    let menuNameArrayWithSubs = [" ","HOME","PAYMENT METHOD", "RIDE HISTORY", "NOTIFICATIONS", "HOW IT WORKS","SETTINGS", "PROMOTIONS","SUBSCRIPTIONS","TERMS OF USE","PRIVACY POLICY","BE A DRIVER"]

    
    var blurredImage : UIImage?
    
    
    //MARK:- IBOutlets
    //MARK:- =================================================

    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var menuTableHeader: UIView!
    @IBOutlet weak var visualView: UIView!
    @IBOutlet weak var userBlurImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification), name:NSNotification.Name(rawValue: "NOTIFICATION"), object: nil)

        self.menuTableView.dataSource = self
        self.menuTableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.menuTableView.reloadData()
    }

    
    func profileBtnTapped(_ sender: UIButton){
        
        let tabBarCantroller = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "MyProfileViewController") as! MyProfileViewController
        let navController = UINavigationController(rootViewController: tabBarCantroller)
        navController.isNavigationBarHidden = true
        navController.automaticallyAdjustsScrollViewInsets=false
        mfSideMenuContainerViewController.centerViewController = navController
        mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {
            selectedIndex = 0
            
        }
    }
    
    func methodOfReceivedNotification(){
    
        self.menuTableView.reloadData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

    
}

// MARK: Table View Datasource Life Cycle Methods
//MARK:- =================================================

extension LeftSidePannelViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if CurrentUser.userType?.lowercased() == "normal"{
            return self.menuNameArray.count
        }
        else{
            return self.menuNameArrayWithSubs.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if IsIPad{
            if indexPath.row == 0{
                return 250
            }
            return 100
        }
        
        if indexPath.row == 0{
            return 200
        }
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuHeaderTableViewCell", for: indexPath) as! MenuHeaderTableViewCell
            
            CommonClass.delay(0.1, closure: {
                cell.setLayOut()
            })
            
            cell.profileBtn.addTarget(self, action: #selector(self.profileBtnTapped(_:)), for: UIControlEvents.touchUpInside)
            if CurrentUser.full_name != nil{
                
                cell.menuNameLabel.text = CurrentUser.full_name?.uppercased()
            }
            
            if let imageUrl = CurrentUser.getUserImage {
                
                    
                    cell.profileImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_place_holder"), options: [], completed: { (image, error, _, url) in
                        
                        if error == nil {
                            
                            let cacheKey = ("userBlurredImage" + (CurrentUser.user_image ?? ""))
                            
                            SDImageCache.shared().queryDiskCache(forKey: cacheKey, done: { (cachedImage, _) in
                                
                                if cachedImage != nil {
                                    
                                    cell.menuImageView.image = cachedImage
                                    
                                } else {
                                    SDImageCache.shared().store(image?.blurEffect(60), forKey: cacheKey)
                                    cell.menuImageView.image = image?.blurEffect(60)
                                }
                            })
                        }
                    })
                    
                } else {
                    
                    cell.menuImageView.backgroundColor = UIColor.black
                }
                
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell
            delay(0.001, closure: {
                cell.setUpViews(indexPath.row)

            })
            if CurrentUser.userType?.lowercased() == "normal"{
                if indexPath.row == self.menuNameArray.count - 1{
                    cell.lineView.isHidden = true
                }
                else{
                    cell.lineView.isHidden = false
                }

            }else{
                
                if indexPath.row == self.menuNameArrayWithSubs.count - 1{
                    cell.lineView.isHidden = true
                }
                else{
                    cell.lineView.isHidden = false
                }
                
            }
            
            if selectedIndex == indexPath.row {
                
                if CurrentUser.userType?.lowercased() == "normal"{
                    
                    cell.populateCell(withImage: self.menuSelectedImageArray[indexPath.row], withMenu: self.menuNameArray[indexPath.row], withColor: UIColor(red: 194/255, green: 0, blue: 52/255, alpha: 1))

                }else{
                    
                    cell.populateCell(withImage: self.menuSelectedImageArray_subs[indexPath.row], withMenu: self.menuNameArrayWithSubs[indexPath.row], withColor: UIColor(red: 194/255, green: 0, blue: 52/255, alpha: 1))
                }

            } else {
                if CurrentUser.userType?.lowercased() == "normal"{
                    cell.populateCell(withImage: self.menuDeselectedImageArray[indexPath.row], withMenu: self.menuNameArray[indexPath.row], withColor: UIColor.black)

                }else{
                    cell.populateCell(withImage: self.menuDeselectedImageArray_subs[indexPath.row], withMenu: self.menuNameArrayWithSubs[indexPath.row], withColor: UIColor.black)
                }

            }
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        tabbarSelect = 0

        switch indexPath.row {
            
        case 1:
            
            CommonClass.gotoHomeVC()
            mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {}
            
        case 2:
            
            let paymentScene = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "PaymentMethodID") as! PaymentMethodViewController
            paymentScene.sender = Sender.sideMenu
            let navController = UINavigationController(rootViewController: paymentScene)
            navController.isNavigationBarHidden = true
            navController.automaticallyAdjustsScrollViewInsets=false
            mfSideMenuContainerViewController.centerViewController = navController
            mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {}
            
        case 3:
            
            let rideHistoryVc = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "RideHistory") as! RideHistory
            let navController = UINavigationController(rootViewController: rideHistoryVc)
            navController.isNavigationBarHidden = true
            navController.automaticallyAdjustsScrollViewInsets=false
            mfSideMenuContainerViewController.centerViewController = navController
            mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {}
    
        case 4:
            
            let settingsScene = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
            let navController = UINavigationController(rootViewController: settingsScene)
            navController.isNavigationBarHidden = true
            navController.automaticallyAdjustsScrollViewInsets = false
            mfSideMenuContainerViewController.centerViewController = navController
            mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {}
            
        case 5:
            
            let settingsScene = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "HowItWorksVC") as! HowItWorksVC
            let navController = UINavigationController(rootViewController: settingsScene)
            navController.isNavigationBarHidden = true
            navController.automaticallyAdjustsScrollViewInsets = false
            mfSideMenuContainerViewController.centerViewController = navController
            mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {}
            
        case 6:
            
            let settingsScene = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            let navController = UINavigationController(rootViewController: settingsScene)
            navController.isNavigationBarHidden = true
            navController.automaticallyAdjustsScrollViewInsets=false
            mfSideMenuContainerViewController.centerViewController = navController
            mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {}
            
        case 7:
            
            
            let settingsScene = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "PromotionsVC") as! PromotionsVC
            let navController = UINavigationController(rootViewController: settingsScene)
            navController.isNavigationBarHidden = true
            navController.automaticallyAdjustsScrollViewInsets = false
            mfSideMenuContainerViewController.centerViewController = navController
            mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {}

        case 8:
            
            if CurrentUser.userType?.lowercased() == "normal"{
                
                self.gotoStaticPage("terms-and-conditions", title: "TERMS OF USE")

            }else{
                
                self.gotoSubscripionVC()
            }

        case 9:
            
            if CurrentUser.userType?.lowercased() == "normal"{
                
                self.gotoStaticPage("privacy-policy", title: "PRIVACY POLICY")

            }else{
                self.gotoStaticPage("terms-and-conditions", title: "TERMS OF USE")

            }

        case 10:
            
            if CurrentUser.userType?.lowercased() == "normal"{
                self.openBrowser()
            }else{
                self.gotoStaticPage("privacy-policy", title: "PRIVACY POLICY")
            }
            
        case 11:
            
            self.openBrowser()

        default:
            showToastWithMessage("Work in progress.".localized)
        }
    }
    
    
    func gotoSubscripionVC(){
        let settingsScene = getStoryboard(StoryboardName.Subscription).instantiateViewController(withIdentifier: "SubscriptionVC") as! SubscriptionVC
        let navController = UINavigationController(rootViewController: settingsScene)
        navController.isNavigationBarHidden = true
        navController.automaticallyAdjustsScrollViewInsets = false
        mfSideMenuContainerViewController.centerViewController = navController
        mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {}

    }
    
    
    func openBrowser(){
    
        let url = URL(string: "http://wav.com.sg/driverweb/default/driver")!
        UIApplication.shared.openURL(url)
        mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {}

    }
    
    
    func gotoStaticPage(_ action: String, title: String){
        
        let settingsScene = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
        settingsScene.str = title
        settingsScene.action = action
        let navController = UINavigationController(rootViewController: settingsScene)
        navController.isNavigationBarHidden = true
        navController.automaticallyAdjustsScrollViewInsets = false
        mfSideMenuContainerViewController.centerViewController = navController
        mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {}

    }
    
}

// Class for Table View Cell (Not resued anyWhere)
// MARK:- Menu Cell
//MARK:- =================================================


class MenuTableViewCell: UITableViewCell {
    
    // IBOutlets
    
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var menuNameLabel: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    // Table View Cell Life Cycle Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.menuImageView.image = nil
        self.menuNameLabel.text = nil
        
    }
    
    func setUpViews(_ index: Int){

        self.countLbl.isHidden = true

        if index == 4{
            if notificationCount == 0{
                
                self.countLbl.isHidden = true
                
            }else{
                
                self.countLbl.isHidden = false
                self.countLbl.text = "\(notificationCount)"
                
            }
        }else{
            self.countLbl.isHidden = true

        }
        self.countLbl.layer.cornerRadius = 10
        self.countLbl.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        self.menuImageView.image = nil
        self.menuNameLabel.text = nil
        self.menuNameLabel.textColor = UIColor.black
    }
    
    // Private Methods
    func populateCell(withImage imageName: String, withMenu menuName: String, withColor textColor: UIColor) {
        
        self.menuImageView.image = UIImage(named: imageName)
        self.menuNameLabel.text = menuName
        self.menuNameLabel.textColor = textColor
    }
}

class MenuHeaderTableViewCell: UITableViewCell {
    
    // IBOutlets
    
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var menuNameLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var profileBtn: UIButton!
    
    // Table View Cell Life Cycle Methods
    
    // Private Methods
    
    func setLayOut(){
        
        self.profileImage.layer.borderWidth = 3
        
        self.shadowView.layer.cornerRadius = self.shadowView.bounds.height / 2
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.height / 2
        self.profileImage.layer.masksToBounds = true
        self.profileImage.layer.borderColor = UIColor(red: 219/255, green: 0, blue: 84/255, alpha: 1).cgColor
        self.profileImage.clipsToBounds = true
        self.shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.shadowView.layer.shadowOpacity = 0.80
        self.shadowView.layer.shadowRadius = 2.0
        self.shadowView.clipsToBounds = false
    }
    
    func populateCell(withImageName imageName: String, withMenuName menuName: String) {
        
        self.menuImageView.image = UIImage(named: imageName)
        self.menuNameLabel.text = menuName
        
    }
    
}

