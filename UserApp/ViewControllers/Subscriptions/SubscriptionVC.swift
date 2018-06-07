//
//  SubscriptionVC.swift
//  UserApp
//
//  Created by Appinventiv on 01/12/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit
import SwiftyJSON

class SubscriptionVC: UIViewController {

    //MARK:- IBOutlets
    //MARK:- =================================================

    @IBOutlet var navigationTitle: UILabel!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet var availableamnttextLbl: UILabel!
    @IBOutlet var availableAmntLbl: UILabel!
    @IBOutlet var addAmntBtn: UIButton!
    @IBOutlet var couponCountLbl: UILabel!
    @IBOutlet var viewCouponsBtn: UIButton!
    @IBOutlet var lastTransactionLbl: UILabel!
    @IBOutlet var lastTransTableView: UITableView!
    
    //MARK:- properties
    //MARK:- =================================================

    var myTrasactions = [JSON]()
    
    
    //MARK:- View life cycle
    //MARK:- =================================================

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.lastTransTableView.delegate = self
        self.lastTransTableView.dataSource = self
        self.addAmntBtn.layer.borderWidth = 2
        self.addAmntBtn.layer.borderColor = UIColor(red: 194 / 255, green: 0 / 255, blue: 52 / 255, alpha: 1).cgColor
        self.addAmntBtn.layer.cornerRadius = 55 / 2
        self.navigationTitle.text = SUBSCRIPTION.localized
        self.availableamnttextLbl.text = AMOUNT_AVAILABLE.localized
        self.lastTransactionLbl.text = C_LAST_TRANSACTIONS.localized
        self.viewCouponsBtn.setTitle(VIEW_COUPONS.localized, for: .normal)
        self.addAmntBtn.setTitle(C_ADD_AMOUNT.localized, for: .normal)

        self.navigationView.setMenuButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if CurrentUser.amount != nil{
            
            self.availableAmntLbl.text = "$" + CurrentUser.amount!
            
        }else{
            
            self.availableAmntLbl.text = "$0"
        }
        
        self.getMyTransactions()

    }

    //MARK:- IBActions
    //MARK:- =================================================

    @IBAction func viewCouponsTapped(_ sender: UIButton) {
        
        let obj = getStoryboard(StoryboardName.Subscription).instantiateViewController(withIdentifier: "SubScriptionCouponsVC") as! SubScriptionCouponsVC
        self.navigationController?.pushViewController(obj, animated: true)
        
    }
    
    
    @IBAction func addAmountTapped(_ sender: UIButton) {
        
        let objVC = getStoryboard(StoryboardName.Subscription).instantiateViewController(withIdentifier: "SubscriptionAddAmountVC") as! SubscriptionAddAmountVC
        objVC.amountstr = self.availableAmntLbl.text
        self.navigationController?.pushViewController(objVC, animated: true)

    }
    
    
    //MARK:- Functions
    //MARK:- =================================================

    
    func getMyTransactions(){
    CommonClass.startLoader("")
        
        var params = JSONDictionary()
        
        params["action"] = "user" as AnyObject
        
        ServiceController.myTransactionApi(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()

            if success{
                
                let transactions = json["transactions"].arrayValue
                let amount = json["amnt"].stringValue
                self.myTrasactions = transactions
                self.availableAmntLbl.text = "$" + amount
                self.lastTransTableView.reloadData()
                showNodata(self.myTrasactions, tableView: self.lastTransTableView, msg: NO_TRANSACTION, color: .black)

            }
            
        }) { (error) in
            
            CommonClass.stopLoader()
        }
    }
}


//MARK:- TableView Delegate Datasource
//MARK:- =================================================


extension SubscriptionVC: UITableViewDelegate, UITableViewDataSource{

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myTrasactions.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionLastTransactionCell", for: indexPath) as! SubscriptionLastTransactionCell
        
        let data = self.myTrasactions[indexPath.row]
        let amnt = data["amount"].stringValue
        let description = data["description"].stringValue

        cell.amntLbl.text = "$" + amnt
        
        cell.codeLbl.text = description
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 65
    }

}



//MARK:- TableView Cell Class
//MARK:- =================================================


class SubscriptionLastTransactionCell: UITableViewCell {
    
    @IBOutlet weak var amntLbl: UILabel!
    @IBOutlet weak var codeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
