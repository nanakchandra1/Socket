//
//  SavedLocationsVC.swift
//  UserApp
//
//  Created by Appinventiv on 24/11/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import GoogleMaps

class SavedLocationsVC: UIViewController {
    
    
    //MARK:- IBOutlets
    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var savedLocTableView: UITableView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var addLocationBtn: UIButton!
    @IBOutlet weak var noLocationSavedLbl: UILabel!
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var enterLocBgView: UIView!
    @IBOutlet weak var enterLocTextField: UITextField!
    @IBOutlet weak var placeHolderView: UIView!
    @IBOutlet weak var placeHolderPopUpView: UIView!
    @IBOutlet weak var locationPin: UIImageView!
    @IBOutlet weak var noSavedLocLbl: UILabel!
    
    
    //MARK:- Properties
    var savedLoc = JSONDictionaryArray()
    lazy var locationManager = CLLocationManager()
    var destinationMarker = GMSMarker()
    var destinationCoordinate: CLLocationCoordinate2D?
    var mapGesture = true
    var zoomState = Zoom_in_Zoom_Out.zoomin
    var placeDetail: JSONDictionary = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.savedLocTableView.estimatedRowHeight = 50
        self.googleMapView.delegate = self
        self.enterLocTextField.text = "Press on 'Map' to select location"
        self.saveLocation(action: "view")
        self.locationPin.isHidden = true
        self.noSavedLocLbl.text = NO_SAVED_LOC.localized
        self.googleMapView.settings.myLocationButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
            
        }
    }
    
    //MARK:- IBActions
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    
    @IBAction func addLocationTapped(_ sender: UIButton) {
        
        if self.addLocationBtn.titleLabel?.text == "Add Locations"{
            
            if self.savedLoc.count >= 5{
                
                showToastWithMessage("Can't save more than 5 locations")
                
            }else{
                
                self.addLocationBtn.setTitle("Done", for: UIControlState())
                self.googleMapView.isHidden = false
                self.placeHolderView.isHidden = true
                self.enterLocBgView.isHidden = false
                self.locationPin.isHidden = false
                self.navigationTitle.text = "ADD LOCATION"
            }
            
        }else{
            
            if self.enterLocTextField.text != ""{
                
                self.addLocationBtn.setTitle("Add Locations", for: UIControlState())
                
                self.saveLocation(action: "add")
                
            }else{
                showToastWithMessage("Please Select Location")
            }
        }
    }
    
    fileprivate func setSaveocationView(){
    
        if self.savedLoc.isEmpty{
            
            self.googleMapView.isHidden = false
            self.placeHolderView.isHidden = false
            self.enterLocBgView.isHidden = true
            self.locationPin.isHidden = true
        }else{
            
            self.navigationTitle.text = "SAVED LOCATION"
            self.googleMapView.isHidden = true
            self.placeHolderView.isHidden = true
            self.enterLocBgView.isHidden = true
            self.savedLocTableView.delegate = self
            self.savedLocTableView.dataSource = self
            self.locationPin.isHidden = true

        }
    }
    
    private func saveLocation(action: String){
    
        var params = JSONDictionary()
        
        if action == "add"{
            
            params["location"] = CommonClass.getJsonObject(self.placeDetail as AnyObject) as AnyObject
        }
        params["action"] = action
        
        CommonClass.startLoader("")
        
        ServiceController.saveLocationApi(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()
            
            if success{
                
                self.savedLoc = json["result"].arrayObject as? JSONDictionaryArray ?? [["":""]]
                
                self.setSaveocationView()
                self.savedLocTableView.reloadData()
                
            }
        }, failureBlock: { (error) in
            
            printlnDebug(error)
            
            CommonClass.stopLoader()
            
        })

    }
    
    
    func getPlaceDetail(_ coordinates:CLLocationCoordinate2D) {
        
        CommonClass.startLoader("")
        let params = ["latlng": "\(coordinates.latitude ),\(coordinates.longitude )", "key": APIKeys.googleMapsApiKey]
        
        ServiceController.googleGeocodeApi(params, SuccessBlock: { (success, json) in
            CommonClass.stopLoader()

            let status = json["status"].string ?? ""
            
            if status == "OK"{
            
                let result = json["results"].array?.first ?? ["" : "" ]
                let address = result["formatted_address"].string ?? ""
                let geometry = result["geometry"].dictionary ?? ["" : "" ]
                let location = geometry["location"]?.dictionary ?? ["":""]
                let latitude = location["lat"]?.double ?? 0
                let longitude = location["lng"]?.double ?? 0
                
                self.enterLocTextField.text = address
                self.placeDetail["address"] = address
                self.placeDetail["latitude"] = latitude
                self.placeDetail["longitude"] = longitude
                
            }
        }) { (error) in
            
            
            
        }
    }
}




// MARK: ================================
// MARK: LocationManager & MapView Delegate Methods

extension SavedLocationsVC: CLLocationManagerDelegate ,GMSMapViewDelegate{
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        self.zoomState = .zoomin
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if self.zoomState == .zoomin{
            self.googleMapView.camera = GMSCameraPosition(target: manager.location!.coordinate, zoom: 14, bearing: 0, viewingAngle: 0)
        }
    }
    
    // UpdteLocationCoordinate
    func updateLocationoordinates(_ coordinates:CLLocationCoordinate2D) {
        
        if self.zoomState == .zoomin{
            self.zoomState = .zoomout
            self.googleMapView.camera = GMSCameraPosition(target: coordinates, zoom: 16, bearing: 0, viewingAngle: 0)
            
        }
        self.getPlaceDetail(coordinates)
        
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        updateLocationoordinates(position.target)
        
    }
    
    // Camera change Position this methods will call every time
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        var destinationLocation = CLLocation()
        
        if self.mapGesture == true
        {
            destinationLocation = CLLocation(latitude: position.target.latitude,  longitude: position.target.longitude)
            destinationCoordinate = destinationLocation.coordinate
           // updateLocationoordinates(destinationCoordinate!)
            printlnDebug(destinationCoordinate?.latitude)
        }
    }

    
//    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        
//        self.getPlaceDetail(coordinate)
//        self.googleMapView.clear()
//        destinationMarker.position = coordinate
//        let image = UIImage(named:"request_job_location_pin")
//        destinationMarker.icon = image
//        destinationMarker.map = self.googleMapView
//        
//        print(coordinate.latitude)
//    }

    
}


//MARK:- Tableview datasource and delegate

extension SavedLocationsVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedLoc.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedLocationCell", for: indexPath) as! SavedLocationCell
        cell.deleteSaveLocBtn.addTarget(self, action: #selector(SavedLocationsVC.deleteSaveLocTapped(_:)), for: UIControlEvents.touchUpInside)
        cell.addressLbl.text = savedLoc[indexPath.row]["address"] as? String
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func deleteSaveLocTapped(_ sender: UIButton){
        
        guard let indexPath = sender.tableViewIndexPath(self.savedLocTableView) else{return}
        
        let loc = self.savedLoc[indexPath.row]
        
        var params = JSONDictionary()
        params["action"] = "remove"
        params["location"] = CommonClass.getJsonObject(loc)
        CommonClass.startLoader("")
        ServiceController.saveLocationApi(params, SuccessBlock: { (success,json) in
            
            if success{
                
                let result = json["result"].arrayObject ?? [["":""]]
                
                self.savedLoc = result as! JSONDictionaryArray
            
            self.savedLocTableView.reloadData()
            
            if self.savedLoc.isEmpty{
                
                self.enterLocBgView.isHidden = true
                self.googleMapView.isHidden = false
                self.placeHolderView.isHidden = false
            }else{
                self.navigationTitle.text = "SAVED LOCATION"
                
                self.enterLocBgView.isHidden = true
                self.googleMapView.isHidden = true
                self.placeHolderView.isHidden = true
            }
            }
        }) { (error) in
        }
        
    }
    
    
}

class SavedLocationCell: UITableViewCell {
    
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var starImg: UIImageView!
    @IBOutlet weak var deleteSaveLocBtn: UIButton!
}
