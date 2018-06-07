//
//  RequestARideViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/21/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import SwiftyJSON


enum Zoom_in_Zoom_Out{
    case zoomin, zoomout
}
enum LocationAction {
    case add, edit
}

enum DictType {
    
    case pick,drop
}


var isvehecleAdd = true
var sdeletedVehicle = 0
var currenSelected = 0


protocol SetPaymentModeDelegate {
    
    func setPaymentMode(_ paymentMode: String, paymentImage: String)
}

class RequestARideViewController: UIViewController, SetPaymentModeDelegate {
    
    
    
    // MARK: IBOutlets
    //MARK:- =================================================
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var bookBtn: UIButton!
    @IBOutlet weak var searchLbl: UILabel!
    @IBOutlet weak var rideView: UIView!
    @IBOutlet weak var rateCardView: UIView!
    @IBOutlet weak var bottomLayoutConstraintOfRideView: NSLayoutConstraint!
    @IBOutlet weak var rideViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickUpDropOffTableView: UITableView!
    @IBOutlet weak var tripFareLabel: UILabel!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var paymentModeLabel: UILabel!
    @IBOutlet weak var paymentModeImageView: UIImageView!
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var pickerOuterView: UIView!
    @IBOutlet weak var vehivleNameLabel: UILabel!
    @IBOutlet weak var pickUpDotView: UIView!
    @IBOutlet weak var pickupLbl: UILabel!
    @IBOutlet weak var pickUpAddressLabel: UILabel!
    @IBOutlet weak var arrivalTimeLbl: UILabel!
    @IBOutlet weak var pickUpEditBtn: UIButton!
    @IBOutlet weak var etaLbl: UILabel!
    @IBOutlet weak var totalFareLbl: UILabel!
    @IBOutlet weak var paymentModeLbl: UILabel!
    @IBOutlet weak var vehicleModeBtn: UIButton!
    
    
    // MARK: Variables
    //MARK:- =================================================
    
    var numberOfLocations = 1
    var dropLocationDict: [JSONDictionary] = [[:]]
    var pickLocationDict: JSONDictionary = [:]
    var tappedIndex = -1
    var action: LocationAction!
    var dictType: DictType!
    var locationManager:CLLocationManager!
    var isPickedUpLoc = true
    lazy var pickerView = UIPickerView()
    var marker = GMSMarker()
    var zoomState = Zoom_in_Zoom_Out.zoomin
    var index: Int?
    var cameraPosition = true
    var currenLat_long: CLLocationCoordinate2D?
    var ride_id = ""
    var status = false
    let timeInterval:TimeInterval = 1.0
    let timerEnd:TimeInterval = 10.0
    var timeCount:TimeInterval = 0
    var matchedLocationsDict = [[String: String]]()
    var isShow = false
    var tripFare = "0"
    var paymentMode = "Cash"
    let geoCoder = CLGeocoder()

    var vehicleList = [MyVehiclesModel]()
    var seletedVehicle = MyVehiclesModel()
    var nearbyUserData = [NearbyUserDriverModel]()

    
    
    lazy var pickerDoneView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40))
    lazy var pickDoneButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40))
    
    // MARK: Constants
    
    var estimatedDistance : Float = 0.0
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(RequestARideViewController.startPrebooking), name:NSNotification.Name(rawValue: GETPREBOOKINGACCEPTED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RequestARideViewController.sockecConnected), name: .connetSocketNotificationName, object: nil)

        self.initialSetup()
            
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        self.pickerView.center = self.pickerOuterView.center
        self.pickerDoneView.center.x = self.pickerView.center.x
        self.pickerDoneView.center.y = self.pickerView.frame.origin.y-20
        rateCardView.frame.size.height = (IsIPad ? 140:100)
        
        self.pickUpDropOffTableView.tableFooterView = rateCardView

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.applicationIconBadgeNumber = 0

        self.show_GPS_prompt()
        
        if CurrentUser.ride_state != nil{
            
            //self.regainRideState()
            
        }
        self.pickerOuterView.isHidden = true
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 100
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.addSwipeGesture(toView: self.rideView)
        self.getVehicles()
        self.cameraPosition = true
        //self.zoomState = .Zoomin
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SocketManegerInstance.socket?.off("NearbyDriver_res")

    }
    

    
    deinit {
        NotificationCenter.default.removeObserver(self)
        SocketManegerInstance.socket?.off("NearbyDriver_res")
    }
    
    
    // MARK: IBAction
    //MARK:- =================================================
    
    @IBAction func bookBtnTapped(_ sender: UIButton) {
        
        self.requestARide()
    }
    
    @IBAction func paymentModeBtnTapped(_ sender: UIButton) {
        
        let paymentScene = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "PaymentMethodID") as! PaymentMethodViewController
        paymentScene.sender = Sender.choosePayment
        paymentScene.delegate = self
        self.navigationController?.pushViewController(paymentScene, animated: true)
        
    }
    
    @IBAction func shareBtnTapped(_ sender: UIButton) {
        
        self.displayShareSheet(self.arrivalTimeLabel.text!)
        
    }
    
    @IBAction func openPickerBtnTapped(_ sender: UIButton) {
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.pickerOuterView.isHidden = false
    }
    
    @IBAction func pickUpEditBtnTapped(_ sender: UIButton) {
        
        self.action = .edit
        self.tappedIndex = -1
        self.navigate(LocationType.pickUp)
    }
    
    
    @IBAction func pickUpTapped(_ sender: UIButton) {
        
        self.action = .edit
        self.tappedIndex = -1
        self.navigate(LocationType.pickUp)
    }
    
}





// MARK: Go to another view controllers
//MARK:- =================================================

extension RequestARideViewController {
    
    
    func showSearchingForDriverPopUp(with ride_id: String){
        
        if let viewController = (mfSideMenuContainerViewController.centerViewController as AnyObject).visibleViewController {
            
            guard viewController != nil else {return}
            
            let popUp = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "SearchingForDriver") as! SearchingForDriver
            
            popUp.modalPresentationStyle = .overCurrentContext
            popUp.ride_id = ride_id
            
            getMainQueue({
                viewController!.present(popUp, animated: true, completion: nil)
            })
        }
    }
    
    func gotoOnrideScreen(with rideDetail: RideDetailModel){
        
        let onRideVC = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "OnRideViewController") as! OnRideViewController
        onRideVC.rideDetail = rideDetail
        let navController = UINavigationController(rootViewController: onRideVC)
        navController.isNavigationBarHidden = true
        navController.automaticallyAdjustsScrollViewInsets = false
        mfSideMenuContainerViewController.centerViewController = navController
        
    }
    
    func gotoGPSPopup(){
        
        if let viewController = (mfSideMenuContainerViewController.centerViewController as AnyObject).visibleViewController, viewController != nil {
            
            let popUp = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "LoactionPopUpVC") as! LoactionPopUpVC
            
            popUp.modalPresentationStyle = .overCurrentContext
            
            getMainQueue({
                viewController!.present(popUp, animated: true, completion: nil)
            })
            
        }
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

// MARK: Table View Life Cycle Methods
//MARK:- =================================================

extension RequestARideViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.numberOfLocations
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as! LocationTableViewCell
        
        let locationAddress = (self.dropLocationDict[indexPath.row]["address"] as? String) ?? "Choose your Drop Off"
        
        cell.populate(atIndex: indexPath.row, withNumberOfLocations: self.numberOfLocations, withLocationAddress: locationAddress)
        
        if indexPath.row == 0 {
            
            cell.deleteLocationBtn.isHidden = true
            
        }else if indexPath.row ==  self.numberOfLocations - 1 && self.dropLocationDict.count < 5{
            
            cell.deleteLocationBtn.isHidden = true
        }
        else{
            
            cell.deleteLocationBtn.isHidden = false
            
        }
        cell.addMoreLocationBtn.addTarget(self, action: #selector(addMoreLocationBtnTapped(_:)), for: .touchUpInside)
        cell.editLocationBtn.addTarget(self, action: #selector(editLocationBtnTapped(_:)), for: .touchUpInside)
        cell.deleteLocationBtn.addTarget(self, action: #selector(deleteLocationBtnTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (self.dropLocationDict[indexPath.row]["address"] == nil) || (self.dropLocationDict[indexPath.row]["address"] as! String).isEmpty {
            
            self.addMoreLocation(atIndex: indexPath.row)
            
        } else {
            
            self.editDropLocation(atIndex: indexPath.row)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        
    }
}


// MARK: Cllocation manager delegate & get ETA
//MARK:- =================================================

extension RequestARideViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        self.currenLat_long = manager.location!.coordinate
        
        if !CurrentUser.isRideAvailable{
            
            self.nearbydriverEmit(withLocation: locations.last!)

        }
        
        if self.zoomState == .zoomin{
            
            self.setPickUpLocation()
            
            self.googleMapView.camera = GMSCameraPosition(target: manager.location!.coordinate, zoom: 13, bearing: 0, viewingAngle: 0)
            
            self.zoomState = .zoomout
            guard let currentLocation = locations.first else { return }
            
            geoCoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
                guard let currentLocPlacemark = placemarks?.first else { return }
                // guard let code = currentLocPlacemark.isoCountryCode else{return}
                guard currentLocPlacemark.country != nil else{return}
                UserDefaults.save(currentLocPlacemark.country as Any , forKey: NSUserDefaultsKeys.COUNTRY)
                
                printlnDebug(CurrentUser.country)
            }

        }
    }
    
}


// MARK: Add/Edit Pick Up or Drop Off Locations
//MARK:- =================================================

extension RequestARideViewController: ManageLocationsDelegate {
    
    func addEditLocation(withLocation location: JSONDictionary) {
        
        if action == .add {
            
            if self.numberOfLocations < 5 {
                
                self.dropLocationDict.insert(location, at: self.tappedIndex)
                self.numberOfLocations = min(self.numberOfLocations.advanced(by: 1), 4)
                self.pickUpDropOffTableView.reloadData()
                
                if let pId = dropLocationDict[self.tappedIndex]["place_id"] as? String, !pId.isEmpty{
                    
                    self.getPlaceDetail(pId, dict: .drop)
                    
                }else{
                    
                    getEta()
                }
                
            } else {
                
                showToastWithMessage("Cannot add more location".localized)
            }
            
        } else if (self.action == .edit) && (self.tappedIndex == -1) {
            self.pickLocationDict = location
            self.isPickedUpLoc = false
            self.pickUpAddressLabel.text = location["address"] as? String ?? "Choose your Pick Up"
            if let pId  = pickLocationDict["place_id"] as? String{
                self.getPlaceDetail(pId, dict: .pick)
                
            }else{
                
                getEta()
                
            }
        } else {
            self.dropLocationDict[self.tappedIndex] = location
            self.pickUpDropOffTableView.reloadData()
            if let pid = self.dropLocationDict[self.tappedIndex]["place_id"] as? String{
                self.getPlaceDetail(pid, dict: .drop)
                
            }else{
                getEta()
            }
        }
        self.setBookBtn()
    }
}


// MARK: Picker View data source life cycle methods
//MARK:- =================================================

extension RequestARideViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return self.vehicleList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        return self.vehicleList[row].vehicle_model
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.seletedVehicle = self.vehicleList[row]
    }
}
