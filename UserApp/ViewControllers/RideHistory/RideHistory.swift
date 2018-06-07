//
//  PreBookingVC.swift
//  UserApp
//
//  Created by Appinventiv on 23/11/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import SwiftyJSON

class RideHistory: UIViewController {
    
    //MARK:- IBOutelets
    //MARK:- =================================================

    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var rideHistoryTableView: UITableView!
    
    
    //MARK:- Properties
    //MARK:- =================================================

    
    var ridrHistory = JSONDictionaryArray()
    var historyList = [HistoryModel]()

    //MARK:- View life cycle
    //MARK:- =================================================

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.rideHistoryTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.rideHistoryTableView.delegate = self
        self.rideHistoryTableView.dataSource = self
       // self.rideHistoryTableView.registerNib(UINib(nibName: "PickUpTripDetailCell" ,bundle: nil), forCellReuseIdentifier: "PickUpTripDetailCell")
        navigationView.setMenuButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getRideHistory()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
 
    
    //MARK:- Methods
    //MARK:- =================================================

    func getRideHistory(){
        
        var params = JSONDictionary()
        params["action"] = "user" as AnyObject
        CommonClass.startLoader("")
        ServiceController.rideHistoryApi(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()
            
            if success{
            
                let result = json["result"].dictionaryValue
                let history = result["history"]?.arrayValue
                self.historyList = []
                
                for res in history!{
                
                    let historyDetail = HistoryModel(data: res)
                    self.historyList.append(historyDetail)
                }
                self.rideHistoryTableView.reloadData()
                
                showNodata(self.historyList, tableView: self.rideHistoryTableView, msg: NO_HISTORY, color: .white)

            }
            
        }) { (error) in
            
            CommonClass.stopLoader()
        }
    }
}


//MARK:- Tableview dalegate and datasource
//MARK:- =================================================

extension RideHistory: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.historyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RideHistoryCell", for: indexPath) as! RideHistoryCell
        
        delay(0.1) {
            cell.setUpView()
        }
        
        let details = self.historyList[indexPath.row]
        
            cell.userName.text = details.user_name
        
         let status = details.status
            
            if status == Status.five{
                cell.rideStatus.text = C_ONRIDE.localized
                
            }else if status == Status.one{
                cell.rideStatus.text = C_ARRIVAL_NOW.localized
                
            }else if status == Status.seven{
                cell.rideStatus.text = C_CANCELLED.localized
                
            }else if status == Status.six{
                cell.rideStatus.text = C_COMPLETED.localized
            }

        
            if let imageUrl = URL(string: details.userImage()){
                
                cell.userImg.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_place_holder"))
                
            }
        
            cell.fromAddressLabel.text = details.pickup
        
            cell.rateLbl.text = "$\(details.p_amount!)"
        
            let date = details.start_time.convertTimeWithTimeZone( formate: DateFormate.dateWithTime)
        
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
        
        let details = self.historyList[indexPath.row]

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
    
    
}



//MARK:- UITableview cell classess

class RideHistoryCell: UITableViewCell {
    
    // MARK: =========
    // MARK: IBOutlets
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var rateLbl: UILabel!
    @IBOutlet weak var fromCircleView: UIView!
    @IBOutlet weak var fromAddressLabel: UILabel!
    
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var toLbl: UILabel!
    @IBOutlet weak var toCircleView1: UIView!
    @IBOutlet weak var toAddressLabel1: UILabel!
    
    @IBOutlet weak var toCircleView2: UIView!
    @IBOutlet weak var toAddressLabel2: UILabel!
    
    @IBOutlet weak var toCircleView3: UIView!
    @IBOutlet weak var toAddressLabel3: UILabel!
    
    @IBOutlet weak var toCircleView4: UIView!
    @IBOutlet weak var toAddressLabel4: UILabel!
    @IBOutlet weak var rideStatus: UILabel!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // MARK: =========
    // MARK: Private Methods
    
    func setUpView(){
        
        self.fromCircleView.layer.cornerRadius = 4
        self.toCircleView1.layer.cornerRadius = 4
        self.toCircleView2.layer.cornerRadius = 4
        self.toCircleView3.layer.cornerRadius = 4
        self.toCircleView4.layer.cornerRadius = 4
        
        self.toCircleView1.layer.masksToBounds = true
        self.toCircleView2.layer.masksToBounds = true
        self.toCircleView3.layer.masksToBounds = true
        self.toCircleView4.layer.masksToBounds = true
        
        self.userImg.layer.cornerRadius = self.userImg.bounds.height / 2
        self.userImg.layer.borderWidth = 3
        self.userImg.layer.borderColor = UIColor.redButton.cgColor
        self.userImg.layer.masksToBounds = true
        
    }
    
    
    
    func hideShow(_ first: Bool, second: Bool, third: Bool, fourth: Bool){
        
        self.toAddressLabel1.isHidden = first
        self.toAddressLabel2.isHidden = second
        self.toAddressLabel3.isHidden = third
        self.toAddressLabel4.isHidden = fourth
        
        self.toCircleView1.isHidden = first
        self.toCircleView2.isHidden = second
        self.toCircleView3.isHidden = third
        self.toCircleView4.isHidden = fourth
        
    }
    
    
    func populate(at index: Int, with fromAddress: String, with toAddress: String) {
        
        self.fromCircleView.layer.cornerRadius = self.fromCircleView.bounds.height / 2
        self.fromAddressLabel.text = fromAddress
        
        
    }
    
    
}
