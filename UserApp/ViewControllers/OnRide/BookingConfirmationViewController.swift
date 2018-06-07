//
//  BookingConfirmationViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/20/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import SwiftyJSON

class BookingConfirmationViewController: UIViewController {
    
    // IBOutlets
    //MARK:- =================================================
    
    @IBOutlet weak var bookingTimeBtn: UIButton!
    @IBOutlet weak var congratulationsLabel: UILabel!
    @IBOutlet weak var bookingIdLabel: UILabel!
    @IBOutlet weak var estimatedTimelLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var termsOfCancelationLbl: UILabel!
    @IBOutlet weak var firstTermsLbl: UILabel!
    @IBOutlet weak var secondTermsLbl: UILabel!
    @IBOutlet weak var driverDetailView: UIView!
    @IBOutlet weak var driverImageView: UIImageView!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var driverMobileNumberLabel: UILabel!
    @IBOutlet weak var verticalSpaceBetweenDriverNameLabelAndDriverDetailView: NSLayoutConstraint!
    
    var tripDetail = RideDetailModel()
    var ride_id:String!
    var estimatedDistance : Float = 0.0
    
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        printlnDebug(tripDetail)
        self.initialSetup()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.driverImageView.layer.cornerRadius = self.driverImageView.frame.size.height/2
        
        if IsIPhone {
            self.verticalSpaceBetweenDriverNameLabelAndDriverDetailView.constant = 10 + self.driverImageView.frame.size.height/2
            self.driverDetailView.frame.size.height = self.verticalSpaceBetweenDriverNameLabelAndDriverDetailView.constant + 51
        } else if IsIPad{
            self.verticalSpaceBetweenDriverNameLabelAndDriverDetailView.constant = 15 + self.driverImageView.frame.size.height/2
            self.driverDetailView.frame.size.height = self.verticalSpaceBetweenDriverNameLabelAndDriverDetailView.constant + 91
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK:- Private Methods
    //MARK:- =================================================
    
    func initialSetup() {
        
        
        self.bookingTimeBtn.layer.borderColor = UIColor.gray.cgColor
        self.bookingTimeBtn.layer.borderWidth = 1
        self.bookingTimeBtn.layer.cornerRadius = 3
        self.bookingTimeBtn.clipsToBounds = true
        
        self.driverImageView.layer.borderColor = UIColor(red: 214/255, green: 0, blue: 84/255, alpha: 1).cgColor
        
        self.driverImageView.layer.borderWidth = 2
        self.driverImageView.clipsToBounds = true
        let last4 = self.ride_id.substring(from: self.ride_id.index(self.ride_id.endIndex, offsetBy: -6))
        self.bookingIdLabel.text = "Your Booking Id: \(last4)"
        
        printlnDebug(self.tripDetail)
        
       // let driver_detail = self.tripDetail["driver_detail"] as! JSON
        
        
        
            self.driverNameLabel.text = self.tripDetail.driver_name
            self.driverMobileNumberLabel.text = self.tripDetail.driver_contact
            let imageUrlStr = "http://52.76.76.250/" + self.tripDetail.driver_image
            
            if let imageUrl = URL(string: imageUrlStr){
                
                self.driverImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
            }
            
            self.calcEta("\(self.tripDetail.pickup_lat),\(self.tripDetail.pickup_long)|", destination: "\(self.tripDetail.driver_lat),\(self.tripDetail.driver_long)|")
        
    }
    
    
    // calculate eta
    
    func calcEta(_ source:String,destination:String){
        self.estimatedDistance = 0.0
        ServiceController.getEatApi(source, destination: destination, SuccessBlock: { (success, json) in
            
            if success{
                
                let status = json["status"].string ?? ""
                
                if status == "OK"{
                    
                    let data = json["rows"].array ?? [["":""]]
                    
                    guard let firstElement = data.first else{
                        fatalError("")
                    }
                    
                    if let elements = firstElement["elements"].array{
                        
                        var timeArray = ""
                        
                        for item in elements{
                            
                            let timeData = item["duration"].dictionary ?? ["":""]
                            
                            let time = timeData["text"]?.string ?? ""
                            
                            timeArray = time
                            
                            let disData = item["distance"].dictionary ?? ["":""]
                            
                            let dis = disData["text"]?.string ?? ""
                            
                            if dis.contains(" m"){
                                let sepratedDis = dis.replacingOccurrences(of: " km", with: "").replacingOccurrences(of: " m", with: "").replacingOccurrences(of: ",", with: "")
                                self.estimatedDistance = Float(sepratedDis)! / 1000
                                
                            }else if dis.contains(" km"){
                                let sepratedDis = dis.replacingOccurrences(of: " km", with: "").replacingOccurrences(of: " m", with: "").replacingOccurrences(of: ",", with: "")
                                self.estimatedDistance = Float(sepratedDis)!
                            }
                            
                            
                        }
                        printlnDebug(timeArray)
                        printlnDebug(self.estimatedDistance)
                        
                        self.retriveTotalEat(timeArray)
                    }
                }
            }
        }) { (error) in
            
            
        }
    }
    
    
    func retriveTotalEat(_ timeArray:String){
        var hourArray = ""
        var minArray = ""
        
        
        if timeArray.contains(" hours") && timeArray.contains(" mins"){
            
            
            let str = timeArray.replacingOccurrences(of: " hours", with: "").replacingOccurrences(of: " mins", with: "")
            
            let strArray = str.components(separatedBy: " ")
            
            hourArray = strArray[0]
            minArray = strArray[1]
            printlnDebug(hourArray)
            printlnDebug(minArray)
            
            
        }else if timeArray.contains(" hours") && timeArray.contains(" min"){
            let str = timeArray.replacingOccurrences(of: " hours", with: "").replacingOccurrences(of: " min", with: "")
            
            let strArray = str.components(separatedBy: " ")
            
            hourArray = strArray[0]
            minArray = strArray[1]
            
        }else if timeArray.contains(" hour") && timeArray.contains(" mins"){
            
            let str = timeArray.replacingOccurrences(of: " hour", with: "").replacingOccurrences(of: " mins", with: "")
            
            let strArray = str.components(separatedBy: " ")
            
            hourArray = strArray[0]
            minArray = strArray[1]
            
        }else if timeArray.contains(" hour") && timeArray.contains(" min"){
            
            let str = timeArray.replacingOccurrences(of: " hour", with: "").replacingOccurrences(of: " min", with: "")
            
            let strArray = str.components(separatedBy: " ")
            
            hourArray = strArray[0]
            minArray = strArray[1]
            
        }else if timeArray.contains(" hours"){
            let str = timeArray.replacingOccurrences(of: " hours", with: "")
            hourArray = str
        }else if timeArray.contains(" mins"){
            let str = timeArray.replacingOccurrences(of: " mins", with: "")
            minArray = str
        }else if timeArray.contains(" hour"){
            let str = timeArray.replacingOccurrences(of: " hour", with: "")
            hourArray = str
        }else if timeArray.contains(" min"){
            let str = timeArray.replacingOccurrences(of: " min", with: "")
            minArray = str
        }
        
        
        printlnDebug(hourArray)
        printlnDebug(minArray)
        self.calculateNetTime(hourArray, minArray: minArray)
    }
    
    
    func calculateNetTime(_ hrArray : String , minArray : String){
        var total = 0
        
        if !hrArray.contains("day") && !hrArray.isEmpty{
            
            total = total + (Int(hrArray) ?? 0 * 60)
        }
        
        if !minArray.isEmpty && !minArray.contains("day"){
            total = total + Int(minArray)!
        }
        printlnDebug(total)
        self.bookingTimeBtn.setTitle("\(total) mins", for: UIControlState())
    }
    
    
    func cancelRide(){
        
        var params = JSONDictionary()
        
        params["ride_id"]        = self.ride_id
        params["action"]        = "cancel"
        params["cancelled_by"]  = "user"
        params["reason"]        = "I want to cancel"
        
        ServiceController.rideactionApi(params, SuccessBlock: { (success,json) in
            CommonClass.stopLoader()
            
            if success{
                hideContentController(self)
                UserDefaults.removeFromUserDefaultForKey(NSUserDefaultsKeys.RIDE_STATE)
                tabbarSelect = 0
                CommonClass.gotoLandingPage()
            }
            
        }) { (error) in
            printlnDebug(error)
            CommonClass.stopLoader()
        }
    }
    
    // MARK: IBActions
    //MARK:- =================================================
    
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        
        hideContentController(self)
        
    }
    
    
    @IBAction func phoneNoTapped(_ sender: UIButton) {
        
        if self.driverMobileNumberLabel.text != ""{
            let phoneNumber = self.driverMobileNumberLabel.text ?? ""
            
            let phone = "telprompt://" + phoneNumber.replacingOccurrences(of: " ", with: "")
            
            if let url = URL(string: phone){
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    @IBAction func cancelBookingBtnTapped(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.cancelRide()
        }))
        self.present(alert, animated: true, completion: nil)

    }
    
}



