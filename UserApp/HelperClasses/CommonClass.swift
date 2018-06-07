
//
//  CommonClass.swift
//  UserApp
//
//  Created by Appinventiv on 16/09/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration
import MFSideMenu


class CommonClass {
    
    class func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
    
    class func getJsonObject(_ Detail: Any) -> String{
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
    
    
    class func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    
    class func goToLogin(){
        
        UserDefaults.clearUserDefaults()
        
        selectedIndex = 0

        let vc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "LoginWithMediaVC") as! LoginWithMediaVC
        sharedAppdelegate.nvc = UINavigationController(rootViewController: vc)
        sharedAppdelegate.nvc.isNavigationBarHidden = true
        sharedAppdelegate.nvc.automaticallyAdjustsScrollViewInsets=false
        
        sharedAppdelegate.window?.rootViewController = sharedAppdelegate.nvc
        
    }
    
    
    class func gotoLandingPage(){
        
        if CurrentUser.isVehicle{
            
            UserDefaults.save(true as AnyObject, forKey: NSUserDefaultsKeys.ISUSERLOGGEDIN)
            let leftMenuVC = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "LeftSidePannelViewController") as! LeftSidePannelViewController
            
            let tabBarCantroller = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "BaseTabBarController") as! BaseTabBarController
            //tabBarCantroller.tabBar.delegate = sharedAppdelegate
            tabBarCantroller.delegate = APPDELEGATEOBJECT
            
            sharedAppdelegate.nvc = UINavigationController(rootViewController: tabBarCantroller)
            sharedAppdelegate.nvc.isNavigationBarHidden = true
            sharedAppdelegate.nvc.automaticallyAdjustsScrollViewInsets=false
            tabBarCantroller.selectedIndex = 0
            let container:MFSideMenuContainerViewController =
                MFSideMenuContainerViewController.container(withCenter: sharedAppdelegate.nvc, leftMenuViewController: leftMenuVC, rightMenuViewController: nil)
            mfSideMenuContainerViewController = container
            container.leftMenuWidth = screenWidth - 100
            sharedAppdelegate.window?.rootViewController = container;
            
        } else {
            
            let obj = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "AddVehicleViewController") as! AddVehicleViewController
            
            sharedAppdelegate.nvc?.pushViewController(obj, animated: true)
            
        }
    }
    
    
    class func gotoHomeVC(){
        
        
        sharedAppdelegate.stausTimer.invalidate()
        let tabBarCantroller = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "BaseTabBarController") as! BaseTabBarController
        tabBarCantroller.delegate = APPDELEGATEOBJECT
        sharedAppdelegate.nvc = UINavigationController(rootViewController: tabBarCantroller)
        sharedAppdelegate.nvc.isNavigationBarHidden = true
        sharedAppdelegate.nvc.automaticallyAdjustsScrollViewInsets=false
        tabBarCantroller.selectedIndex = 0
        mfSideMenuContainerViewController.centerViewController = sharedAppdelegate.nvc
        //mfSideMenuContainerViewController.toggleLeftSideMenuCompletion {}
        
    }
    
    class func gotoTutorialScreen(){
        
        let vc = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        
        sharedAppdelegate.nvc = UINavigationController(rootViewController: vc)
        sharedAppdelegate.nvc.isNavigationBarHidden = true
        sharedAppdelegate.nvc.automaticallyAdjustsScrollViewInsets = false
        sharedAppdelegate.window?.rootViewController = sharedAppdelegate.nvc
        sharedAppdelegate.window?.makeKeyAndVisible()
        
    }
    
   class func gotoPromotionVC(){
        
        let settingsScene = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "PromotionsVC") as! PromotionsVC
        sharedAppdelegate.nvc = UINavigationController(rootViewController: settingsScene)
        sharedAppdelegate.nvc.isNavigationBarHidden = true
        sharedAppdelegate.nvc.automaticallyAdjustsScrollViewInsets = false
        mfSideMenuContainerViewController.centerViewController = sharedAppdelegate.nvc
        selectedIndex = 7
    }
    
   class func gotoNotificationVC(){
        
        let settingsScene = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        sharedAppdelegate.nvc = UINavigationController(rootViewController: settingsScene)
        sharedAppdelegate.nvc.isNavigationBarHidden = true
        sharedAppdelegate.nvc.automaticallyAdjustsScrollViewInsets = false
        mfSideMenuContainerViewController.centerViewController = sharedAppdelegate.nvc
        selectedIndex = 4
    }

    class func gotoVehicleVC(){
        
        let settingsScene = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "AddVehicleViewController") as! AddVehicleViewController
        sharedAppdelegate.nvc = UINavigationController(rootViewController: settingsScene)
        sharedAppdelegate.nvc.isNavigationBarHidden = true
        sharedAppdelegate.nvc.automaticallyAdjustsScrollViewInsets = false
        mfSideMenuContainerViewController.centerViewController = sharedAppdelegate.nvc
        selectedIndex = 4
    }

    
    class var isConnectedToNetwork : Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
    
    
    class func reconnectSocket(){
    
        SocketManegerInstance = SocketIOManager()
        
        SocketManegerInstance.connectSocket(handler: { (data) in
    
    })
}
    
    //MARK: Show/Hide loader
    
    class func startLoader(_ messege: String){
        Loader.showLoader()
    }
    
    class func stopLoader(){
        Loader.hideLoader()
        
    }
    
    

}

func printlnDebug <T> (_ object: T) {
    
    print(object)
}


func print_debug <T> (_ object: T) {
    
    print(object)
}

func makeLbl(view: UIView,msg: String, color: UIColor) -> UILabel{
    
    let tablelabel = UILabel(frame: CGRect(x: view.center.x, y: view.center.y, width: view.frame.width, height: view.frame.height))
    
    tablelabel.font = UIFont(name:fontName , size: 15)
    
    tablelabel.textColor = color
    
    tablelabel.textAlignment = .center
    
    tablelabel.text = msg.localized
    
    return tablelabel
    
}

func showNodata(_ data: [Any], tableView: UITableView, msg: String, color: UIColor){
    
    if data.isEmpty{
        
        tableView.backgroundView = makeLbl(view: tableView, msg: msg.localized, color: color)
        
        tableView.backgroundView?.isHidden = false
        
    }else{
        
        tableView.backgroundView?.isHidden = true
        
    }
    
}

