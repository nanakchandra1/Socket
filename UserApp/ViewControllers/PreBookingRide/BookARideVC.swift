//
//  BookARideVC.swift
//  UserApp
//  Created by Appinventiv on 23/11/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import CoreLocation

enum DatePickerMode {
    
    case date, time
    
}

class BookARideVC: UIViewController,ManageLocationsDelegate,SetPaymentModeDelegate {
    


    //MARK:- IBOutets
    //MARK:- =================================================
    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var navigationTitle: UILabel!

    @IBOutlet weak var pickUpDotView: UIView!
    @IBOutlet weak var pickUpAddressLabel: UILabel!
    @IBOutlet weak var pickupLbl: UILabel!
    @IBOutlet weak var pickUpEditBtn: UIButton!
    @IBOutlet weak var pickUpDropOffTableView: UITableView!
    @IBOutlet weak var bookArideTableView: UITableView!
    @IBOutlet weak var popUpBgView: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var datePickerBgView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerBgView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var datePickerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var rideView: UIView!
    @IBOutlet weak var doneBtn: UIButton!
    
    //MARK:- Properties
    //MARK:- =================================================
    
    var locationManager:CLLocationManager!
    var zoomState = Zoom_in_Zoom_Out.zoomin
    var pickLocationDict: JSONDictionary = [:]
    var dropLocationDict: [JSONDictionary] = [[:]]
    var tappedIndex = -1
    var isPickedUpLoc = true
    var action = LocationAction.add
    var dictType: DictType!
    var dynamicHeight: CGFloat = 0
    var numberOfLocations = 1
    var dateMode = DatePickerMode.date
    var dateAndTime = [String:String]()
    var vehicleDetail = JSONDictionaryArray()
    var currenLat_long: CLLocationCoordinate2D?
    var p_mode = "Cash"
    var p_mode_img = "payment_method_cash"
    var estimatedDistance : Float = 0.0
    var arrivalTime = ""
    var tripFare = "$0"
    var vehicleList = [MyVehiclesModel]()
    var vehicle = MyVehiclesModel()
    var delegate:GetPrebookingDelegate!

    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.pickUpDropOffTableView.delegate = self
        self.pickUpDropOffTableView.dataSource = self
        self.popUpBgView.isHidden = true
        self.datePickerBottomConstraint.constant = -150
        self.pickUpDropOffTableView.estimatedRowHeight = 40
        self.bookArideTableView.estimatedRowHeight = 40
        self.pickUpDropOffTableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationTableViewCell")
        self.bookArideTableView.register(UINib(nibName: "VehicleDetailcell", bundle: nil), forCellReuseIdentifier: "VehicleDetailcell")
        self.p_mode = CurrentUser.p_mode ?? "Cash"
        printlnDebug(self.p_mode)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.getVehiclesDetail()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- IBActions
    //MARK:- =================================================
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func pickUpEditBtnTapped(_ sender: UIButton) {
        
        self.action = .edit
        self.tappedIndex = -1
        self.navigate(LocationType.pickUp)

    }
   
    
    
    @IBAction func bookRideBtnTapped(_ sender: UIButton) {
        
       
        let pickupLoc = self.pickLocationDict
        
        var dropLoc = self.dropLocationDict
        
        let vehicle = ["no": self.self.vehicle.vehicle_no,"type":self.vehicle.vehicle_type,"model":self.vehicle.vehicle_model,"desc": self.vehicle.vehicle_desc]

        dropLoc.removeLast()
        
        printlnDebug(dropLoc)
        
        if self.isValidate(dropLoc){
  
            CommonClass.startLoader("")

        var params = JSONDictionary()
        
        params["vehicle_type"] = self.vehicle.vehicle_type.lowercased()
        
        params["trip_time"] = self.dateAndTime["date"]!  + " " + self.dateAndTime["showTime"]!
            
        if self.currenLat_long != nil{
            params["current_lat"] = self.currenLat_long?.latitude
            params["current_lon"] = self.currenLat_long?.longitude
        }
        params["estimated_time"] = "10"
        params["vehicle"] = CommonClass.getJsonObject(vehicle as AnyObject)
        params["estimated_distance"] = "10"
        params["pickup_locations"] = CommonClass.getJsonObject(pickupLoc as AnyObject)
        params["drop_locations"] = CommonClass.getJsonObject(dropLoc as AnyObject)
            
        params["p_mode"] = CurrentUser.p_mode ?? "Cash"

        print_debug(params)
            
        ServiceController.scheduleRideApi(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()
            
            showToastWithMessage(json["message"].string ?? "")

            if success{
                
                self.navigationController?.popViewController(animated: true)
                
                self.delegate.getPreBookings()
                
            }
            
        }) { (error) in
            
            CommonClass.stopLoader()
            
        }
        }
        
    }
    
    
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        
        if datePicker.datePickerMode == .date{
            self.setDateTime(.date)
            
        }else{
            self.setDateTime(.time)
        }
        self.datePickerBottomConstraint.constant = -150
    }
    
    
    func paymentModeBtnTapped(_ sender: UIButton){
    
        let paymentScene = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "PaymentMethodID") as! PaymentMethodViewController
        paymentScene.sender = Sender.choosePayment
        
        paymentScene.delegate = self
        
        self.navigationController?.pushViewController(paymentScene, animated: true)
        

    }
    
    
    //MARK:- Methods
    //MARK:- =================================================
    
    
    func setPaymentMode(_ paymentMode: String, paymentImage: String) {
        
        self.p_mode = paymentMode
        self.p_mode_img = paymentImage
        self.bookArideTableView.reloadData()
        
    }

    
    func isValidate(_ drop: JSONDictionaryArray) -> Bool{
    
        if drop.isEmpty{
            showToastWithMessage(RideRelatedString.selectDrop)
            return false

        }else{
            
            if let _ =  self.dateAndTime["date"], let _ = self.dateAndTime["time"]{
                return true
            }else{
                showToastWithMessage(RideRelatedString.selectDate_time)
                
                return false
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
            let geometry = result["geometry"].dictionary ?? ["" : "" ]
            let location = geometry["location"]?.dictionary ?? ["":""]
            let latitude = location["lat"]?.double ?? 0
            let longitude = location["lng"]?.double ?? 0

                
                self.pickUpAddressLabel.text = address
                self.pickLocationDict["address"] = address
                self.pickLocationDict["latitude"] = latitude
                self.pickLocationDict["longitude"] = longitude
                
            }
            
        }) { (error) in
          
            
            
        }
        
    }
    
    
    func addMoreLocationBtnTapped(_ sender: UIButton) {
        
        let cell = sender.superview?.superview as! LocationTableViewCell
        let indexPath = self.pickUpDropOffTableView.indexPath(for: cell)!
        self.tappedIndex = indexPath.row
        action = .add
        
        self.navigate(LocationType.dropoff)
    }
    
    
    func getVehiclesDetail(){
        
        var params = JSONDictionary()
        params["action"] = "view"
        
        ServiceController.getvehicleApi(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()

            if success{
                
            let result = json["result"].arrayValue
            
            self.vehicleList = []
                
                if !result.isEmpty{
                    
                    UserDefaults.save("y" as AnyObject, forKey: NSUserDefaultsKeys.VEHICLES)

                    self.vehicle = MyVehiclesModel(data: result.first!)
                    
                    for res in result{
                        
                        let vehicleDetail = MyVehiclesModel(data: res)
                        self.vehicleList.append(vehicleDetail)
                        
                    }

                }
                
            self.bookArideTableView.delegate = self
            self.bookArideTableView.dataSource = self
            self.bookArideTableView.reloadData()
            
        }
            
        }) { (error) in
            
            CommonClass.stopLoader()
        }
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
    
    
    func addEditLocation(withLocation location: JSONDictionary) {
        
        if self.action == .add {
            
            if self.numberOfLocations < 5 {
                
                self.dropLocationDict.insert(location, at: self.tappedIndex)
                self.numberOfLocations = min(self.numberOfLocations.advanced(by: 1), 4)
                self.pickUpDropOffTableView.reloadData()
                
                if let pId = dropLocationDict[self.tappedIndex]["place_id"] as? String , !pId.isEmpty{
                    self.getPlaceDetail(pId, dict: .drop)
                }else{
                    getEta()
                }
            } else {
                
                showToastWithMessage(RideRelatedString.drop_loc_Limt.localized)
            }
            
        } else if (self.action == .edit) && (self.tappedIndex == -1) {
            
            self.pickLocationDict = location
            self.isPickedUpLoc = false
            self.pickUpAddressLabel.text = location["address"] as? String ?? RideRelatedString.selectPic
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
        
    }
    
    func navigate(_ type: LocationType) {
        
        let chooseLocationScene = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "ChooseLocationViewController") as! ChooseLocationViewController
        
        let locationType = self.getLocationType(forIndex: self.tappedIndex)
        
        chooseLocationScene.locationType = locationType
        chooseLocationScene.delegate = self
        chooseLocationScene.location_Type = type
        chooseLocationScene.chooseState = .pre
        
        self.navigationController?.present(chooseLocationScene, animated: true, completion: nil)
    }
    
    
    func ontapDateBtn(_ sender: UIButton){
        self.datePickerBottomConstraint.constant = 0
        self.datePicker.datePickerMode = .date
    }
    
    
    func ontapTimeBtn(_ sender: UIButton){
        self.datePicker.datePickerMode = .time
        self.datePickerBottomConstraint.constant = 0
    }
    
    
    
    func show_hide_datePicker(){
        
        
    }
    
    
    func setDateTime(_ mode: DatePickerMode){
        
        let dateFormatter = DateFormatter()
        
        if mode == .date{
            
            dateFormatter.dateFormat = "MM-dd-yyyy"
//            self.datePicker.minimumDate = Date()
            let gregorian: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let currentDate: Date = Date()
            var components: DateComponents = DateComponents()
            components.month = 1
            let maxDate: Date = (gregorian as NSCalendar).date(byAdding: components, to: currentDate, options: NSCalendar.Options(rawValue: 0))!
            self.datePicker.maximumDate = maxDate
           // self.datePicker.minimumDate = Date()
            let date = dateFormatter.string(from: self.datePicker.date)
            self.dateAndTime["date"] = date
            
        }else{
            dateFormatter.dateFormat = "HH:mm:ss"
//            self.datePicker.minimumDate = Date()
            let gregorian: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let currentDate: Date = Date()
            var components: DateComponents = DateComponents()
            components.month = 1
            let maxDate: Date = (gregorian as NSCalendar).date(byAdding: components, to: currentDate, options: NSCalendar.Options(rawValue: 0))!
            self.datePicker.maximumDate = maxDate
            //self.datePicker.minimumDate = Date()
            let time = dateFormatter.string(from: self.datePicker.date)
            self.dateAndTime["time"] = time
            dateFormatter.dateFormat = "hh:mm a"
            let showtime = dateFormatter.string(from: self.datePicker.date)

            self.dateAndTime["showTime"] = showtime
            
        }
        self.bookArideTableView.reloadData()
        
    }
    
    func getPlaceDetail(_ placeID: String, dict: DictType) {
        
        let params = [ "placeid" : placeID, "key" : APIKeys.googleAPIKey ]
        
        ServiceController.getLatLong(params, SuccessBlock: { (success, json) in
           
            let status = json["status"].string ?? ""
            
            printlnDebug(json)
            if status == "OK"{
                
                let result = json["result"].dictionaryValue
                let geometry = result["geometry"]?.dictionaryValue
                let location = geometry?["location"]?.dictionaryValue
                let latitude = location?["lat"]?.doubleValue
                let longitude = location?["lng"]?.doubleValue
                
                if dict == .drop {
                    
                    self.dropLocationDict[self.tappedIndex]["latitude"] = latitude
                    self.dropLocationDict[self.tappedIndex]["longitude"] = longitude
                    self.dropLocationDict[self.tappedIndex]["place_id"] = nil
                    
                } else {
                    
                    self.pickLocationDict["latitude"] = latitude
                    self.pickLocationDict["longitude"] = longitude
                    self.pickLocationDict["place_id"] = nil
                }
                
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

                
            }

            
        }) { (error) in
           
            
        }
        
    }
    
    
    func getLocationType(forIndex index: Int) -> String {
        
        if index == -1 {
            
            return "Pick Up"
            
        } else {
            
            return "Drop Off"
        }
    }
    
    
    
    
    func ontapChangeBtn(_ sender: UIButton){
        
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.showHidePopUp(false)
    }
    
    func showHidePopUp(_ show: Bool){
        
        self.popUpBgView.isHidden = show
        self.popUpView.isHidden = !show
        self.pickerBgView.isHidden = show
        self.popUpBgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
    }
    
    @IBAction func pickerDoneBtnTapped(_ sender: UIButton) {
        
        self.showHidePopUp(true)
        self.bookArideTableView.reloadData()
        
    }
    
}


// MARK: Cllocation manager delegate & get ETA
//MARK:- =================================================

extension BookARideVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currenLat_long = manager.location!.coordinate
        
        if self.zoomState == .zoomin{
            self.setPickUpLocation()
            self.zoomState = .zoomout
        }
    }
    
    
    
    
    func getEta() {
        
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
            
            
        }    }
    
    
    
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
        self.arrivalTime = "You'll reach to your destination in \(total) mins"
        
        self.getFare(total)
    }
    
    
    func getFare(_ tot:Int){
        
        
        let params : JSONDictionary = ["trip_type":"valet" ,"estimated_distance": "\(self.estimatedDistance)" ,"estimated_time": "\(tot)" ,"no_of_drops" : "\(self.dropLocationDict.count - 1)" ,"current_city":"singapore" ]
        
        ServiceController.getRideFareApi(params, SuccessBlock: { (success,json) in
            
            if success{

                let result = json["result"].dictionary ?? ["":""]

                let fare  = result["total_fare"]?.string ?? ""
                self.tripFare = "$\(fare)"
                self.bookArideTableView.reloadData()
                
        }
        }) { (error) in
            printlnDebug(error)
        }
    }
}




// MARK: Table View Delegate and datasource
//MARK:- =================================================

extension BookARideVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView === self.pickUpDropOffTableView{
            return self.numberOfLocations
        }else{
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView === self.pickUpDropOffTableView{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as! LocationTableViewCell
            
            let locationAddress = (self.dropLocationDict[indexPath.row]["address"] as? String) ?? "Choose your Drop Off"
            if indexPath.row == 0 {
                
                cell.deleteLocationBtn.isHidden = true
                
            }else if indexPath.row ==  self.numberOfLocations - 1 && self.dropLocationDict.count < 5{
                
                cell.deleteLocationBtn.isHidden = true
            }
            else{
                
                cell.deleteLocationBtn.isHidden = false
                
            }

            cell.populate(atIndex: indexPath.row, withNumberOfLocations: self.numberOfLocations, withLocationAddress: locationAddress)
            
            cell.addMoreLocationBtn.addTarget(self, action: #selector(addMoreLocationBtnTapped(_:)), for: .touchUpInside)
            cell.editLocationBtn.addTarget(self, action: #selector(editLocationBtnTapped(_:)), for: .touchUpInside)
            
            return cell
            
        }else{
            
            if indexPath.row == 0{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "BookRideScheduleCell", for: indexPath) as! BookRideScheduleCell
                cell.setUpView()
                cell.selectDateBtn.addTarget(self, action: #selector(self.ontapDateBtn(_:)), for: UIControlEvents.touchUpInside)
                cell.selectTimeBtn.addTarget(self, action: #selector(self.ontapTimeBtn(_:)), for: UIControlEvents.touchUpInside)
                
                if let date = self.dateAndTime["date"]{
                    cell.dateLbl.text = date
                }
                if let time = self.dateAndTime["showTime"]{
                    cell.timeLbl.text = time
                }
                return cell
            }
            else if indexPath.row == 1{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleDetailcell", for: indexPath) as! VehicleDetailcell
                
                cell.crossBtn.addTarget(self, action: #selector(self.ontapChangeBtn(_:)), for: UIControlEvents.touchUpInside)
                
                cell.populateCell(withVehicle: self.vehicle)
                return cell
                
            }else{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethodCell", for: indexPath) as! PaymentMethodCell
                cell.payMentBtn.addTarget(self, action: #selector(self.paymentModeBtnTapped(_:)), for: UIControlEvents.touchUpInside)
                cell.fareLbl.text = self.tripFare
                
                
                    if self.p_mode.lowercased() == PaymentMode.cash.lowercased(){
                        
                        cell.paymentTypeLbl.text = PaymentMode.cash
                        cell.selectCardImg.image = UIImage(named: "payment_method_cash")
                        
                    }else{
                        cell.paymentTypeLbl.text = PaymentMode.card
                        cell.selectCardImg.image = UIImage(named: "payment_method_card")

                    }
                    
                cell.selectCardImg.image = UIImage(named: self.p_mode_img)
                return cell
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView === self.pickUpDropOffTableView{
            self.rideView.frame = CGRect(x: 0, y: 0,width: screenWidth   , height: CGFloat(50 * self.dropLocationDict.count) + 50.0)
            return UITableViewAutomaticDimension
        }else{
            if indexPath.row == 0{
                return 111
            }
            if indexPath.row == 1{
                return UITableViewAutomaticDimension
            }else{
                return 111
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === self.pickUpDropOffTableView{
            
            if (self.dropLocationDict[indexPath.row]["address"] == nil) || (self.dropLocationDict[indexPath.row]["address"] as! String).isEmpty {
                
                self.addMoreLocation(atIndex: indexPath.row)
                
            } else {
                
                self.editDropLocation(atIndex: indexPath.row)
                
            }
        }
    }
}

//MARK:- Picker view delegate and datasource
//MARK:- =================================================


extension BookARideVC: UIPickerViewDelegate,UIPickerViewDataSource{
    
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
        
        self.vehicle = self.vehicleList[row]
    }
}



//MARK:- TableView cell classess
//MARK:- =================================================

class PaymentMethodCell: UITableViewCell{
    
    
    @IBOutlet weak var fareLbl: UILabel!
    @IBOutlet weak var selectCashBtn: UIImageView!
    @IBOutlet weak var totalfareLbl: UILabel!
    @IBOutlet weak var selectCardImg: UIImageView!
    @IBOutlet weak var paymentTypeLbl: UILabel!
    @IBOutlet weak var paymentModeLbl: UILabel!
    @IBOutlet weak var payMentBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}

class BookRideScheduleCell: UITableViewCell{
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var selectDateBtn: UIButton!
    @IBOutlet weak var selectTimeBtn: UIButton!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var timeView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectDateBtn.layer.borderWidth = 1
        self.selectTimeBtn.layer.borderWidth = 1
        self.selectDateBtn.layer.cornerRadius = 3
        self.selectTimeBtn.layer.cornerRadius = 3

    }
    
    func setUpView(){
        self.dateView.layer.cornerRadius = 3
        self.timeView.layer.cornerRadius = 3

    }
    
}
