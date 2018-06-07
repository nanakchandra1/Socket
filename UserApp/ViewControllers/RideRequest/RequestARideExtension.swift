//
//  RequestARideExtension.swift
//  UserApp
//
//  Created by Appinventiv on 15/11/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import SwiftyJSON


// MARK:- Set UI Methods

extension RequestARideViewController{

    
    func initialSetup() {
        
        self.paymentMode = CurrentUser.p_mode ?? "Cash"
        self.navigationTitle.text = REQUEST_RIDE.localized
        self.shareBtn.isUserInteractionEnabled = false
        self.pickUpDropOffTableView.estimatedRowHeight = 40
        self.pickerDoneView.addSubview(self.pickDoneButton)
        self.pickDoneButton.setTitle(DONE.capitalized.localized, for: UIControlState())
        self.pickDoneButton.addTarget(self, action: #selector(toolbarDoneBtnTapped), for: .touchUpInside)
        self.bookBtn.layer.borderColor = UIColor(red: 18/255, green: 18/255, blue: 18/255, alpha: 1).cgColor
        self.bookBtn.clipsToBounds = true
        self.bookBtn.layer.borderWidth = IsIPad ? 5:4.5
        self.bookBtn.layer.cornerRadius = IsIPad ? 45:30
        self.pickUpDropOffTableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationTableViewCell")
        self.pickUpDropOffTableView.dataSource = self
        self.pickUpDropOffTableView.delegate = self
        self.pickUpDropOffTableView.rowHeight = IsIPad ? 80:60
        self.setBookBtn()
        navigationView.setMenuButton()
        self.pickUpDotView.layer.cornerRadius = IsIPad ? 5:3.5
        self.pickUpAddressLabel.text = CHOOSE_YOUR_PICKUP.localized
        self.pickUpAddressLabel.sizeToFit()
        self.pickupLbl.text = PICK_UP.localized
        self.pickUpEditBtn.layer.cornerRadius = 3
        self.pickUpEditBtn.layer.borderColor = UIColor(red: 129/255, green: 129/255, blue: 129/255, alpha: 0.3).cgColor
        self.pickUpEditBtn.layer.borderWidth = 1
        self.pickUpEditBtn.isHidden = true
        
        self.pickerView.backgroundColor = UIColor.white
        self.pickerDoneView.backgroundColor = UIColor(red: 194/255, green: 0, blue: 52/255, alpha: 1)
        self.pickerView.frame.size.height = 150
        self.pickerView.frame.size.width = screenWidth * 0.85
        self.pickerDoneView.frame.size.width = screenWidth * 0.85
        self.pickerView.center = self.view.center
        //self.pickerDoneView.clipsToBounds = true
        self.searchLbl.text = SEARCH_DRIVER_ON_LOCATION.localized
        self.pickerOuterView.addSubview(self.pickerView)
        self.pickerOuterView.addSubview(self.pickerDoneView)
        
        self.view.bringSubview(toFront: self.pickerOuterView)
        
        self.set_Payment_Mode()
        
        self.sockecConnected()
        
    }
    
    
    func sockecConnected(){
        
        self.getRequestResponce()

        if CurrentUser.isRideAvailable{
        
            self.getRegainRideState()

        }else{
        
            self.nearbydriver_on_res()
        }
    }
    
    func set_Payment_Mode(){
        
        
        if self.paymentMode.lowercased() == PaymentMode.cash.lowercased(){
            
            self.paymentModeLabel.text = PaymentMode.cash
            self.paymentModeImageView.image = payment_method_cash
            
        }else{
            
            self.paymentModeLabel.text = PaymentMode.card
            self.paymentModeImageView.image = payment_method_card
        }
        
    }
    
    func displayContentController(_ content: UIViewController) {
        addChildViewController(content)
        self.view.addSubview(content.view)
        content.didMove(toParentViewController: self)
    }
    
    
    func setMapZoomLevel(){
        
        self.googleMapView.clear()

        if self.currenLat_long != nil {
            
            if let lat = self.pickLocationDict["latitude"] as? Double,let long = self.pickLocationDict["longitude"] as? Double{
                
                let marker = GMSMarker()
                let cordinate = CLLocationCoordinate2D(latitude: lat , longitude: long)
                self.googleMapView.camera = GMSCameraPosition(target: cordinate, zoom: 13, bearing: 0, viewingAngle: 0)
                marker.position = cordinate
                marker.icon = locationPin
                marker.map = self.googleMapView
                
            }
        }
        
        for nearby in self.nearbyUserData{
        
            let marker = GMSMarker()
            let cordinate = CLLocationCoordinate2D(latitude: nearby.lat , longitude: nearby.long)
            marker.position = cordinate
            marker.icon = scooterPin
            marker.map = self.googleMapView

        }
    }
    
    
    
    
    
    
    func displayShareSheet(_ shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }
    
    func setPickUpLocation() {
        
        let params = ["latlng": "\(locationManager.location?.coordinate.latitude ?? 0),\(locationManager.location?.coordinate.longitude ?? 0)", "key": "AIzaSyB0jPK6b0QwIZV8u1hSKLpe8cZsHpot3yc"]
        
        
        ServiceController.googleGeocodeApi(params, SuccessBlock: { (success, json) in
            
            let status = json["status"].string ?? ""
            
            if status == "OK"{
                
                let result = json["results"].array?.first ?? [:]
                let address = result["formatted_address"].string ?? ""
                let geometry = result["geometry"].dictionary ?? [:]
                let location = geometry["location"]?.dictionary ?? [:]
                let latitude = location["lat"]?.double ?? 0
                let longitude = location["lng"]?.double ?? 0
                
                self.pickUpAddressLabel.text = address
                self.pickLocationDict["address"] = address
                self.pickLocationDict["latitude"] = latitude
                self.pickLocationDict["longitude"] = longitude
                self.setMapZoomLevel()
                
            }
            
        }) { (error) in
            
            
            
        }
        
    }
    
    
    func setPaymentMode(_ paymentMode: String, paymentImage: String) {
        
        self.paymentMode = paymentMode
        
        self.set_Payment_Mode()
        
    }

    
    // To check if book btn should be enabled or disabled
    func setBookBtn() {
        
        if dropLocationDict[0]["address"] == nil || pickLocationDict["address"] == nil || (dropLocationDict[0]["address"] as! String).isEmpty || (pickLocationDict["address"] as! String).isEmpty {
            
            self.disableBookBtn()
            
        } else {
            
            self.enableBookBtn()
            
            
            CommonClass.delay(2, closure: {
                
                printlnDebug(self.pickLocationDict)
                printlnDebug(self.dropLocationDict)
                
                if let p_lat = self.pickLocationDict["latitude"],let p_lng = self.pickLocationDict["longitude"] , let _ = self.dropLocationDict[0]["latitude"] as? Double{
                    
                    let pickup_loc = CLLocation(latitude: Double("\(p_lat)")!, longitude: Double("\(p_lng)")!)
                    self.setPickUpMarker(pickup_loc)
                    
                    let drop_loc = CLLocation(latitude: self.dropLocationDict[0]["latitude"] as! Double, longitude: self.dropLocationDict[0]["longitude"] as! Double)
                    
                    self.setPickUpMarker(drop_loc)
                    
                    self.pickUpDropOffTableView.reloadData()
                }
            })
        }
    }
    
    
    func startPrebooking(_ userData: Notification){
        
        if let userdata = userData.userInfo as? JSONDictionary{
            
            self.ride_id = userdata["ride_id"] as! String
            //self.checkStatus()
            
        }
        
    }
    
    
    func setPickUpMarker(_ locValue:CLLocation){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(locValue.coordinate.latitude, locValue.coordinate.longitude)
        marker.icon = locationPin
        marker.map = self.googleMapView
    }
    
    
    func disableBookBtn() {
        
        self.bookBtn.isEnabled = false
        self.bookBtn.backgroundColor = UIColor(red: 41/255, green: 41/255, blue: 41/255, alpha: 1)
        self.bookBtn.tintColor = UIColor(red: 36/255, green: 36/255, blue: 36/255, alpha: 1)
        
        self.bookBtn.setTitleColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), for: .normal)
    }
    
    func enableBookBtn() {
        self.openRideView()
        self.bookBtn.isEnabled = true
        self.bookBtn.backgroundColor = UIColor(red: 218/255, green: 0, blue: 84/255, alpha: 1)
        self.bookBtn.tintColor = UIColor.white
        self.bookBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)

    }
    
    
    func addSwipeGesture(toView view: UIView) {
        
        let downSwipeGestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(viewDidSwipe(_:)))
        let upSwipeGestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(viewDidSwipe(_:)))
        
        downSwipeGestureRecogniser.direction = .down
        upSwipeGestureRecogniser.direction = .up
        
        view.addGestureRecognizer(downSwipeGestureRecogniser)
        view.addGestureRecognizer(upSwipeGestureRecogniser)
    }
    
    func viewDidSwipe(_ swipe: UISwipeGestureRecognizer) {
        
        if swipe.direction == .up && self.bottomLayoutConstraintOfRideView.constant == -(IsIPad ? 169:119) {
            
            self.openRideView()
            
        } else if swipe.direction == .down && self.bottomLayoutConstraintOfRideView.constant == 0 {
            
            self.closeRideView()
        }
    }
    
    func openRideView() {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
            
            self.bottomLayoutConstraintOfRideView.constant = 0
            self.view.layoutIfNeeded()
            
        }, completion: { (didComplete: Bool) in
            
        })
    }
    
    
    func closeRideView() {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.bottomLayoutConstraintOfRideView.constant = -(IsIPad ? 140:119)
            self.view.layoutIfNeeded()
        }, completion: { (didComplete: Bool) in
        })
    }
    
    
    func addMoreLocationBtnTapped(_ sender: UIButton) {
        
        let cell = sender.superview?.superview as! LocationTableViewCell
        let indexPath = self.pickUpDropOffTableView.indexPath(for: cell)!
        
        self.tappedIndex = indexPath.row
        action = .add
        
        self.navigate(LocationType.dropoff)
    }
    
    
    func deleteLocationBtnTapped(_ sender: UIButton) {
        
        if self.numberOfLocations > 1 {
            
            let cell = sender.superview?.superview as! LocationTableViewCell
            let indexPath = self.pickUpDropOffTableView.indexPath(for: cell)!
            
            if self.numberOfLocations == self.dropLocationDict.count {
                
                self.numberOfLocations -= 1
            }
            
            self.dropLocationDict.remove(at: indexPath.row)
            self.pickUpDropOffTableView.reloadData()
            
            var destinationStr = ""
            
            for item in self.dropLocationDict{
                
                if let lat = item["latitude"]{
                    if let long = item["longitude"]{
                        
                        destinationStr.append("\(lat),\(long)|")
                    }
                }
            }
            
            printlnDebug(destinationStr)
            
            let srcLat = self.pickLocationDict["latitude"]
            let srcLon = self.pickLocationDict["longitude"]
            let srcStr = "\(srcLat!),\(srcLon!)"
            
            
            self.calcEta(srcStr, destination: destinationStr)
            
        } else {
            
            showToastWithMessage("Cannot delete this location".localized)
        }
        
        self.setBookBtn()
    }
    
    func editLocationBtnTapped(_ sender: UIButton) {
        
        let cell = sender.superview?.superview as! LocationTableViewCell
        let indexPath = self.pickUpDropOffTableView.indexPath(for: cell)!
        
        self.tappedIndex = indexPath.row
        self.action = .edit
        
        self.navigate(LocationType.dropoff)
    }
    
    func editDropLocation(atIndex index: Int) {
        
        self.tappedIndex = index
        self.action = .edit
        
        self.navigate(LocationType.dropoff)
    }
    
    func addMoreLocation(atIndex index: Int) {
        
        self.tappedIndex = index
        action = .add
        
        self.navigate(LocationType.dropoff)
    }
    
    
    
    
    
    func navigate(_ type: LocationType) {
        
        let chooseLocationScene = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "ChooseLocationViewController") as! ChooseLocationViewController
        
        let locationType = self.getLocationType(forIndex: self.tappedIndex)
        
        chooseLocationScene.locationType = locationType
        chooseLocationScene.delegate = self
        chooseLocationScene.location_Type = type
        chooseLocationScene.chooseState = .req
        self.present(chooseLocationScene, animated: true, completion: nil)
    }
    
    
    
    func getLocationType(forIndex index: Int) -> String {
        
        if index == -1 {
            
            return "Pick Up"
            
        } else {
            
            return "Drop Off"
        }
    }
    
    func toolbarDoneBtnTapped() {
        
        self.pickerOuterView.isHidden = true
        self.vehivleNameLabel.text = self.vehicleList[self.pickerView.selectedRow(inComponent: 0)].vehicle_model
        self.seletedVehicle = self.vehicleList[self.pickerView.selectedRow(inComponent: 0)]
        
    }
    
    
    
    func getJsonObject(_ Detail: Any) -> String{
        
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
    
    
    
    
    func show_GPS_prompt(){
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
                
            case .notDetermined:
                print_debug("No access")
            case .restricted, .denied:
                gotoGPSPopup()
            case .authorizedAlways, .authorizedWhenInUse:
                print_debug("Access")
            }
        } else {
            
            gotoGPSPopup()
            
        }
    }
    
    
    
    func turn_GPS_ON() {
        
        UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
    }
    



}
