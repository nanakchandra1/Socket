//
//  AppDelegate.swift
//  UserApp
//
//  Created by Appinventiv on 16/09/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import TwitterKit
import GoogleMaps
import MFSideMenu
import Crashlytics
import SDWebImage
import Stripe
import  UserNotifications
import SwiftyJSON

var notificationCount = 0

let APPDELEGATEOBJECT = (UIApplication.shared.delegate as! AppDelegate)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UITabBarDelegate,UITabBarControllerDelegate{
    
    var window: UIWindow?
    var device_Token = "123456"
    var stausTimer = Timer()
    var pushData : PushPayLoad?
    var nvc: UINavigationController!

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey(APIKeys.googleMapsApiKey)
        STPPaymentConfiguration.shared().publishableKey = APIKeys.stripApiKey
        
        
        let handler: VoiceeCountryHandler = VoiceeCountryHandler()
        handler.prepareDataBace()
        
        Fabric.with([Twitter.self, Crashlytics.self])
        
        getMainQueue(){
            self.initialSetup(application, didFinishLaunchingWithOptions: launchOptions)
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        
        self.RegisterForPushNotification()
        
        self.checkUserLoginStatus()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    
    func RegisterForPushNotification() {
        
        if #available(iOS 10.0, *) {
            
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
            }
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            
            // Fallback on earlier versions
            let settings = UIUserNotificationSettings(types: [UIUserNotificationType.sound,UIUserNotificationType.alert,UIUserNotificationType.badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if #available(iOS 9.0, *) {
            let _: [String: AnyObject] = [UIApplicationOpenURLOptionsKey.sourceApplication.rawValue: sourceApplication! as AnyObject,
                                          UIApplicationOpenURLOptionsKey.annotation.rawValue: annotation as AnyObject]
        } else {
            // Fallback on earlier versions
        }
        
        if url.scheme == "fb185550875294957" {
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    
    
    
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) -> Void{
        
        let characterSet: CharacterSet = CharacterSet( charactersIn: "<>" )
        var token = ""
        for i in 0..<deviceToken.count {
            
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        
        token = token.trimmingCharacters(in: characterSet)
        
        token = token.replacingOccurrences(of: " ", with: "")
        
        if !token.isEmpty{
            
            self.device_Token = token
        }else
        {
            self.device_Token = "123456"
        }
    }
    
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        let aps = (userInfo as? [String: AnyObject])!
        print_debug(aps)
        if let info = aps["aps"] as? [String : AnyObject] {
            print_debug(info)
            self.pushData = PushPayLoad(withPayLoad: info)
        } else { return }
        
        if application.applicationState == UIApplicationState.inactive {
            
            self.showPopUp(aps, application: application)
            
        } else if application.applicationState == UIApplicationState.background {
            self.showPopUp(aps, application: application)
            
        }
        else {
            self.showPopUp(aps, application: application)
        }
    }
    
    
    func handleRemotePush(_ infoDict:[String : AnyObject],application: UIApplication){
        
        self.showPopUp(infoDict, application: application)
        
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        self.application(application, didReceiveRemoteNotification: userInfo)
    }
    
    
    
    

    
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: SATRTANIMATE), object: nil, userInfo: nil)
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if CurrentUser.isUserLoggedIn{
            
                SocketManegerInstance.connectSocket(handler: { () in
                
            })
        }
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.res.UserApp" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "UserApp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
}


struct PushPayLoad {
    
    let alert:String!
    let pushId : String!
    let pushType: String!
    
    init(withPayLoad : [String : AnyObject]) {
        self.pushId = withPayLoad["push_id"] as? String ?? ""
        self.alert = withPayLoad["alert"] as? String ?? ""
        self.pushType = withPayLoad["push_type"] as? String ?? ""
    }
}
