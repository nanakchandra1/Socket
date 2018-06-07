//
//  MyVehicleViewController.swift
//  UserApp
//
//  Created by Aakash Srivastav on 10/4/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum VehicleAddState {
    
    case new, add, edit
    
}



class MyVehicleViewController: UIViewController {

    // MARK: IBOutlets
    //MARK:- =================================================

    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var myVehicleTableView: UITableView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var addNewVehicleBtn: UIButton!
    
    // MARK: Variables
    //MARK:- =================================================

    var dynamicHeight: CGFloat = 0
    var vehicleDetail = JSONDictionaryArray()
    var vehicleList = [MyVehiclesModel]()
    var selectedIndex: Int?
    var vehicleState = VehicleAddState.new
    var editedIndex: Int?
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationView.setMenuButton()
        
        self.initialSetup()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.myVehicleTableView.separatorStyle = .none
        self.myVehicleTableView.estimatedRowHeight = 100
        self.getVehiclesDetail()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.selectedIndex = nil
    }
    
    // MARK:IBActions
    //MARK:- =================================================

    @IBAction func addNewVehicleBtnTapped(_ sender: UIButton) {
        
        self.vehicleState = .add
        self.selectedIndex = nil
        self.editedIndex = nil

        let obj = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "AddVehicleViewController") as! AddVehicleViewController
        obj.addvehicleState = .add
        obj.sender = .myVehicle
        self.navigationController?.pushViewController(obj, animated: true)
        
    }
    
    // MARK: Private Methods
    //MARK:- =================================================

    func initialSetup() {
        
        self.myVehicleTableView.dataSource = self
        self.navigationTitle.text = MY_VEHICLES.localized
        self.addNewVehicleBtn.setTitle(ADD_NEW_VEHICLES.localized, for: .normal)
        self.myVehicleTableView.delegate = self
        self.myVehicleTableView.register(UINib(nibName: "MyVehicleTableViewCell", bundle: nil), forCellReuseIdentifier: "MyVehicleTableViewCell")
    }
    
    func getVehiclesDetail(){
        
        CommonClass.startLoader("")
        var params = JSONDictionary()
        params["action"] = "view"
        ServiceController.getvehicleApi(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()

            if success{
                
                self.vehicleDetail = json["result"].arrayObject as! JSONDictionaryArray
                
                let result = json["result"].arrayValue
                
                self.vehicleList = []
                
                for res in result{
                    
                    UserDefaults.save("y", forKey: NSUserDefaultsKeys.VEHICLES)

                    let vehicleDetail = MyVehiclesModel(data: res)
                    self.vehicleList.append(vehicleDetail)
                    
                }
                
                if self.vehicleState == .edit{
                
                    self.scrollTableView(self.editedIndex!)
                    
                }else if self.vehicleState == .add{
                    
                    printlnDebug(self.vehicleList.count - 1)
                    self.myVehicleTableView.scrollToRow(at: IndexPath(row: 0, section: self.vehicleList.count - 2), at: .none, animated: true)

                }
                
                self.myVehicleTableView.reloadData()
                
                
            }
            
        }) { (error) in
            
            printlnDebug(error)
            CommonClass.stopLoader()
        }
    }
    
    
    
    func scrollTableView(_ row: Int) {
        
        self.myVehicleTableView.scrollToRow(at: IndexPath(row: 0, section: row), at: .none, animated: false)
        
    }
    
    func crossBtnTapped(_ sender: UIButton){
    self.vehicleState = .new
        if let indexPath = sender.tableViewIndexPath(self.myVehicleTableView) {
            self.selectedIndex = indexPath.section
            sender.isSelected = !sender.isSelected
            self.myVehicleTableView.reloadData()
        }
    }
    
    
    
    func editVehicleTapped(_ sender: UIButton){
        
        if let indexPath = sender.tableViewIndexPath(self.myVehicleTableView){
            
            self.vehicleState = .edit
            self.editedIndex = indexPath.section
            let cell = self.myVehicleTableView.cellForRow(at: indexPath) as! MyVehicleTableViewCell
            cell.crossBtn.isSelected = !cell.crossBtn.isSelected
            
            let obj = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "AddVehicleViewController") as! AddVehicleViewController
            obj.allVehiclesDetail = self.vehicleDetail
            obj.index = indexPath.section
            obj.editedVehicleDetail = self.vehicleDetail[indexPath.section]
            obj.addvehicleState = VehicleAddState.edit
            obj.sender = .myVehicle
            self.navigationController?.pushViewController(obj, animated: true)
        }
    }
    
    
    func deleteBtnTapped(_ sender: UIButton){
        
        
        guard self.vehicleList.count > 1 else {
            
            showToastWithMessage(ProfileStrings.vehicleNeed)
            return
        }
        
        if let indexPath = sender.tableViewIndexPath(self.myVehicleTableView){
            
                var params = JSONDictionary()
                
                params["action"] = "remove"
            
                params["vehicle_no"] = self.vehicleList[indexPath.section].vehicle_no
            
            var temp_params = [String:String]()
            
            temp_params["type"] = self.vehicleList[indexPath.section].vehicle_type.lowercased()
            temp_params["no"] = self.vehicleList[indexPath.section].vehicle_no
            temp_params["model"] = self.vehicleList[indexPath.section].vehicle_model
            temp_params["desc"] = self.vehicleList[indexPath.section].vehicle_desc
            
            
            params["vehicle"] =  CommonClass.getJsonObject(temp_params as AnyObject)

            printlnDebug(params)

                CommonClass.startLoader("")
            
                ServiceController.update_remove_VehicleApi(params, SuccessBlock: { (success,json) in

                    CommonClass.stopLoader()

                    if success{
                        
                        self.selectedIndex = nil
                        self.vehicleList.remove(at: indexPath.section)
                        isvehecleAdd = true
                        sdeletedVehicle = 0
                        self.myVehicleTableView.reloadData()
                        showToastWithMessage(REMOVED.localized)
                        
                    }
                    
                    }, failureBlock: { (error) in
                        
                        CommonClass.stopLoader()
                })
                
        }
        
    }    
    
}

// MARK: Table View Datasource and Delegate Life Cycle Methods
//MARK:- =================================================

extension MyVehicleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.vehicleList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyVehicleTableViewCell", for: indexPath) as! MyVehicleTableViewCell
        
        if self.selectedIndex == indexPath.section {
            
            cell.btnBgView.isHidden = false
        }
        else{
            
            cell.btnBgView.isHidden = true
        }
        
        cell.crossBtn.addTarget(self, action: #selector(self.crossBtnTapped(_:)), for: UIControlEvents.touchUpInside)
         cell.editBtn.addTarget(self, action: #selector(self.editVehicleTapped(_:)), for: UIControlEvents.touchUpInside)
        cell.deleteBtn.addTarget(self, action: #selector(self.deleteBtnTapped(_:)), for: UIControlEvents.touchUpInside)
        
        cell.populateCell(withVehicle: self.vehicleList[indexPath.section])
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedIndex = nil
        self.editedIndex = nil
        self.myVehicleTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension

       // return (IsIPad ? 250:212)+dynamicHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        //return (IsIPad ? 250:212)+dynamicHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = UIColor(red: 29/255, green: 29/255, blue: 29/255, alpha: 1)
        
        return view
    }
}
