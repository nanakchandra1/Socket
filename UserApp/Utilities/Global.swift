//
//  Global.swift
//  DriverApp
//
//  Created by saurabh on 06/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation
import UIKit


//MARK: APPDELEGATE
let sharedAppdelegate = (UIApplication.shared.delegate as! AppDelegate)


// MARK: SCREEN
let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height
let screenSize = UIScreen.main.bounds.size



let fontName = "SFUIDisplay-Regular"


// MARK: Device
let IsIPhone = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
let IsIPad = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad

// MARK: OS
let SystemVersion_String : String = UIDevice.current.systemVersion
let SystemVersion_Float : Float = (SystemVersion_String as NSString).floatValue
let SystemVersion_Int : Int = Int(SystemVersion_Float)

var DeviceModelName:String{
    if let modelName = UIDevice.current.modelName{
        
        return modelNameString(modelName)
    }
    return "iPhone"
}

var DeviceUUID:String {
    
    return UIDevice.current.identifierForVendor!.uuidString
}

let IS_IOS8  = SystemVersion_String.hasPrefix("8")
let IS_IOS9  = SystemVersion_String.hasPrefix("9")
let IS_IOS10  = SystemVersion_String.hasPrefix("10")

let IS_GreaterThanIOS8 = SystemVersion_Int > 8
let IS_GreaterThanIOS9 = SystemVersion_Int > 9

let IS_BelowThanIOS9 = SystemVersion_Int < 9
let IS_BelowThanIOS10 = SystemVersion_Int < 10

let IS_GreaterThanOrEqualToIOS8 = SystemVersion_Int >= 8
let IS_GreaterThanOrEqualToIOS9 = SystemVersion_Int >= 9

let IS_BelowThanOrEqualToIOS9 = SystemVersion_Int <= 9
let IS_BelowThanOrEqualToIOS10 = SystemVersion_Int <= 10

let Begin_UserInteraction: Void = UIApplication.shared.endIgnoringInteractionEvents()
let End_UserInteraction: Void = UIApplication.shared.endIgnoringInteractionEvents()

var isIPhoneSimulator:Bool{
    
    var isSimulator = false
    #if arch(i386) || arch(x86_64)
        //simulator
        isSimulator = true
    #endif
    return isSimulator
}



// MARK: ================
// MARK: GLOBAL FUNCTIONS
// MARK: ================


func hideContentController(_ content: UIViewController) {
    
    content.willMove(toParentViewController: nil)
    content.view.removeFromSuperview()
    content.removeFromParentViewController()
}



func delay(_ delay:Double, closure:@escaping ()->()) {
    
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
        execute: closure
    )
}

func getMainQueue(_ closure:@escaping ()->()){
    
    DispatchQueue.main.async(execute: {
        closure()
    })
}

//func getBackgroundQueue(_ closure:@escaping ()->()){
//    
//    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
//        closure()
//    })
//}

//MARK: Webservices Handling
func getIntValue(_ value:AnyObject?) -> Int? {
    if let v = value {
        let intValueStr = "\(v)"
        return Int(intValueStr)
    }
    return nil
}

func getStringValue(_ value:AnyObject?) -> String? {
    if let anyValue = value {
        return "\(anyValue)"
    }
    return nil
}


func getBoolValue(_ value:AnyObject?) -> Bool? {
    
    if value is String {
        
        return ((value as! String) == "0" || (value as! String).lowercased() == "false") ? false : true
    }
    
    if value is Int {
        
        return (value as! Int) == 0 ? false : true
    }
    
    if value is Bool {
        
        return (value as! Bool)
    }
    
    return nil
}

func setTextFieldPlaceHolderTextColor(_ textField:UITextField,color:UIColor){
    
    let str = NSAttributedString(string: "Text", attributes: [NSForegroundColorAttributeName:color])
    textField.attributedPlaceholder = str
}

// to find index of an object in collection types
//func find<C: Collection>(_ collection: C, predicate: (C.Iterator.Element) -> Bool) -> C.Index? {
//    for index in collection.startIndex ..< collection.endIndex {
//        if predicate(collection[index]) {
//            return index
//        }
//    }
//    return nil
//}

//MARK:
//MARK:Remove object from user defaults
func removeFromUserDefaults(_ key:String?){
    
    if(key != nil){
        
        let standardUserDefaults=UserDefaults.standard
        standardUserDefaults.removeObject(forKey: key! as String)
        standardUserDefaults.synchronize()
    }
}
//MARK:
//MARK:Get value from user defaults

func userDefaultsForKey(_ key:NSString?)-> AnyObject?{
    
    if(key != nil){
        
        let standardUserDefaults=UserDefaults.standard
        return standardUserDefaults.object(forKey: key! as String) as AnyObject
    }
    return nil
}
//MARK:
//MARK:User defaults insertion/retrive/removal
func saveToUserDefaults(_ object:AnyObject, withKey key:NSString){
    
    let standardUserDefaults=UserDefaults.standard
    standardUserDefaults.set(object, forKey: key as String)
    standardUserDefaults.synchronize()
}

//MARK:
//MARK: Check for empty value in dictionary
func checkforEmptyValueinDictioanty(_ dic:NSDictionary)-> Bool{
    
    //for (keyVal, dataVal) in dic
    for (_, dataVal) in dic {
        
        if ((dataVal as AnyObject).length()==0){
            return false
        }
    }
    return true
}

//MARK:
//MARK: Phone number validation

func isValidPhoneNumber(_ value: String) -> Bool {
    
    do
    {
        let regex = try NSRegularExpression(pattern: "[0123456789]{6,10}", options: .caseInsensitive)
        return regex.firstMatch(in: value, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, value.characters.count)) != nil
        
    } catch {
        return false
    }
}

//MARK:
//MARK: Email validation

func isValidEmail(_ testStr:String) -> Bool {
    
    do {
        let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: testStr, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, testStr.characters.count)) != nil
    } catch {
        return false
    }
}
//MARK:
//MARK: Dial Phone Number
func dialPhoneNumer(_ phoneNumer:String){
    
    let url = URL(string: "telprompt://\(phoneNumer)")!
    UIApplication.shared.openURL(url)
}
func sendMail(_ phoneNumer:String){
    let url = URL(string: "mailto://\(phoneNumer)")!
    UIApplication.shared.openURL(url)
}
//MARK:
//MARK: Get indexPath/cell from tableView/collectionView
func tableViewCellForItem(_ item: AnyObject, inTable tableView: UITableView) -> UITableViewCell? {
    if let indexPath = tableViewIndexPathforCellItem(item, inTable: tableView){
        return tableView.cellForRow(at: indexPath)
    }
    return nil
}

func tableViewIndexPathforCellItem(_ item: AnyObject, inTable tableView: UITableView) -> IndexPath? {
    let buttonPosition: CGPoint = item.convert(CGPoint.zero, to: tableView)
    return tableView.indexPathForRow(at: buttonPosition)
}

func collectionViewCellForItem(_ item: AnyObject, inCollectionView collectionView: UICollectionView) -> UICollectionViewCell? {
    if let indexPath = collectionViewIndexPathforCellItem(item, inCollectionView: collectionView){
        return collectionView.cellForItem(at: indexPath)
    }
    return nil
}

func collectionViewIndexPathforCellItem(_ item: AnyObject, inCollectionView collectionView: UICollectionView) -> IndexPath? {
    let buttonPosition: CGPoint = item.convert(CGPoint.zero, to: collectionView)
    return collectionView.indexPathForItem(at: buttonPosition)
}

//MARK:
//MARK: Calculate the size of text
func textSizeCount(_ text: String?, font: UIFont, bundingSize size: CGSize) -> CGSize {
    
    if text == nil{
        return CGSize.zero
    }
    let mutableParagraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
    mutableParagraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
    let attributes: [String : AnyObject] = [NSFontAttributeName: font, NSParagraphStyleAttributeName: mutableParagraphStyle]
    let tempStr = NSString(string: text!)
    
    let rect: CGRect = tempStr.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
    let height = ceilf(Float(rect.size.height))
    let width = ceilf(Float(rect.size.width))
    return CGSize(width: CGFloat(width), height: CGFloat(height))
}


func getFirstCharOfString(_ str : String) -> Character {
    
    return str[str.characters.index(str.startIndex, offsetBy: 0)]
}

func getLastCharOfString(_ str : String) -> Character {
    
    return str[str.characters.index(str.endIndex, offsetBy: -1)]
}

func modelNameString(_ identifier:String)->String{
    
    switch identifier {
    case "iPod5,1":                                 return "iPod Touch 5"
    case "iPod7,1":                                 return "iPod Touch 6"
    case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
    case "iPhone4,1":                               return "iPhone 4s"
    case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
    case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
    case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
    case "iPhone7,2":                               return "iPhone 6"
    case "iPhone7,1":                               return "iPhone 6 Plus"
    case "iPhone8,1":                               return "iPhone 6s"
    case "iPhone8,2":                               return "iPhone 6s Plus"
    case "iPhone8,4":                               return "iPhone SE"
    case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
    case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
    case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
    case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
    case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
    case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
    case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
    case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
    case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
    case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
    case "AppleTV5,3":                              return "Apple TV"
    case "i386", "x86_64":                          return "Simulator"
    default:                                        return identifier
        
    }
}


//MARK:- Extension To Get Device Name
//MARK:-
public extension UIDevice {
    
    var modelName: String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafeMutablePointer(to: &systemInfo.machine) { ptr in String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }
    }
}

//MARK:- Hide or Show Status Bar
//MARK:-
//func hideStatusBar(_ viewController:UIViewController) {
//    
//    _ = UIViewController.prefersStatusBarHidden(viewController)
//}

func rotateImage(_ src: UIImage, left: Bool) -> UIImage {
    
    var angleDegrees: Float = 90
    if left {
        angleDegrees = -angleDegrees
    }
    let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: src.size.width, height: src.size.height))
    let angleRadians: CGFloat = CGFloat(angleDegrees * Float((Double.pi)))
    let t: CGAffineTransform = CGAffineTransform(rotationAngle: angleRadians)
    rotatedViewBox.transform = t
    let rotatedSize: CGSize = rotatedViewBox.frame.size
    UIGraphicsBeginImageContext(rotatedSize)
    let bitmap: CGContext = UIGraphicsGetCurrentContext()!
    bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
    bitmap.rotate(by: angleRadians)
    bitmap.scaleBy(x: 1.0, y: -1.0)
    bitmap.draw(src.cgImage!, in: CGRect(x: -src.size.width / 2, y: -src.size.height / 2, width: src.size.width, height: src.size.height))
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
}

//MARK:
//MARK: SAVE IMAGE TO DOCUMENT DIRECTORY
func saveImageToDocumentDirectory(_ image:UIImage,path:NSString)->NSString{
    
    let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
    let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
    let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
    if paths.count > 0 {
        let dirPath = paths[0]
        
        let writePath = (dirPath as NSString).appendingPathComponent("\(path).png")
        try? UIImagePNGRepresentation(image)!.write(to: URL(fileURLWithPath: writePath), options: [.atomic])
        return writePath as NSString
    }
    return ""
}

//MARK:- Set Orientation for Device
func setDeviceOrientation(_ orientation:UIDeviceOrientation){
    
    let value = orientation.rawValue
    if (orientation == UIDeviceOrientation.landscapeLeft){
        UIApplication.shared.setStatusBarOrientation(UIInterfaceOrientation.landscapeRight, animated: false)
    }
    else if (orientation == UIDeviceOrientation.landscapeRight){
        UIApplication.shared.setStatusBarOrientation(UIInterfaceOrientation.landscapeRight, animated: false)
    }
    else if (orientation == UIDeviceOrientation.portraitUpsideDown){
        UIApplication.shared.setStatusBarOrientation(UIInterfaceOrientation.portraitUpsideDown, animated: false)
    }
    else{
        UIApplication.shared.setStatusBarOrientation(UIInterfaceOrientation.portrait, animated: false)
    }
    UIDevice.current.setValue(value, forKey: "orientation")
    
}

//MARK:- To Send The Application In to Sleep Mode After Some Time
func disableApplicationIdelTimer(_ flag: Bool) {
    UIApplication.shared.isIdleTimerDisabled = flag
}


//MARK:- Add/Remove Child View Controller
func addChildVC(_ childVC:UIViewController, parentVC:UIViewController){
    
    parentVC.addChildViewController(childVC)
    childVC.view.frame = parentVC.view.bounds
    parentVC.view.addSubview(childVC.view)
    childVC.didMove(toParentViewController: parentVC)
}
func removeChildVC(_ childVC:UIViewController){
    
    childVC.willMove(toParentViewController: nil)
    childVC.view.removeFromSuperview()
    childVC.removeFromParentViewController()
}

//MARK:- Print Core Data URL
func printCoreDataURL() {
    
    print_debug(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
}

//MARk:-
//MARK:- shake Animation

func shakeView(_ vw: UIView) {
    
    let animation = CAKeyframeAnimation()
    animation.keyPath = "position.x"
    animation.values = [0, 10, -10, 10, -5, 5, -5, 0 ]
    animation.keyTimes = [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1]
    animation.duration = 0.4
    animation.isAdditive = true
    vw.layer.add(animation, forKey: "shake")
}


//MARk:-
//MARK:- Gradient color

func turquoiseColor() -> CAGradientLayer {
    let topColor = UIColor(red: 80.0/255.0, green: 46.0/255.0, blue: 85.0/255.0, alpha: 1.0)
    let bottomColor = UIColor(red: 117.0/255.0, green: 68.0/255.0, blue: 106.0/255.0, alpha: 1.0)
    let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
    let gradientLocations: [Float] = [0.0, 1.0]
    let gradientLayer: CAGradientLayer = CAGradientLayer()
    gradientLayer.colors = gradientColors
    gradientLayer.locations = gradientLocations as [NSNumber]
    
    return gradientLayer
}


class Colors {
    let colorTop = UIColor(red: 80.0/255.0, green: 46.0/255.0, blue: 85.0/255.0, alpha: 1.0).cgColor
    let colorBottom = UIColor(red: 117.0/255.0, green: 68.0/255.0, blue: 106.0/255.0, alpha: 1.0).cgColor
    
    let gl: CAGradientLayer
    
    init() {
        gl = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [0.0, 1.0]
    }
}

func gradientColor(_ view : UIView){
    let gradientLayerView: UIView = UIView(frame: view.bounds)
    let gradient: CAGradientLayer = CAGradientLayer()
    gradient.frame = gradientLayerView.bounds
    gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.black.cgColor, UIColor.black.cgColor]
    gradientLayerView.layer.insertSublayer(gradient, at: 0)
    view.layer.insertSublayer(gradientLayerView.layer, at: 0)
}

//MARK:-
//MARK:- ATTRIBUTED STRING METHOD
func getDocumentsDirectory() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
    let documentsDirectory = paths[0]
    return documentsDirectory as NSString
}

//MARK: Show Toast

 func showToastWithMessage(_ msg : String) {
    let config = GTToastConfig(
        contentInsets: UIEdgeInsets(top:10, left: 20, bottom: 10, right: 10),
        cornerRadius: 8.0,
        font: UIFont.systemFont(ofSize: 11),
        textColor: UIColor.white,
        textAlignment: NSTextAlignment.left,
        backgroundColor: UIColor.black.withAlphaComponent(0.8),
        animation: GTToastAnimation.scale,
        displayInterval: 2,
        bottomMargin: 15.0,
        imageAlignment: GTToastAlignment.top,
        maxImageSize: CGSize(width: 100,height: 100)
    )
    GTToast.create(msg, config: config, image: nil).show()
}


// MARK: Set anchor point correctly for a view
func setAnchorPoint(_ anchorPoint: CGPoint, forView view: UIView) {
    var newPoint = CGPoint(x: view.bounds.size.width * anchorPoint.x, y: view.bounds.size.height * anchorPoint.y)
    var oldPoint = CGPoint(x: view.bounds.size.width * view.layer.anchorPoint.x, y: view.bounds.size.height * view.layer.anchorPoint.y)
    
    newPoint = newPoint.applying(view.transform)
    oldPoint = oldPoint.applying(view.transform)
    
    var position = view.layer.position
    position.x -= oldPoint.x
    position.x += newPoint.x
    
    position.y -= oldPoint.y
    position.y += newPoint.y
    
    view.layer.position = position
    view.layer.anchorPoint = anchorPoint
}



//MARK:- corner radius
func cornerLayer(_ viewBounds:CGRect,corners:UIRectCorner,cgsizeWidth:CGFloat,cgsizeHeight:CGFloat) -> CAShapeLayer{
    let maskPath = UIBezierPath(roundedRect: viewBounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cgsizeWidth, height: cgsizeHeight))
    let maskLayer = CAShapeLayer()
    maskLayer.frame = viewBounds
    maskLayer.path = maskPath.cgPath
    return maskLayer
}




//MARK: Open Settings

func openSettings(){
    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
}


//MARK: Get storyboard

func getStoryboard(_ name:String)->UIStoryboard{
    
    return UIStoryboard(name: name, bundle: nil)
}


//MARK: Check if network is available

//func isNetworkAvailable() -> Bool{
//    
//    var isNetworkAvalable=true
//    
//    if !(Reachability.isNetworkAvailable()){
//        isNetworkAvalable=false
//        getMainQueue({
//            showToastWithMessage("CONNECTION_ERROR".localized())
//        })
//        hideLoader()
//    }
//    return isNetworkAvalable
//}



//MARK: Set side pannel menu button

extension UIView{
    
func setMenuButton(){
    
    let btnImgNormal=UIImage(named: "hamburger")!
    let btnImgHighlighted = UIImage(named: "hamburger")!
    let button   = UIButton(type: UIButtonType.custom)
    button.backgroundColor = UIColor.clear
    button.setImage(btnImgNormal, for:UIControlState())
    button.setImage(btnImgHighlighted, for:UIControlState.highlighted);
    button.frame = CGRect(x: 5, y: 0, width: 40, height: 44)
    button.addTarget(sharedAppdelegate, action: Selector(("leftSideMenuButtonPressed:")), for: UIControlEvents.touchUpInside)
    self.addSubview(button)
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

