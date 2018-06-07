//
//  AppdelegateExtension.swift
//  UserApp
//
//  Created by Appinventiv on 15/11/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import Foundation
import SwiftyJSON
import SDWebImage


extension AppDelegate{

    //MARK:- initial app setup
    
    func initialSetup(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?){
        
        
        //CountryHandler
        let handler: VoiceeCountryHandler = VoiceeCountryHandler()
        handler.prepareDataBace()
        
        if launchOptions != nil{
            
            if let userInfo = launchOptions![UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]{
                print_debug("launchOptions userInfo\n\(userInfo)")
                
                if (userInfo["aps"] as? [String:AnyObject]) != nil{
                    
                    //  Push recived
                    self.handleRemotePush(userInfo as! [String: AnyObject], application: application)
                }
            }
        }
    }
    
    //MARK:- navigate or show pop by push notification

    func showPopUp(_ aps: [String: AnyObject],application: UIApplication) {
        
        
        if let type = aps["type"] as? String{
            
            print_debug(type)
            if type == "prebookingaccepted"{
                CommonClass.gotoLandingPage()
                NotificationCenter.default.post(name: Notification.Name(rawValue: GETPREBOOKINGACCEPTED), object: nil, userInfo: aps)
                
            }else if type == "ads"{
                
                
                
                if application.applicationState == UIApplicationState.inactive {
                    
                    CommonClass.gotoPromotionVC()
                    
                } else if application.applicationState == UIApplicationState.background {
                    CommonClass.gotoPromotionVC()
                    
                }else{
                    
                    notificationCount = notificationCount + 1
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION), object: nil, userInfo: nil)
                    
                    guard let viewController = (mfSideMenuContainerViewController.centerViewController as AnyObject).visibleViewController else{return}
                    
                    if viewController != nil {
                        
                        print_debug(aps)
                        let popUp = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "NotificationPopUpVC") as! NotificationPopUpVC
                        
                        popUp.modalPresentationStyle = .overCurrentContext
                        if let info = aps["aps"] as? JSON{
                            popUp.userInfo = NotificationModel(info)
                        }
                        
                        getMainQueue({
                            viewController!.present(popUp, animated: true, completion: nil)
                        })
                    }
                }
                
            }else if type == "promotion"{
                
                if application.applicationState == UIApplicationState.inactive {
                    
                    CommonClass.gotoPromotionVC()
                    
                } else if application.applicationState == UIApplicationState.background {
                    CommonClass.gotoPromotionVC()
                }
            }
        }
    }
    
    
    //MARK:- Check user login state

    func checkUserLoginStatus(){
        
        if CurrentUser.isUserLoggedIn{
            
            if CurrentUser.is_mobileVerified{
                
                if CurrentUser.isVehicle{
                    
                    CommonClass.gotoLandingPage()
                    
                }else{
                    
                    CommonClass.goToLogin()
                    
                }
            }else{
                
                CommonClass.goToLogin()
                
            }
        }else{
            
            if CurrentUser.ISFIRSTTIME == nil {
                
                UserDefaults.save(true, forKey: NSUserDefaultsKeys.ISFIRSTTIME)
                CommonClass.gotoTutorialScreen()
                
            }else{
                
                CommonClass.goToLogin()
                
            }
        }
    }

    //MARK:- Side menu button tap

    func leftSideMenuButtonPressed(_ sender: AnyObject?){
        
        //self.leftSidePannelVC.tblView.reloadData()
        mfSideMenuContainerViewController.leftMenuViewController.viewWillAppear(false)
        mfSideMenuContainerViewController.toggleLeftSideMenuCompletion({
        })
    }
    
    
    
    //MARK: Tabbarviewcontroller delegates
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController){
        
        let bgView1 = tabBarController.tabBar.viewWithTag(11211)
        let bgView2 = tabBarController.tabBar.viewWithTag(11212)
        let bgView3 = tabBarController.tabBar.viewWithTag(11213)
        
        switch tabBarController.selectedIndex {
            
        case 0:
            
            bgView1?.backgroundColor = .tabBar
            bgView2?.backgroundColor = .tabBarDeselected
            bgView3?.backgroundColor = .tabBarDeselected
            
        case 1:
            
            bgView2?.backgroundColor = .tabBar
            bgView1?.backgroundColor = .tabBarDeselected
            bgView3?.backgroundColor = .tabBarDeselected
            
        case 2:
            
            bgView3?.backgroundColor = .tabBar
            bgView2?.backgroundColor = .tabBarDeselected
            bgView1?.backgroundColor = .tabBarDeselected

        default:
            break
        }
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
    // MARK: Handle Memory Warning
    func applicationDidReceiveMemoryWarning(_ application: UIApplication){
        
        clearCache()
    }
    
    func clearCache(){
        //removeing SDWebImage Cache to clear memory
        SDWebImageManager.shared().imageCache.clearMemory()
        SDWebImageManager.shared().imageCache.clearDisk()
        SDWebImageManager.shared().imageCache.cleanDisk()
        URLCache.shared.removeAllCachedResponses()
        
    }

}
