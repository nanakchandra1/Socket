//
//  OnRideViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 10/25/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

enum OnRide_ArrivalNowState {
    case onRide, arrival
}

class OnRideViewController: UIViewController {
    
    // MARK: =========
    // MARK: IBOutlets
    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var userMobileNumber: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var pickDropTableViewCell: UITableView!
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var cancelBtnBottomConst: NSLayoutConstraint!
    @IBOutlet weak var startNavigateBtn: UIButton!
    @IBOutlet weak var etaView: UIView!
    @IBOutlet weak var etaLbl: UILabel!
    @IBOutlet weak var routeLbl: UILabel!
    @IBOutlet weak var tableviewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var tableviewTopConstant: NSLayoutConstraint!
    // select drop
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var selectLocLbl: UILabel!
    @IBOutlet weak var selectDropPickerView: UIPickerView!
    @IBOutlet weak var dropCancelBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    
    // MARK: =========
    // MARK: Variables
    lazy var locationManager = CLLocationManager()
    var vcState = OnRide_ArrivalNowState.arrival
    var rideDetail = RideDetailModel()
    var dropLoc = ""
    var ride_id = ""
    var status: String!
    var estimatedDistance : Float = 0.0
    var popUpSelection:PopUpSelectionState!
    var isZoom = true
    var sharedMsg = ""
    var driverLoc = ""
    var isShoWDetail = false
    var currentLocation : CLLocation?
    
    var driverOldLat: Double = 0
    var driverOldLong: Double = 0
    
    // MARK:- ViewController Life Cycle Methods
    // MARK:- =================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 0
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
            print_debug(self.rideDetail)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2
        
    }
    
}

//MARK:- Private Methods
//MARK:- =================================================

extension OnRideViewController{
    
    fileprivate func initialSetup() {
        
        if CurrentUser.ride_state != RideStateString.rating{
            
            navigationView.setMenuButton()
            
        }
        
        if self.rideDetail.ride_status == Status.one{
            
            self.cancelBtnBottomConst.constant = 0
            self.pickDropTableViewCell.isHidden = true
            self.tableviewTopConstant.constant = -88

            
        }else if self.rideDetail.ride_status == Status.five{
            self.tableviewTopConstant.constant = 0
            self.pickDropTableViewCell.isHidden = false
            self.cancelBtnBottomConst.constant = 0
        }
        
        self.userImageView.clipsToBounds = true
        self.userImageView.layer.borderWidth = 1.8
        self.userImageView.layer.borderColor = UIColor(colorLiteralRed: 194/255.0, green: 0/255.0, blue: 52/255.0, alpha: 1).cgColor
        
        self.pickDropTableViewCell.register(UINib(nibName: "PickDropTableViewCell" ,bundle: nil), forCellReuseIdentifier: "PickDropTableViewCell")
        
        self.pickDropTableViewCell.dataSource = self
        self.pickDropTableViewCell.delegate = self
        
        
        switch self.rideDetail.ride_status {
            
        case Status.one:
            
            self.navigationTitle.text = C_ARRIVAL_NOW.localized
            self.cancelBtn.setTitle(C_CANCEL.localized, for: UIControlState())
            self.vcState = .arrival
            
        case Status.five:
            
            self.navigationTitle.text = C_ONRIDE.localized
            self.cancelBtn.setTitle(C_CHANGE_DESTI.localized, for: UIControlState())
            self.vcState = .onRide
            
        case Status.six:
            
            self.gotoRatingVC(rideDetail: self.rideDetail)
            
        case Status.seven:
            CommonClass.gotoLandingPage()
            UserDefaults.removeFromUserDefaultForKey(NSUserDefaultsKeys.RIDE_ID)
            
        default:
            
            printlnDebug("")
            
        }
        self.driverOldLat = self.rideDetail.driver_lat
        self.driverOldLong = self.rideDetail.driver_long

        self.setPicDropLoc()
        self.setDriverData()
        self.updateMarker()
        self.ride_Cancelled()
        self.ride_started()
        self.driver_arrived()
        self.driverLocationUpdate()
        self.endRide()
        
    }
    
    
    
    fileprivate func setDriverData(){
        
        self.userNameLabel.text = self.rideDetail.driver_name
        self.userMobileNumber.text = self.rideDetail.driver_contact
        self.userIdLabel.text = self.rideDetail.driver_uid
        
        let image = self.rideDetail.driver_image ?? ""
        
        let imageUrlStr = imgUrl + image
        
        if let imageUrl = URL(string: imageUrlStr){
            
            self.userImageView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "ic_place_holder"))
        }
    }
    
    
    fileprivate func setPicDropLoc(){
        
        self.dropLoc = self.rideDetail.drop_address
        
        
        self.pickDropTableViewCell.reloadData()
        
        if self.vcState == .arrival{
            
            self.getPlaceDetail(CLLocationCoordinate2D(latitude: self.rideDetail.driver_lat, longitude: self.rideDetail.driver_long))
            
        }
    }
    
    
    
    fileprivate func setEta(){
        
        
        var destinationStr = ""
        var source = ""
        
        self.pickDropTableViewCell.reloadData()
        
        if self.vcState == .arrival{
            
            source = "\(self.rideDetail.driver_lat),\(self.rideDetail.driver_long)|"
            
            destinationStr = "\(self.rideDetail.pickup_lat),\(self.rideDetail.pickup_long)|"
            self.calcEta(source, destination: destinationStr)
            
        }else{
            
            source = "\(self.rideDetail.pickup_lat),\(self.rideDetail.pickup_long)|"
            destinationStr = self.rideDetail.drop_lat_long
            
            self.calcEta(source, destination: destinationStr)
            
        }
    }
    
    
    fileprivate func updateMarker(){
        
        self.setEta()
        self.setMapZoomLevel()
        
    }
    
    
}

//MARK:- Private Methods
//MARK:- =================================================

extension OnRideViewController{
    
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        
        if self.vcState == .arrival{
            
            let alert = UIAlertController(title: "", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                
                self.cancelRide()
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }else{
            
            self.changeDestination()
        }
    }
    
    
    @IBAction func shareBtnTapped(_ sender: UIButton) {
        
        self.displayShareSheet(self.sharedMsg)
    }
    
    
    @IBAction func phoneNoTapped(_ sender: UIButton) {
        
        if self.userMobileNumber.text != ""{
            
            let phoneNumber = self.userMobileNumber.text ?? ""
            
            let phone = "telprompt://" + phoneNumber.replacingOccurrences(of: " ", with: "")
            
            if let url = URL(string: phone){
                
                UIApplication.shared.openURL(url)
            }
        }
    }
}

// MARK: Navigate another viewcontoller methods
//MARK:- =================================================

extension OnRideViewController{
    
    
    func displayContentController(_ content: UIViewController) {
        
        self.view.endEditing(true)
        addChildViewController(content)
        self.view.addSubview(content.view)
        content.didMove(toParentViewController: self)
    }
    
    func gotoBookingConfirmation(){
        let obj = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "BookingConfirmationViewController") as! BookingConfirmationViewController
        obj.tripDetail = self.rideDetail
        printlnDebug(self.rideDetail)
        obj.ride_id = self.ride_id
        self.displayContentController(obj)
    }
    
    
    //change destination
    
    func changeDestination(){
        
        let obj = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "ChangeDestinationPopUpVC") as! ChangeDestinationPopUpVC
        
        obj.rideDetail = self.rideDetail
        obj.delegate = self
        obj.popUpSelection = .changeDestination
        self.displayContentController(obj)
        
    }
    
    func displayShareSheet(_ shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }
    
    
    
    func gotoRatingVC(rideDetail: RideDetailModel){
        
        guard let viewController = (mfSideMenuContainerViewController.centerViewController as AnyObject).visibleViewController else{return}
        
        if viewController != nil {
            
            let popUp = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "RatingVC") as! RatingVC
            
            popUp.modalPresentationStyle = .overCurrentContext
            popUp.tripDetail = rideDetail
            
            getMainQueue({
                viewController!.present(popUp, animated: true, completion: nil)
            })
        }
        
    }
}


// MARK: Change drop delegate method
//MARK:- =================================================

extension OnRideViewController: ChangeDestinationDelegete{
    
    func changeDropStatus(with deatil: RideDetailModel) {
        
        self.rideDetail = deatil
        self.setPicDropLoc()
        self.updateMarker()
    }
    
}


// MARK: Socket services call methods
//MARK:- =================================================

extension OnRideViewController{
    
    
    //cancel ride by user
    
    func cancelRide(){
        
        var params = JSONDictionary()
        
        params["ride_id"]        = CurrentUser.ride_id!
        params["action"]        = "cancel"
        params["cancelled_by"]  = "user"
        params["reason"]        = "I want to cancel"
        
        if CommonClass.isConnectedToNetwork{
            
            CommonClass.startLoader("")
            
            SocketServicesController.cancelRequestRide(params)
            
        }
    }
    
    
    // ride cancelled by user or driver
    
    func ride_Cancelled(){
        
        SocketServicesController.rideCancelled({ (success, data) in
            
            CommonClass.gotoLandingPage()
            
        }) {
            
        }
    }
    
    // driver arrived at pick up location
    
    func driver_arrived(){
        
        SocketServicesController.driverArrived({ (success, data) in
            
            showToastWithMessage("Driver arrived your pickup location")
            
        }) {
            
        }
    }
    
    // ride started by driver
    
    func ride_started(){
        
        SocketServicesController.rideStarted({ (success, data) in
            
            self.vcState = .onRide
            self.cancelBtn.setTitle(C_CHANGE_DESTI.localized, for: UIControlState())
            self.navigationTitle.text = C_ONRIDE.localized
            self.tableviewTopConstant.constant = 0
            self.pickDropTableViewCell.isHidden = false

            self.setPicDropLoc()
            self.updateMarker()
            
        }) {
            
        }
    }
    
    
    // Driver location update
    
    func driverLocationUpdate(){
        
        SocketServicesController.driver_location({ (success, data) in
            
            self.driverOldLat = self.rideDetail.driver_lat
            self.driverOldLong = self.rideDetail.driver_long

            let result = data["result"]
            self.rideDetail.driver_lat = result["current_lat"].doubleValue
            self.rideDetail.driver_long = result["current_lon"].doubleValue

            self.setPicDropLoc()
            self.updateMarker()
            
        }) {
            
        }
    }
    
    // ride end from driver end
    
    func endRide(){
        
        
        SocketServicesController.end_ride({ (success, data) in
            
            showToastWithMessage("ride ended")
            let rideDetail = RideDetailModel(with: data)
            self.gotoRatingVC(rideDetail: rideDetail)
            printlnDebug(data)
            
        }) {
            
        }
    }
    
}

// MARK: LocationManager Delegate Methods
//MARK:- =================================================


extension OnRideViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.currentLocation = manager.location
        
    }
    
    
    func setZoomBound(){
        
        let current = CLLocationCoordinate2D(latitude: self.rideDetail.pickup_lat, longitude: self.rideDetail.pickup_long)
        let destination = CLLocationCoordinate2D(latitude: self.rideDetail.driver_lat,longitude: self.rideDetail.driver_long)
        let bounds = GMSCoordinateBounds(coordinate: current, coordinate: destination)
        let camera = self.googleMapView.camera(for: bounds, insets:UIEdgeInsets.zero)
        self.googleMapView.camera = camera!
    }

    
    func setMapZoomLevel(){
        
        //self.setZoomBound()
       // guard let _  = self.currentLocation else{return}
        self.googleMapView.clear()
        
        
        if self.vcState == .arrival{
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(self.rideDetail.pickup_lat, self.rideDetail.pickup_long)
            marker.icon = locationPin
            marker.map = self.googleMapView
            
        }else if self.vcState == .onRide{
            
            for res in self.rideDetail.dropLatLongArray{
                
                let lat = res["lat"].doubleValue
                let lon = res["long"].doubleValue
                
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2DMake(lat, lon)
                marker.icon = locationPin
                marker.map = self.googleMapView
            }
        }

        let old_cord = CLLocationCoordinate2D(latitude: self.driverOldLat, longitude: self.driverOldLong)
        let new_cord = CLLocationCoordinate2D(latitude: self.rideDetail.driver_lat, longitude: self.rideDetail.driver_long)

        self.googleMapView.camera = GMSCameraPosition(target: new_cord, zoom: 14.5, bearing: 0, viewingAngle: 0)
        
        let marker = GMSMarker()
        marker.position = new_cord
        marker.icon = scooterPin
        marker.map = self.googleMapView
        
        let oldCoodinate: CLLocationCoordinate2D? = new_cord
        let newCoodinate: CLLocationCoordinate2D? = old_cord
        
        marker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
        
        marker.rotation = CLLocationDegrees(self.getHeadingForDirection(fromCoordinate: oldCoodinate!, toCoordinate: newCoodinate!))
        //found bearing value by calculation when marker add
        marker.position = oldCoodinate!
        //this can be old position to make car movement to new position
        marker.map = self.googleMapView
        //marker movement animation
        CATransaction.begin()
        CATransaction.setValue(Int(5.0), forKey: kCATransactionAnimationDuration)
        CATransaction.setCompletionBlock({() -> Void in
            
            marker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
            marker.rotation = CDouble(self.getHeadingForDirection(fromCoordinate: oldCoodinate!, toCoordinate: newCoodinate!))
            
        })
        marker.position = newCoodinate!
        //this can be new position after car moved from old position to new position with animation
        marker.map = self.googleMapView
        marker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
        marker.rotation = CLLocationDegrees(self.getHeadingForDirection(fromCoordinate: oldCoodinate!, toCoordinate: newCoodinate!))
        //found bearing value by calculation
        CATransaction.commit()
    }
    
    func getHeadingForDirection(fromCoordinate fromLoc: CLLocationCoordinate2D, toCoordinate toLoc: CLLocationCoordinate2D) -> Float {
        
        let fLat: Float = Float((fromLoc.latitude).degreesToRadians)
        let fLng: Float = Float((fromLoc.longitude).degreesToRadians)
        let tLat: Float = Float((toLoc.latitude).degreesToRadians)
        let tLng: Float = Float((toLoc.longitude).degreesToRadians)
        let degree: Float = (atan2(sin(tLng - fLng) * cos(tLat), cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng))).radiansToDegrees
        if degree >= 0 {
            return degree
        }
        else {
            return 360 + degree
        }
    }
    
    func getPlaceDetail(_ coordinates:CLLocationCoordinate2D){
        
        
        let params = ["latlng": "\(coordinates.latitude ),\(coordinates.longitude )", "key": APIKeys.googleAPIKey]
        
        ServiceController.googleGeocodeApi(params, SuccessBlock: { (success, json) in
            
            let status = json["status"].string ?? ""
            
            if status == "OK"{
                
                let result = json["results"].array?.first ?? ["" : "" ]
                let address = result["formatted_address"].string ?? ""
                self.driverLoc = address
                self.pickDropTableViewCell.reloadData()
                
            }
            
        }) { (error) in
            
            
            
        }
    }
    
    
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
                        
                        var timeArray = [String]()
                        
                        for item in elements{
                            
                            let timeData = item["duration"].dictionary ?? ["":""]
                            
                            let time = timeData["text"]?.string ?? ""
                            
                            timeArray.append(time)
                            
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
    
    
    
    func retriveTotalEat(_ timeArray:[String]){
        
        var hourArray = [String]()
        var minArray = [String]()
        
        for item in timeArray{
            
            if item.contains(" hours") && item.contains(" mins"){
                
                
                let str = item.replacingOccurrences(of: " hours", with: "").replacingOccurrences(of: " mins", with: "")
                
                let strArray = str.components(separatedBy: " ")
                
                hourArray.append(strArray[0])
                minArray.append(strArray[1])
                
            }else if item.contains(" hours") && item.contains(" min"){
                let str = item.replacingOccurrences(of: " hours", with: "").replacingOccurrences(of: " min", with: "")
                
                let strArray = str.components(separatedBy: " ")
                
                hourArray.append(strArray[0])
                minArray.append(strArray[1])
                
            }else if item.contains(" hour") && item.contains(" mins"){
                
                let str = item.replacingOccurrences(of: " hour", with: "").replacingOccurrences(of: " mins", with: "")
                
                let strArray = str.components(separatedBy: " ")
                
                hourArray.append(strArray[0])
                minArray.append(strArray[1])
                
            }else if item.contains(" hour") && item.contains(" min"){
                
                let str = item.replacingOccurrences(of: " hour", with: "").replacingOccurrences(of: " min", with: "")
                
                let strArray = str.components(separatedBy: " ")
                
                hourArray.append(strArray[0])
                minArray.append(strArray[1])
                
            }else if item.contains(" hours"){
                let str = item.replacingOccurrences(of: " hours", with: "")
                hourArray.append(str)
            }else if item.contains(" mins"){
                let str = item.replacingOccurrences(of: " mins", with: "")
                minArray.append(str)
            }else if item.contains(" hour"){
                let str = item.replacingOccurrences(of: " hour", with: "")
                hourArray.append(str)
            }else if item.contains(" min"){
                let str = item.replacingOccurrences(of: " min", with: "")
                minArray.append(str)
            }
            
        }
        
        printlnDebug(hourArray)
        printlnDebug(minArray)
        self.calculateNetTime(hourArray, minArray: minArray)
    }
    
    
    func calculateNetTime(_ hrArray : [String] , minArray : [String]){
        
        
        var total = 0
        for item in hrArray{
            
            if !item.contains("day") && !item.isEmpty{
                
                total = total + (Int(item)! * 60)
            }
            
        }
        
        for item in minArray{
            
            if !item.contains("day") && !item.isEmpty{
                
                total = total + Int(item)!
            }
        }
        printlnDebug(total)
        self.etaLbl.text = "\(total) mins (\(self.estimatedDistance) kms)"
        if self.vcState == .arrival{
            self.sharedMsg = "\(RideRelatedString.arrivalnow_share_eta_Msg) \(total) mins"
            if total <= 2{
                UserDefaults.save(NavigationTitle.arrivalNow as AnyObject, forKey: NavigationTitle.arrivalNow)
                self.navigationTitle.text = C_ARRIVAL_NOW.localized
            }else{
                UserDefaults.save(NavigationTitle.arrivalNow as AnyObject, forKey: NavigationTitle.onTheWay)
                self.navigationTitle.text = C_ON_THE_WAY.localized
            }
        }else{
            self.sharedMsg = "\(RideRelatedString.share_eta_Msg) \(total) mins"
        }
    }
    
}

// MARK: TableView Delegate and DataSource Methods
//MARK:- =================================================



extension OnRideViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickDropTableViewCell", for: indexPath) as! PickDropTableViewCell
        if self.vcState == .arrival{
            if indexPath.row == 0{
                cell.populate(at: indexPath.row, with: self.driverLoc)
            }
            else{
                
                cell.populate(at: indexPath.row, with: self.rideDetail.pickup_address)
            }
            
        }else{
            if indexPath.row == 0{
                
                cell.populate(at: indexPath.row, with: self.rideDetail.pickup_address)
            }
            else{
                cell.populate(at: indexPath.row, with: self.rideDetail.drop_address)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
