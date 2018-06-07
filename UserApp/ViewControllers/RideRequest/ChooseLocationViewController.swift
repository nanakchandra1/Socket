//
//  ChooseLocationViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/22/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON

enum LocationType {
    
    case pickUp, dropoff, none
}

enum ChooseLocState {
    case req, pre
}

protocol TabbarDelegate {
    
    func setSelectedTab(_ index: Int)
}

protocol ManageLocationsDelegate {
    
    func addEditLocation(withLocation location: JSONDictionary)
}

class ChooseLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: IBOutlets
    //MARK:- =================================================
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var previousSavedLocaitonTableView: UITableView!
    @IBOutlet weak var searchedLocationTableView: UITableView!
    @IBOutlet weak var crossBtn: UIButton!
    
    
    // MARK: Variables
    //MARK:- =================================================
    
    var locationType = "Pick-Up"
    var currentLoc = JSONDictionary()
    var locationManager:CLLocationManager!
    var location_Type = LocationType.none
    var delegate: ManageLocationsDelegate!
    var chooseState = ChooseLocState.req
    var numberOfSections = 0
    var zoomState = Zoom_in_Zoom_Out.zoomin
    var matchedLocationsDict = JSONDictionaryArray()
    var savedLoc = JSONDictionaryArray()
    var previousLocationDict = JSONDictionaryArray()
    var country_cod = ""
    let geoCoder = CLGeocoder()

    
    // MARK: View Controller Life Cycle Methods
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getPreviousLocs()
    }
    
    // MARK: Private Methods
    //MARK:- =================================================
    
    func initialSetup() {
        
        self.crossBtn.isHidden = true
        self.previousSavedLocaitonTableView.estimatedRowHeight = 60
        
        self.searchedLocationTableView.estimatedRowHeight = 40

        if self.location_Type == LocationType.pickUp{
            
            self.navigationTitle.text = ChooseLocationTitle.pic
            
        }else{
            
            self.navigationTitle.text = ChooseLocationTitle.drop
            
        }
        
        if CurrentUser.saveLoc != nil  {
            
            self.numberOfSections = self.numberOfSections+1
            
            self.savedLoc = (CurrentUser.saveLoc as? JSONDictionaryArray)!
            
        }
        
        self.locationManager = CLLocationManager()
        
        self.locationManager.delegate = self
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            
            locationManager.startUpdatingLocation()
            
            self.locationManager.startMonitoringSignificantLocationChanges()
            
        }
        
        self.show_GPS_prompt()
        

        locationType = locationType.replacingOccurrences(of: " ", with: "-")
        
        self.title = "Choose Your \(locationType.capitalized)"
        
        self.searchTextField.delegate = self
        
        self.previousSavedLocaitonTableView.dataSource = self
        
        self.previousSavedLocaitonTableView.delegate = self
        
        self.searchedLocationTableView.dataSource = self
        
        self.searchedLocationTableView.delegate = self
        
        self.searchedLocationTableView.isHidden = true
        
        if IsIPhone {
            
            self.searchedLocationTableView.rowHeight = 44
            
            self.previousSavedLocaitonTableView.rowHeight = 35
            
        } else if IsIPad {
            
            self.searchedLocationTableView.rowHeight = 70
            
            self.previousSavedLocaitonTableView.rowHeight = 55
        }
        
        let style = self.searchTextField.defaultTextAttributes[NSParagraphStyleAttributeName] as! NSMutableParagraphStyle
        
        style.minimumLineHeight = (self.searchTextField.font?.lineHeight)! - ((self.searchTextField.font?.lineHeight)! - UIFont(name: "SFUIDisplay-Regular", size: IsIPad ? 22:11.5)!.lineHeight)/2
        
        self.searchTextField.attributedPlaceholder = NSAttributedString(string: "Choose Your \(locationType)", attributes: [NSForegroundColorAttributeName: UIColor(red: 137/255, green: 136/255, blue: 136/255, alpha: 1), NSFontAttributeName: UIFont(name: "SFUIDisplay-Regular", size: IsIPad ? 20:11.5)!, NSParagraphStyleAttributeName: style])
        
        self.searchTextField.addTarget(self, action: #selector(getMatchingLocations), for: .editingChanged)
        
    }
    
    
    func show_GPS_prompt(){
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
                
            case .notDetermined:
                
                print_debug("No access")
                
            case .restricted, .denied:
                
                print_debug("No access")
                
            case .authorizedAlways, .authorizedWhenInUse:
                
                print_debug("Access")
            }
        }
        
    }
    
    
    func setPickUpLocation() {
        
        let params = ["latlng": "\(locationManager.location?.coordinate.latitude ?? 0),\(locationManager.location?.coordinate.longitude ?? 0)", "key": "AIzaSyB0jPK6b0QwIZV8u1hSKLpe8cZsHpot3yc"]
        
        ServiceController.googleGeocodeApi(params, SuccessBlock: { (success, json) in
            
            let status = json["status"].string ?? ""
            
            if status == "OK"{
                
                let result = json["results"].array?.first ?? ["" : "" ]
                
                let address = result["formatted_address"].string ?? ""
                
                let placeId = result["place_id"].string ?? ""
                
                self.currentLoc["address"] = address
                
                self.currentLoc["place_id"] = placeId
                
                self.previousSavedLocaitonTableView.reloadData()
            }
            
        }) { (error) in
            
            
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let currentLocation = locations.first else { return }
        
        if self.zoomState == .zoomin{
            
            self.setPickUpLocation()
            
            self.zoomState = .zoomout
            
        }
        geoCoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            
            guard let currentLocPlacemark = placemarks?.first else { return }
            
            guard let code = currentLocPlacemark.isoCountryCode else{return}
            
            self.country_cod = code
        }
        
    }

    
    
    func getMatchingLocations() {
        
        self.matchedLocationsDict.removeAll()
        
        if !self.searchTextField.text!.isEmpty {
            
            self.searchedLocationTableView.isHidden = false
            self.crossBtn.isHidden = false
            
        } else {
            self.crossBtn.isHidden = true

            self.searchedLocationTableView.isHidden = true
            
        }
        guard let text = self.searchTextField.text, !text.isEmpty && CommonClass.isConnectedToNetwork else {
            
            self.searchedLocationTableView.reloadData()
            
            return
        }
        
        
        let url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(text)&key=\(APIKeys.googleAPIKey)&components=country:\(self.country_cod)"
        
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)

        ServiceController.googlePlacesAPI(encodedUrl!, SuccessBlock: { (success, json) in
            
            let status = json["status"].string ?? ""
            
            let result = json["predictions"].array ?? [["" : "" ]]
            
            guard status == "OK" else {
                
                self.matchedLocationsDict = [["address": status]]
                
                self.searchedLocationTableView.reloadData()
                
                return
                
            }
            
            self.matchedLocationsDict.removeAll()
            
            for location in result {
                
                let place_id = location["place_id"].string ?? ""
                
                let address = location["description"].string ?? ""
                
                let dict = ["place_id": place_id, "address": address]
                
                self.matchedLocationsDict.append(dict)
            }
            
            delay(Double(0.01), closure: {
                
                self.searchedLocationTableView.reloadData()
            })
            
        }) { (error) in
            
            
        }

    }
    
    func matchLocation(_ id: String?) -> Bool {
        
        guard let _ = id else{
            
            return false
            
        }
        
        
        
        for location in self.savedLoc {
            
            if (location["address"] as? String)?.lowercased() == id?.lowercased() {
                
                return true
                
            }
        }
        return false
    }
    
    func getPreviousLocs() {
        
        ServiceController.getPreviousLocations(SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()

            if success{
                
                let locations = json["result"].array ?? [["":""]]
                
            if !locations.isEmpty{
                
                self.previousLocationDict = locations[0]["previous_locs"].arrayObject as? JSONDictionaryArray ?? [["":""]]
            }
            
            if self.previousLocationDict.count > 0 {
                
                self.numberOfSections = self.numberOfSections + 1
                
                self.previousSavedLocaitonTableView.reloadData()
            }
        }
        }) { (error) in
            
            CommonClass.stopLoader()
        }
    }
    
    // MARK: IBActions
    //MARK:- =================================================
    
    @IBAction func searchBtnTapped(_ sender: UIButton) {
        
        if self.searchTextField.isFirstResponder {
            
            self.getMatchingLocations()
            
        } else {
            
            self.searchTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        
        self.searchedLocationTableView.isHidden = true
        
        self.searchTextField.text = ""
        self.crossBtn.isHidden = true
        self.view.endEditing(true)
        
        self.matchedLocationsDict.removeAll()
        
        self.searchedLocationTableView.reloadData()
        
    }
    
    @IBAction func backBtntapped(_ sender: UIButton) {
        self.view.endEditing(true)

        if self.chooseState == .req{
            
            tabbarSelect = 0
            
        }else{
            
            tabbarSelect = 2
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: TableView DataSource Life Cycle Methods
//MARK:- =================================================

extension ChooseLocationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if tableView === self.searchedLocationTableView {
            
            return 1
            
        }
        
        if self.location_Type == LocationType.pickUp {
            
            return self.numberOfSections + 1
            
        } else if self.location_Type == LocationType.dropoff{
            
            return self.numberOfSections
            
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView === self.searchedLocationTableView {
            
            return self.matchedLocationsDict.count
        }
        
        if self.location_Type == LocationType.pickUp {
            
            if section == 0 {
                
                return 1
                
            } else if section == 1 {
                
                return self.previousLocationDict.count
                
            } else if section == 2 {
                
                return self.savedLoc.count
                
            } else {
                
                return 1
                
            }
            
        } else if self.location_Type == LocationType.dropoff{
            
            if section == 0 {
                
                return self.previousLocationDict.count
                
            } else if section == 1 {
                
                return self.savedLoc.count
                
            } else {
                
                return 0
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView === self.previousSavedLocaitonTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PreviousSavedLocationTableViewCell", for: indexPath) as! PreviousSavedLocationTableViewCell
            
            if self.location_Type == LocationType.pickUp {
                
                if indexPath.section == 0 {
                    
                    cell.populate(withLocation: self.currentLoc["address"] as? String ?? "")
                    
                    cell.makeRoundCorners(cell.bounds.height)
                    
                } else if indexPath.section == 1 {
                    
                    cell.populate(withLocation: self.previousLocationDict[indexPath.row]["address"] as? String ?? "")
                    
                    if indexPath.row+1 == self.previousLocationDict.count {
                        
                        cell.makeRoundCorners(cell.bounds.height)
                    }
                    
                } else if indexPath.section == 2 {
                    
                    let data = self.savedLoc[indexPath.row]
                    
                    cell.populate(withLocation: data["address"] as? String ?? "")
                    
                    if indexPath.row+1 == self.savedLoc.count {
                        
                        cell.makeRoundCorners(cell.bounds.height)
                    }
                }
            } else  if self.location_Type == LocationType.dropoff {
                
                if indexPath.section == 0 {
                    
                    cell.populate(withLocation: self.previousLocationDict[indexPath.row]["address"] as? String ?? "")
                    
                    if indexPath.row+1 == self.previousLocationDict.count {
                        
                        cell.makeRoundCorners(cell.bounds.height)
                        
                    }
                } else if indexPath.section == 1 {
                    
                    let data = self.savedLoc[indexPath.row]
                    
                    cell.populate(withLocation: data["address"] as? String ?? "")
                    
                    if indexPath.row+1 == self.savedLoc.count {
                        
                        cell.makeRoundCorners(cell.bounds.height)
                    }
                }
            }
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchedLocationtableViewCell", for: indexPath) as! SearchedLocationtableViewCell
            
            if self.matchedLocationsDict.count > 0{
                
            var location = self.matchedLocationsDict[indexPath.row]["address"] as? String ?? ""
            
            if location == "ZERO_RESULTS" {
                
                location = "NO MATCHING RESULTS FOUND"
                
                self.searchedLocationTableView.allowsSelection = false
                
            } else {
                
                self.searchedLocationTableView.allowsSelection = true
            }
            
            cell.populate(withLocation: location, isSavedLocation: self.matchLocation(location))
            
            if indexPath.row == self.matchedLocationsDict.count-1 {
                
                cell.separatorLineView.isHidden = true
                
            }
            }
            return cell
        }
    }
    
}


// MARK: TableView Delegate Life Cycle Methods
//MARK:- =================================================

extension ChooseLocationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        if tableView === self.searchedLocationTableView {
            return nil
        }
        
        let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.previousSavedLocaitonTableView.frame.width, height: IsIPad ? 50:30))
        sectionHeaderView.backgroundColor = UIColor(red: 29/255, green: 29/255, blue: 29/255, alpha: 1)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.previousSavedLocaitonTableView.frame.width, height: IsIPad ? 50:30))
        view.backgroundColor = UIColor.white
        view.layer.mask = cornerLayer(view.bounds, corners: [.topLeft, .topRight], cgsizeWidth: 3, cgsizeHeight: 3)
        view.clipsToBounds = true
        
        let locationTypeLabel = UILabel(frame: CGRect(x:15, y: sectionHeaderView.center.y, width: view.frame.width-30, height: IsIPad ? 20:15))
        
        locationTypeLabel.font = UIFont(name: "SFUIDisplay-Semibold", size: IsIPad ? 16:11.5)!
        
        let prevText = self.previousLocationDict.count == 0 ? "Previous Location":"Previous Locations"
        
        let savText = self.savedLoc.count == 0 ? "Saved Location":"Saved Locations"
        
        if self.location_Type == LocationType.pickUp {
            
            if section == 0 {
                
                locationTypeLabel.text = "My Location"
                
            }
            else if section == 1 {
                
                locationTypeLabel.text = prevText
                
            }
            else if section == 2 {
                
                locationTypeLabel.text = savText
                
            }
            
        } else  if self.location_Type == LocationType.dropoff {
            
            if section == 0 {
                
                locationTypeLabel.text = prevText
                
            }
            else if section == 1 {
                
                locationTypeLabel.text = savText
                
            }
        }
        
        
        view.addSubview(locationTypeLabel)
        
        sectionHeaderView.addSubview(view)
        
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if tableView === self.searchedLocationTableView {
            
            return nil
            
        }
        return UIView()
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if tableView == self.searchedLocationTableView {
            
            return 0
        }
        
        if self.location_Type == LocationType.pickUp {
            
            if section == 1 && self.previousLocationDict.count == 0 {
                
                return 0
            }
            else if section == 2 && self.savedLoc.count == 0 {
                
                return 0
            }
            
        } else  if self.location_Type == LocationType.dropoff {
            
            if section == 0 && self.previousLocationDict.count == 0 {
                
                return 0
            }
            else if section == 1 && self.savedLoc.count == 0 {
                
                return 0
            }
        }
        
        return IsIPad ? 50:30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if tableView == self.searchedLocationTableView {
            
            return 0
        }
        
        if self.location_Type == LocationType.pickUp {
            
            if section == 1 && self.previousLocationDict.count == 0 {
                
                return 0
            }
            else if section == 2 && self.savedLoc.count == 0 {
                
                return 0
            }
            
        } else  if self.location_Type == LocationType.dropoff {
            
            if section == 0 && self.previousLocationDict.count == 0 {
                
                return 0
            }
            else if section == 1 && self.savedLoc.count == 0 {
                
                return 0
            }
        }
        
        return IsIPad ? 12:8
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        
        guard  CommonClass.isConnectedToNetwork else {
            
            showToastWithMessage(NetworkIssue.slow_Network)
            return
        }
        
        if tableView === self.searchedLocationTableView {
            
            delegate?.addEditLocation(withLocation: self.matchedLocationsDict[indexPath.row])
            
        }
        else{
            
            if self.location_Type == LocationType.pickUp {
                
                if indexPath.section == 0{
                    
                    if !self.currentLoc.isEmpty{
                        
                        delegate?.addEditLocation(withLocation: self.currentLoc)
                        
                    }
                }
                else if indexPath.section == 1{
                    
                    delegate?.addEditLocation(withLocation: self.previousLocationDict[indexPath.row])
                    
                }else if indexPath.section == 2{
                    
                    delegate?.addEditLocation(withLocation: self.savedLoc[indexPath.row])
                    
                }

            }
            else if self.location_Type == LocationType.dropoff{
                
                if indexPath.section == 0{
                
                delegate?.addEditLocation(withLocation: self.previousLocationDict[indexPath.row])
                
            }else if indexPath.section == 1{
                
                delegate?.addEditLocation(withLocation: self.savedLoc[indexPath.row])
                    
                }
            }
        }
        
        if self.chooseState == .req{
            
            tabbarSelect = 0
            
        }else{
            
            tabbarSelect = 2
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: Text Field Delegate Life Cycle Methods
extension ChooseLocationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.getMatchingLocations()
        self.searchTextField.resignFirstResponder()
        return true
    }
}

// MARK:
// MARK: Class for PreviousSavedLocation TableViewCell
class PreviousSavedLocationTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var previousSavedLocationLabel: UILabel!
    
    // Table view cell life cycle methods
    override func prepareForReuse() {
        super.prepareForReuse()
        self.previousSavedLocationLabel.text = nil
        self.layer.mask = cornerLayer(CGRect(x:0, y: 0, width: screenWidth-30, height: IsIPad ? 55:35), corners: [.bottomLeft, .bottomRight], cgsizeWidth: 0, cgsizeHeight: 0)
    }
    
    // MARK: Private Methods
    func populate(withLocation location: String) {
        
        self.previousSavedLocationLabel.text = location
    }
    
    func makeRoundCorners(_ height: CGFloat) {
        
        self.layer.mask = cornerLayer(CGRect(x:0, y: 0, width: screenWidth - 30, height: height), corners: [.bottomLeft, .bottomRight], cgsizeWidth: 3, cgsizeHeight: 3)
    }
}

// MARK: Class for SearchedLocation TableViewCell
//MARK:- =================================================

class SearchedLocationtableViewCell: UITableViewCell {
    // MARK: IBOutlets
    @IBOutlet weak var searchedLocationLabel: UILabel!
    @IBOutlet weak var savedLocationImageView: UIImageView!
    @IBOutlet weak var separatorLineView: UIView!
    
    // Table view cell life cycle methods
    override func prepareForReuse() {
        super.prepareForReuse()
        self.searchedLocationLabel.text = nil
       // self.savedLocationImageView.image = nil
        self.separatorLineView.isHidden = false
    }
    
    // MARK: Private Methods
    func populate(withLocation location: String?, isSavedLocation: Bool) {
        
        self.searchedLocationLabel.text = location
        
        if isSavedLocation {
            
           // self.savedLocationImageView.image = UIImage(named: "request_job_star_select")
            
        } else {
            
            //self.savedLocationImageView.image = UIImage(named: "request_job_star_deselect")
        }
    }
    

}
