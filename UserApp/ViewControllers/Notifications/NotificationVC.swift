//
//  NotificationVC.swift
//  UserApp
//
//  Created by Appinventiv on 14/12/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationVC: UIViewController {
    
    //MARK:- IBOutletes
    //MARK:- =================================================
    
    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var notificationTableView: UITableView!
    
    
    var notificationData = JSONArray()
    var notificationList = [NotificationModel]()
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        notificationCount = 0
        NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION), object: nil, userInfo: nil)
        self.notificationTableView.delegate = self
        self.notificationTableView.dataSource = self
        self.getNotifications()
        navigationView.setMenuButton()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- Private methods
    //MARK:- =================================================

    func getNotifications(){
        
        CommonClass.startLoader("")
        
        ServiceController.notificationApi(SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()
            
            if success{
                
                let result = json["result"].arrayValue
                
                for res in result{
                
                    let detail = NotificationModel(res)
                    
                    self.notificationList.append(detail)
                    
                }
                showNodata(self.notificationList, tableView: self.notificationTableView, msg: NO_NOTIFICATION, color: .white)

                self.notificationTableView.reloadData()

            }
        }) { (error) in
            
                CommonClass.stopLoader()
        }
    }
}


//MARK:- Tableview delegate and datasource methods
//MARK:- =================================================

extension NotificationVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.notificationList.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        
        let data = self.notificationList[indexPath.row]
        
        cell.populateData(data)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.showPopUp(self.notificationList[indexPath.row])
        
    }
    
    
    func showPopUp(_ info: NotificationModel){
        
        guard let viewController = (mfSideMenuContainerViewController.centerViewController as AnyObject).visibleViewController else{return}
        if viewController != nil {
            
            let popUp = getStoryboard(StoryboardName.User).instantiateViewController(withIdentifier: "NotificationPopUpVC") as! NotificationPopUpVC
            
            popUp.modalPresentationStyle = .overCurrentContext
            
            popUp.userInfo = info
            
            getMainQueue({
                
                viewController!.present(popUp, animated: true, completion: nil)
            })
        }
    }
    
}


//MARK:- Tableview cell classess
//MARK:- =================================================


class NotificationCell: UITableViewCell{
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var notiMsg: UILabel!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    func populateData(_ details: NotificationModel){
    
        self.dateLbl.text = details.date_created
        self.notiMsg.text = details.title
        
    }
}
