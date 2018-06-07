//
//  PreBookingVC.swift
//  UserApp
//
//  Created by Appinventiv on 23/11/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

protocol CancelPrebookingDelegate {
    func refreshPreBooking()
}

class PreBookingVC: UIViewController , GetPrebookingDelegate{
    
    //MARK:- IBOutelets
    //MARK:- =================================================
    
    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var prebookingTableView: UITableView!
    @IBOutlet weak var addMoreRideBtn: UIButton!
    
    //MARK:- Properties
    //MARK:- =================================================
    
    
    var ridrHistory = JSONDictionaryArray()
    var prebookingsList = [PrebookingsModel]()
    var selectedIndexPath: IndexPath!
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prebookingTableView.delegate = self
        self.prebookingTableView.dataSource = self
        self.navigationTitle.text = "PRE BOOKING"
        self.prebookingTableView.register(UINib(nibName: "PickUpTripDetailCell" ,bundle: nil), forCellReuseIdentifier: "PickUpTripDetailCell")
        navigationView.setMenuButton()
        self.getRideHistory()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:- IBActions
    //MARK:- =================================================
    
    
    @IBAction func addMoreRideTapped(_ sender: UIButton) {
        
        let obj = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "BookARideVC") as! BookARideVC
        obj.delegate = self
        self.navigationController?.pushViewController(obj, animated: true)
        
    }
    
    //MARK:- Methods
    //MARK:- =================================================
    
    
    func getRideHistory(){
        
        var params = JSONDictionary()
        
        params["action"] = "user"
        
        CommonClass.startLoader("")
        
        ServiceController.rideHistoryApi(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()
            
            self.prebookingsList = []
            
            if success{
                
                let result = json["result"].dictionaryValue
                
                let prebookings = result["upcoming"]?.arrayValue
                
                for res in prebookings!{
                    
                    let details = PrebookingsModel(data: res)
                    self.prebookingsList.append(details)
                    
                }
                
                self.prebookingTableView.reloadData()
                showNodata(self.prebookingsList, tableView: self.prebookingTableView, msg: NO_PREBOOKING, color: .white)
            }
        }) { (error) in
            
            CommonClass.stopLoader()
        }
    }
    
    
    func getPreBookings() {
        
        self.getRideHistory()
        
    }
    
}

//MARK:- Tableview dalegate and datasource
//MARK:- =================================================

extension PreBookingVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.prebookingsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickUpTripDetailCell", for: indexPath) as! PickUpTripDetailCell
        
        delay(0.1) {
            cell.setUpView()
        }
        
        let details = self.prebookingsList[indexPath.row]
        
        cell.userName.text = details.user_name
        
        if let imageUrl = URL(string: details.userImage()){
            
            cell.userImg.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_place_holder"))
        }
        
        cell.fromAddressLabel.text = details.pickup
        
        cell.rateLbl.text = "$\(details.p_amount!)"
        
        let date = details.date_created.convertTimeWithTimeZone(formate: DateFormate.dateWithTime)
        
        cell.datelbl.text = date
        
        switch details.dropCount {
            
        case 0:
            
            print_debug("Nothing")
            
        case 1:
            
            cell.toAddressLabel1.text = details.drop1
            cell.hideShow(false, second: true, third: true, fourth: true)
            
        case 2:
            
            cell.toAddressLabel1.text = details.drop1
            cell.toAddressLabel2.text = details.drop2
            cell.hideShow(false, second: false, third: true, fourth: true)
            
        case 3:
            
            cell.toAddressLabel1.text = details.drop1
            cell.toAddressLabel2.text = details.drop2
            cell.toAddressLabel3.text = details.drop3
            cell.hideShow(false, second: false, third: false, fourth: true)
            
        case 4:
            
            cell.toAddressLabel1.text = details.drop1
            cell.toAddressLabel2.text = details.drop2
            cell.toAddressLabel3.text = details.drop3
            cell.toAddressLabel4.text = details.drop4
            
            cell.hideShow(false, second: false, third: false, fourth: false)
            cell.toAddressLabel1.isHidden = false
            cell.toAddressLabel2.isHidden = false
            cell.toAddressLabel3.isHidden = false
            cell.toAddressLabel4.isHidden = false
            cell.toCircleView1.isHidden = false
            cell.toCircleView2.isHidden = false
            cell.toCircleView3.isHidden = false
            cell.toCircleView4.isHidden = false
            
        default:
            
            fatalError("LIMIT EXCEED")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let details = self.prebookingsList[indexPath.row]
        
        switch details.dropCount {
            
        case 0:
            
            print_debug("Nothing")
            
        case 1:
            
            let pic = details.pickup.boundingRect(with: CGSize(width: screenWidth-80, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
            
            let title = details.drop1.boundingRect(with: CGSize(width: screenWidth-100, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
            
            let heiht = title.height + pic.height + 150
            
            return heiht
            
        case 2:
            
            let pic = details.pickup.boundingRect(with: CGSize(width: screenWidth-80, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
            
            let title = details.drop1.boundingRect(with: CGSize(width: screenWidth-80, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
            
            let title2 = details.drop2.boundingRect(with: CGSize(width: screenWidth-80, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
            
            let heiht = title.height + title2.height + pic.height + 160
            
            return heiht
            
        case 3:
            
            let pic = details.pickup.boundingRect(with: CGSize(width: screenWidth-73, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
            
            let title = details.drop1.boundingRect(with: CGSize(width: screenWidth-100, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
            
            let title2 = details.drop2.boundingRect(with: CGSize(width: screenWidth-100, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
            
            let title3 = details.drop3.boundingRect(with: CGSize(width: screenWidth-100, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
            
            let heiht = title.height + title2.height + title3.height + pic.height + 170
            
            return heiht
            
        case 4:
            
            let pic = details.pickup.boundingRect(with: CGSize(width: screenWidth-110, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
            
            let title = details.drop1.boundingRect(with: CGSize(width: screenWidth-110, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
            
            let title2 = details.drop2.boundingRect(with: CGSize(width: screenWidth-110, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
            
            let title3 = details.drop3.boundingRect(with: CGSize(width: screenWidth-110, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
            
            let title4 = details.drop4.boundingRect(with: CGSize(width: screenWidth-110, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont(name: fontName, size: 12)!], context: nil)
            
            let heiht = title.height + title2.height + title3.height + title4.height + pic.height + 180
            
            return heiht
            
        default:
            
            fatalError("LIMIT EXCEED")
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let obj = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "PrebookingDetailVC") as! PrebookingDetailVC
        obj.rideDetail = self.prebookingsList[indexPath.row]
        obj.delegate = self
        self.selectedIndexPath = indexPath
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
}



