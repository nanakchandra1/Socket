//
//  ChangeDestinationPopUpVC.swift
//  UserApp
//
//  Created by Appinventiv on 07/11/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import CoreLocation
import MFSideMenu
import SwiftyJSON

protocol ChangeDestinationDelegete {
    func changeDropStatus(with deatil: RideDetailModel)
}

enum PopUpSelectionState{

    case changeDestination, waiting, updated, none
}


class ChangeDestinationPopUpVC: UIViewController{

    
    //MARK:- IBOUTLETS
    //MARK:- =================================================

    @IBOutlet weak var areYouSureLbl: UILabel!
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var changeLocBgView: UIView!
    @IBOutlet weak var selectlocBgView: UIView!
    @IBOutlet weak var changeDestiTableView: UITableView!
    @IBOutlet weak var selectLocTextField: UITextField!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var reasonBgView: UIView!
    @IBOutlet weak var changeRoyteBtn: UIButton!
    @IBOutlet weak var waitingBgView: UIView!
    @IBOutlet weak var witingMsgLbl: UILabel!
    @IBOutlet weak var updatedBgView: UIView!
    @IBOutlet weak var updatedLbl: UILabel!
    @IBOutlet weak var dropOffpositionBfView: UIView!
    @IBOutlet weak var dropOffNoLbl: UILabel!
    @IBOutlet weak var selectPosiconImg: UIImageView!
    @IBOutlet weak var selectDropPosBtn: UIButton!
    @IBOutlet weak var pickerBgView: UIView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var changeDestPpopUpHeight: NSLayoutConstraint!
    @IBOutlet weak var chooseDropHeight: NSLayoutConstraint!
    
    //MARK:- Properties
    //MARK:- =================================================

    var locationManager:CLLocationManager!
    let geoCoder = CLGeocoder()

    var popUpSelection = PopUpSelectionState.changeDestination
    var rideDetail = RideDetailModel()
    var matchedLocationsDict = [[String: String]]()
    var changedLoc = JSONDictionary()
    var dropLoc = JSONDictionaryArray()
    let noOfDrop = ["DROP OFF- 1","DROP OFF- 2","DROP OFF- 3","DROP OFF- 4"]
    var index = 0
    var ride_id = ""
    var searchText = ""
    var status_timer = Timer()
    var country_cod = ""
    var delegate:ChangeDestinationDelegete!


    //MARK:- View life cycle
    //MARK:- =================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectLocTextField.delegate = self
        self.reasonTextView.delegate = self
        self.changeDestinationRes()
        printlnDebug(self.rideDetail)
        self.setLayOut()
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mfSideMenuContainerViewController.panMode = MFSideMenuPanModeNone

        if self.popUpSelection == .updated{
            
            CommonClass.delay(3, closure: {
                hideContentController(self)
            })
        
        }
        
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
        }

        
        var tapGasture =  UITapGestureRecognizer()
        tapGasture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { (notification:Notification!) -> Void in
            
            self.view.addGestureRecognizer(tapGasture)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil,
                                                                
                                                                queue: OperationQueue.main) {_ in
                                                                    
                                                                    self.view.removeGestureRecognizer(tapGasture)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mfSideMenuContainerViewController.panMode = MFSideMenuPanModeDefault

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.view.endEditing(true)
    }
    
    deinit {
        self.selectLocTextField.endEditing(true)
        self.reasonTextView.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    // MARK: Private Methods
    //MARK:- =================================================
    
    fileprivate func setLayOut(){
        
        
        self.dropOffpositionBfView.layer.borderWidth = 1
        self.dropOffpositionBfView.layer.borderColor = UIColor.gray.cgColor
        self.dropOffpositionBfView.layer.cornerRadius = 2
        
        self.selectlocBgView.layer.borderWidth = 1
        self.selectlocBgView.layer.borderColor = UIColor.gray.cgColor
        self.selectlocBgView.layer.cornerRadius = 2
        self.reasonBgView.layer.borderWidth = 1
        self.reasonBgView.layer.borderColor = UIColor.gray.cgColor
        self.reasonBgView.layer.cornerRadius = 2
        self.pickerBgView.isHidden = true
        
        self.dropLoc = self.rideDetail.dropLocations
        
        if self.dropLoc.count <= 1{
            self.changeDestPpopUpHeight.constant = 300
            self.chooseDropHeight.constant = 0
        }else{
            self.changeDestPpopUpHeight.constant = 350
            self.chooseDropHeight.constant = 42
        }
            self.showHidePopups()
        
        self.selectLocTextField.addTarget(self, action: #selector(getMatchingLocations), for: .editingChanged)

    }
    
    
    func showHidePopups(){
        
            if self.rideDetail.drop.count == 1{
                
                self.dropOffpositionBfView.isHidden = true
            }
        
        if self.popUpSelection == .changeDestination{
            
            self.changeLocBgView.isHidden = false
            self.waitingBgView.isHidden = true
            self.updatedBgView.isHidden = true
            self.changeDestiTableView.delegate = self
            self.changeDestiTableView.dataSource = self
            
        }else if self.popUpSelection == .waiting{
            
            self.changeLocBgView.isHidden = true
            self.waitingBgView.isHidden = false
            self.updatedBgView.isHidden = true
            
        }else if self.popUpSelection == .updated{
            
            self.changeLocBgView.isHidden = true
            self.waitingBgView.isHidden = true
            self.updatedBgView.isHidden = false
        }

    }
    
    
    fileprivate func changeDestinationRes(){
    
        SocketServicesController.changeDestination_res({ (success, data) in
            
            printlnDebug(data)
            
            self.popUpSelection = .waiting
            
            self.showHidePopups()
            
            self.changeDestinationRes_status()
            
        }) { 
            
        }
    
    }
    
    
    fileprivate func changeDestinationRes_status(){
        
        SocketServicesController.changeDestination_status({ (success, data) in
            
            printlnDebug(data)
            self.rideDetail = RideDetailModel(with: data)
            
            if self.rideDetail.cd_status == Status.two{
                
                self.popUpSelection = .updated
                self.updatedLbl.text = RideRelatedString.changeDest_updatedLoc
                self.delegate.changeDropStatus(with: self.rideDetail)

            }else if self.rideDetail.cd_status == Status.one || self.rideDetail.cd_status == Status.three{
                
                self.popUpSelection = .updated
                self.updatedLbl.text = RideRelatedString.changeDest_rejected
                
            }
            
            self.showHidePopups()
            
            CommonClass.delay(3, closure: {
                
                hideContentController(self)
                
            })
            
        }) {
            
        }
        
    }
    
    func dismissKeyboard(_ sender: AnyObject)
    {
        self.view.endEditing(true)
    }

    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.selectLocTextField.endEditing(true)
        self.reasonTextView.endEditing(true)
    }
    
    
    
    
    func displayContentController(_ content: UIViewController) {
        
        addChildViewController(content)
        self.view.addSubview(content.view)
        content.didMove(toParentViewController: self)
    }


    
    func getJsonObject(_ Detail: AnyObject) -> String{
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
    
    
    

    
    
    //MARK:- IBActions
    //MARK:- =================================================
    
    
    @IBAction func onTapChangeRoute(_ sender: UIButton) {
        
        self.selectLocTextField.endEditing(true)
        self.reasonTextView.endEditing(true)

        if !self.matchedLocationsDict.isEmpty{
            
            if !self.selectLocTextField.hasText{
                showToastWithMessage(RideRelatedString.changeDest_selectLoc)
                return
            }

            if let _ = self.matchedLocationsDict.first!["place_id"]{
                self.changeDest_loc()
            }else{
                showToastWithMessage(RideRelatedString.changeDest_selectLoc)
            }
        }
    }
    
    
    
    
    @IBAction func onTapCrossBtn(_ sender: UIButton) {
        
        hideContentController(self)
        
    }
    
    
    
    @IBAction func selectPositionBtnTapp(_ sender: UIButton) {
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerBgView.isHidden = false
        
    }
    
    
    
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        
        self.pickerBgView.isHidden = true
        
    }
    
}

// MARK: Web services call methods
//MARK:- =================================================

extension ChangeDestinationPopUpVC{
    
    
   fileprivate func changeDest_loc(){
    
        var params = JSONDictionary()
        
        self.dropLoc.remove(at: self.index)
        self.dropLoc.insert(changedLoc, at: self.index)
    
        params["cd_position"] = self.index
        
        params["ride_id"] = self.rideDetail.ride_id
        
        params["drop_locations"] = JSONDictionaryArray(dropLoc)
        params["cur_total_fare"] = "10"
        params["estimated_distance"] = "10"
        params["estimated_time"] = "10"
        params["country"] = "singapore"
        params["driver_id"] = self.rideDetail.driver_id
    
        printlnDebug(params)
        SocketServicesController.changeDestination(params)
        
    }
    
    
    func getMatchingLocations() {
        
        self.matchedLocationsDict.removeAll()
        
        if !self.selectLocTextField.text!.isEmpty {
            
            self.changeDestiTableView.isHidden = false
            
        } else {
            
            self.changeDestiTableView.isHidden = true
        }
        
        guard let text = self.selectLocTextField.text, !text.isEmpty && CommonClass.isConnectedToNetwork else {
            
            self.changeDestiTableView.reloadData()
            
            return
        }
        
        
        let url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(text)&key=\(APIKeys.googleAPIKey)&components=country:\(self.country_cod)"
        
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        ServiceController.googlePlacesAPI(encodedUrl!, SuccessBlock: { (success, json) in
            
            let status = json["status"].string ?? ""
            
            let result = json["predictions"].array ?? [["" : "" ]]
            
            guard status == "OK" else {
                
                self.matchedLocationsDict = [["address": status]]
                
                self.changeDestiTableView.reloadData()
                
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
                
                self.changeDestiTableView.reloadData()
            })
            
        }) { (error) in
            
        }
        
    }
    
    
    func getPlaceDetail(_ placeID: String,index: Int) {
        
        let params = [ "placeid" : placeID, "key" : APIKeys.googleAPIKey ]
        
        ServiceController.getLatLong(params, SuccessBlock: { (success, json) in
            
            let status = json["status"].string ?? ""
            let result = json["result"].dictionaryObject ?? ["" : "" ]

            
            if status == "OK" {
                
                if let geometry = result["geometry"] as? JSONDictionary, let location = geometry["location"] as? JSONDictionary, let latitude = location["lat"] as? Double, let longitude = location["lng"] as? Double {
                    
                    var changelocation = JSONDictionary()
                    
                    changelocation["latitude"] = latitude
                    
                    changelocation["longitude"] = longitude
                    
                    changelocation["place_id"] = ""
                    
                    changelocation["address"] = self.matchedLocationsDict[index]["address"] ?? ""
                    
                    self.changedLoc = changelocation
                    
                } else {
                    
                    showToastWithMessage(status)
                }
            }
            
        }) { (error) in
            
            
        }
    }
}

//MARK:- UITextfield delegate
//MARK:- =================================================


extension ChangeDestinationPopUpVC: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.getMatchingLocations()
        self.selectLocTextField.resignFirstResponder()
        return true
        
    }

    
}



//MARK:- UITextview delegate
//MARK:- =================================================


extension ChangeDestinationPopUpVC: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        textView.text = ""
    }

}



//MARK:- UITableview delegate Datasource
//MARK:- =================================================


extension ChangeDestinationPopUpVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.matchedLocationsDict.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChangeDestiCell", for: indexPath) as! ChangeDestiCell
        
        if indexPath.row <= self.matchedLocationsDict.count - 1{
            let location = self.matchedLocationsDict[indexPath.row]["address"] ?? ""
            cell.changeDestiCell.text = location
        }
        

        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectLocTextField.text = ""
        printlnDebug(self.matchedLocationsDict)
        self.changeDestiTableView.isHidden = true
        
        if let placeid = self.matchedLocationsDict[indexPath.row]["place_id"]{
            
            self.getPlaceDetail(placeid,index: indexPath.row)
            self.selectLocTextField.text = self.matchedLocationsDict[indexPath.row]["address"] ?? ""

        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}



//MARK:- Picker view delegate and datasource
//MARK:- =================================================


extension ChangeDestinationPopUpVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return self.dropLoc.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        printlnDebug(self.noOfDrop[row])
        return self.noOfDrop[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.dropOffNoLbl.text = self.noOfDrop[row]
        self.index = row
        
    }
    
}


// MARK: Cllocation manager delegate
//MARK:- =================================================

extension ChangeDestinationPopUpVC: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first else { return }
        
        geoCoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            guard let currentLocPlacemark = placemarks?.first else { return }
            guard let code = currentLocPlacemark.isoCountryCode else{return}
            self.country_cod = code
        }
    }
    


}

//MARK:- Tableview cell classess
//MARK:- =================================================


class ChangeDestiCell: UITableViewCell{

    @IBOutlet weak var changeDestiCell: UILabel!
}
