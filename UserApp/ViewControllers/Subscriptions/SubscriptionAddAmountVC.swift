//
//  SubscriptionAddAmountVC.swift
//  UserApp
//
//  Created by Appinventiv on 01/12/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class SubscriptionAddAmountVC: UIViewController {

    //MARK:- IBOutlets
    //MARK:- =================================================

    @IBOutlet var navigationTitle: UILabel!
    @IBOutlet var availableAmtLbl: UILabel!
    @IBOutlet var amtLbl: UILabel!
    @IBOutlet var enterAmntTextLbl: UILabel!
    @IBOutlet var enterAmntTextField: UITextField!
    @IBOutlet weak var enterAmntView: UIView!
    @IBOutlet var addAmntBtn: UIButton!
    @IBOutlet var backBtn: UIButton!
    
    //MARK:- Properties
    //MARK:- =================================================

    var amountstr:String!
    
    
    //MARK:- View life cycle
    //MARK:- =================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.enterAmntView.layer.cornerRadius = 5
        self.enterAmntView.layer.borderColor = UIColor.lightGray.cgColor
        self.enterAmntView.layer.borderWidth = 1
        self.navigationTitle.text = C_ADD_AMOUNT.localized
        self.availableAmtLbl.text = AMOUNT_AVAILABLE.localized
        self.enterAmntTextLbl.text = S_ENTER_AMOUNT.localized
        self.enterAmntTextField.placeholder = C_ENTER_AMOUNT.localized
        self.addAmntBtn.setTitle(C_ADD_AMOUNT.localized, for: .normal)
        if CurrentUser.amount != nil{
            self.amtLbl.text = "$" + CurrentUser.amount!
        }else{
        self.amtLbl.text = "$0"
        }
        self.enterAmntTextField.attributedPlaceholder = NSAttributedString(string:"ENTER AMOUNT",
                                                               attributes:[NSForegroundColorAttributeName: UIColor.darkGray])
        // Do any additional setup after loading the view.
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
    
    @IBAction func addAmntTapped(_ sender: UIButton) {
        
        if self.enterAmntTextField.text != ""{
        let obj = getStoryboard(StoryboardName.Subscription).instantiateViewController(withIdentifier: "SubscriptionCardDetailVC") as! SubscriptionCardDetailVC
            obj.amount = self.enterAmntTextField.text
        self.navigationController?.pushViewController(obj, animated: true)
        }else{
            showToastWithMessage(PLEASE_ENTER_AMNT.localized)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
