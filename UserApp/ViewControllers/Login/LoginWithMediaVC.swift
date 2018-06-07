//
//  LoginWithMediaVC.swift
//  UserApp
//
//  Created by Appinventiv on 22/09/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import GoogleSignIn
import TwitterKit
import MFSideMenu
import SwiftyJSON

let Google_ClientID = "989165576362-9jqsc6nuojunilggnoq1rdbbkdj2c8hf.apps.googleusercontent.com"

class LoginWithMediaVC: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate{
    
    //MARK:- Variables
    //MARK:- *****************************************************************
    var userInfo = [String: String]()
    var isPushed = false
    
    //MARK:- IBOutlets
    //MARK:- *****************************************************************
    
    @IBOutlet weak var loginWithFbBtn: UIButton!
    @IBOutlet weak var loginWithTwitterBtn: UIButton!
    @IBOutlet weak var loginWithGoogleBtn: UIButton!
    @IBOutlet weak var loginWithEmailBtn: UIButton!
    @IBOutlet weak var registerNowBtn: UIButton!
    
    @IBOutlet weak var fbBgView: UIView!
    @IBOutlet weak var twitterBgView: UIView!
    @IBOutlet weak var googleBgView: UIView!
    @IBOutlet weak var emailBgView: UIView!
    @IBOutlet weak var registerBgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = Google_ClientID
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.login")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.me")
        self.fbBgView.layer.cornerRadius = 2
        self.twitterBgView.layer.cornerRadius = 2
        self.googleBgView.layer.cornerRadius = 2
        self.emailBgView.layer.cornerRadius = 2
        self.registerBgView.layer.cornerRadius = 2
        self.registerBgView.layer.borderColor = UIColor(red: 59 / 255, green: 27 / 255, blue: 40 / 255, alpha: 1).cgColor
        self.registerBgView.layer.borderWidth = 0.5
        
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.isPushed {
            UIApplication.shared.setStatusBarHidden(false, with: .slide)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        CommonClass.stopLoader()
    }
    
    //MARK:- IBActions
    //MARK:- *****************************************************************
    
    @IBAction func loginWithFbTapped(_ sender: AnyObject) {
        
        //CommonClass.startLoader("")
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        let permissionsMe:[AnyObject]!=["user_about_me" as AnyObject,
                                        "user_birthday" as AnyObject,
                                        "email" as AnyObject,
                                        "user_photos" as AnyObject,
                                        "user_events" as AnyObject,
                                        "user_friends" as AnyObject,
                                        "user_videos" as AnyObject,
                                        "public_profile" as AnyObject];
        
        fbLoginManager.loginBehavior = .native
        fbLoginManager.logIn(withReadPermissions: permissionsMe, handler: { (result, error) -> Void in
            if (error == nil){
                CommonClass.stopLoader()
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.isCancelled{
                    CommonClass.stopLoader()
                } else if(fbloginresult.grantedPermissions.contains("email")) {
                    CommonClass.startLoader("")
                    self.getFBUserData()
                    fbLoginManager.logOut()
                }
            }
            else {
                // #Warning add login for pop up
                CommonClass.stopLoader()
            }
        })
    }
    
    
    @IBAction func loginWithTwitterTapped(_ sender: UIButton) {
        
        CommonClass.startLoader("")
        
        Twitter.sharedInstance().logIn {(session, error) in
            if let s = session {
                print("logged in user with id \(s.userID)")
                
                var params = JSONDictionary()
                
                params["twt_id"] = s.userID
                params["action"] = "twitter"
                params["device_id"] = DeviceUUID
                params["device_token"] = APPDELEGATEOBJECT.device_Token
                
                params["device_model"] = DeviceModelName
                params["platform"] = OS_PLATEFORM
                params["os_version"] = SystemVersion_String 
                
                
                printlnDebug(params)
                
                CommonClass.startLoader("")
                ServiceController.loginApi(params as JSONDictionary, SuccessBlock: { (success,json) in
                    
                    let code = json["statusCode"].intValue
                    let result = json["result"]

                        CommonClass.stopLoader()
                        
                        if code == 200{
                            userdata.saveJSONDataToUserDefault(result)
                            CommonClass.reconnectSocket()

                            CommonClass.gotoLandingPage()

                        }
                        else if code == 219{
                            
                            userdata.saveJSONDataToUserDefault(result)
                            let obj = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "MobileVerificationViewController") as! MobileVerificationViewController
                            self.navigationController?.pushViewController(obj, animated: true)
                            
                        }
                        else if code == 235{
                            
                            let obj = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "ProfileSetUpVC") as! ProfileSetUpVC
                            let client =  TWTRAPIClient(userID: s.userID)
                            
                            client.loadUser(withID: s.userID, completion: { (user, error) -> Void in
                                
                                if let currentuser = user{
                                    printlnDebug(currentuser.profileImageLargeURL)
                                    obj.userEditDataDict["imageName"] =  "\(currentuser.profileImageLargeURL)"
                                }
                            })

                            obj.userEditDataDict["twt_id"] = s.userID
                            obj.userMediaData["isEditable"] = "y" as AnyObject
                            obj.userEditDataDict["full_name"] = s.userName
                            
                            self.navigationController?.pushViewController(obj, animated: true)
                        }
                        else{
                        }
                        
                    
                    }, failureBlock: { (error) in
                        CommonClass.stopLoader()
                        printlnDebug(error)
                })
                
                
            } else {
                // log error
            }
        }
    }
    
    @IBAction func loginWithoogleTapped(_ sender: UIButton) {
        
        CommonClass.startLoader("")
        
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    @IBAction func loginWithEmailTapped(_ sender: UIButton) {
        
        
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func registerNowTapped(_ sender: UIButton) {
        
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(obj, animated: true)
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
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                withError error: Error!) {
        if (error == nil) {
            
            // Perform any operations on signed in user here.
            self.userInfo["userId"] = user.userID
            self.userInfo["idToken"] = user.authentication.idToken
            self.userInfo["fullName"] = user.profile.name
            self.userInfo["email"] = user.profile.email
            let imageUrl = signIn.currentUser.profile.imageURL(withDimension: 120)
            printlnDebug(imageUrl)
            printlnDebug(self.userInfo)
            var params = JSONDictionary()
            
            params["email"] = user.profile.email as AnyObject
            params["action"] = "google" as AnyObject
            params["google_id"] = user.userID as AnyObject
            params["device_id"] = DeviceUUID as AnyObject
                params["device_token"] = APPDELEGATEOBJECT.device_Token as AnyObject
            params["device_model"] = DeviceModelName as AnyObject
            params["platform"] = OS_PLATEFORM as AnyObject
            params["os_version"] = SystemVersion_String as AnyObject
            
            printlnDebug(params)
            CommonClass.startLoader("")
            ServiceController.loginApi(params, SuccessBlock: { (success,json) in
                
                CommonClass.stopLoader()
                let result = json["result"]

                let code = json["statusCode"].intValue
                    
                    if code == 200{
                        userdata.saveJSONDataToUserDefault(result)
                        CommonClass.reconnectSocket()

                        CommonClass.gotoLandingPage()
                    }
                    else if code == 219{
                        
                        userdata.saveJSONDataToUserDefault(result)

                        let obj = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "MobileVerificationViewController") as! MobileVerificationViewController
                        obj.email = user.profile.email
                        self.navigationController?.pushViewController(obj, animated: true)
                        
                    }
                    else if code == 235{
                        let obj = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "ProfileSetUpVC") as! ProfileSetUpVC
                        
                        obj.userEditDataDict["full_name"] = user.profile.name
                        obj.userEditDataDict["email"] = user.profile.email
                        obj.userEditDataDict["google_id"] = user.userID
                        obj.userEditDataDict["imageName"] = "\(String(describing: imageUrl!))"
                        obj.userMediaData["isEditable"] = "n" as AnyObject

                        
                        self.navigationController?.pushViewController(obj, animated: true)
                    }
                    else{
                    }
                    
                
                }, failureBlock: { (error) in
                    CommonClass.stopLoader()
            })
            
            
            
        }
        else {
            print("\(error.localizedDescription)")
        }
    }
    
    
    func getFBUserData(){
        
        if((FBSDKAccessToken.current()) != nil){
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email,birthday"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    
                    var params = JSONDictionary()
                    
                    printlnDebug(result)
                    
                    let fdData = JSON(result ?? [:])
                    print_debug(fdData)
                    let email = fdData["email"].stringValue
                    let id = fdData["id"].stringValue
                    let dob = fdData["birthday"].stringValue
                    let name = fdData["name"].stringValue
                    let image = fdData["picture"]["data"]["url"].stringValue
                    
                    params["email"] = email
                    params["fb_id"] = id
                    //params["dob"] = dob
                    params["action"] = "fb" as AnyObject
                    params["device_id"] = DeviceUUID as AnyObject
                    params["device_token"] = APPDELEGATEOBJECT.device_Token
                    params["device_model"] = DeviceModelName as AnyObject
                    params["platform"] = OS_PLATEFORM as AnyObject
                    params["os_version"] = SystemVersion_String as AnyObject
                    
                    printlnDebug(params)
                    CommonClass.startLoader("")
                    
                    ServiceController.loginApi(params as JSONDictionary, SuccessBlock: { (success,json) in
                        
                        printlnDebug(json)
                        
                        let result = json["result"]
                        
                         let code = json["statusCode"].intValue
                            
                            if code == 200{
                                
                                userdata.saveJSONDataToUserDefault(result)
                                CommonClass.reconnectSocket()

                                CommonClass.gotoLandingPage()
                            }
                                
                            else if code == 235{
                                
                                let obj = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "ProfileSetUpVC") as! ProfileSetUpVC
                                
                                
                                if email.isEmpty{
                                    
                                    obj.userMediaData["isEditable"] = "y" as AnyObject
                                }
                                else{
                                    
                                    obj.userMediaData["isEditable"] = "n" as AnyObject

                                }
                                
                                obj.userEditDataDict["email"] = email
                                obj.userEditDataDict["full_name"] = name
                                obj.userEditDataDict["dob"] = self.setDateFormat(dob)
                                obj.userEditDataDict["imageName"] = image
                                obj.userEditDataDict["fb_id"] = id
                                
                                self.navigationController?.pushViewController(obj, animated: true)
                            }
                            else if code == 219{
                                
                                userdata.saveJSONDataToUserDefault(result)

                                    let obj = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "MobileVerificationViewController") as! MobileVerificationViewController
                                
                                        obj.email = result["email"].stringValue
                                        obj.mobileNumberText = result["phone"].stringValue
                                        obj.code = result["country_code"].stringValue
                                
                                    self.navigationController?.pushViewController(obj, animated: true)
                            }
                        
                        }, failureBlock: { (error) in
                            CommonClass.stopLoader()
                    })
                    
                }
            })
        }
    }
    
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
