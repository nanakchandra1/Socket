//
//  NotificationPopUpVC.swift
//  DriverApp
//
//  Created by Appinventiv on 02/02/17.
//  Copyright © 2017 AppInventiv. All rights reserved.
//


import UIKit
import MFSideMenu
import SwiftyJSON

class NotificationPopUpVC: UIViewController {

    //MARK:- IBOutlets
    //MARK:- ====================================
    
    @IBOutlet weak var popUpview: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var noti_title_Lbl: UILabel!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var urlBtn: UIButton!
    
    
    //MARK:- Properties
    //MARK:- ====================================
    
    var userInfo: NotificationModel!

    
    //MARK:- View life cycle methods
    //MARK:- ====================================

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mfSideMenuContainerViewController.panMode = MFSideMenuPanModeNone

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mfSideMenuContainerViewController.panMode = MFSideMenuPanModeDefault

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        if let view = touches.first?.view {
            
            if view == self.bgView && !self.bgView.subviews.contains(view) {
                
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    //MARK:- Private Methods
    //MARK:- ====================================
    
    private func openBrowser(_ urlstr: String){
        
        let url = URL(string: urlstr) ?? URL(string: "http://www.google.com")
        
        UIApplication.shared.openURL(url!)
        
    }

    
    private func setupView(){
        
        tabbarSelect = 0
        
        
        self.noti_title_Lbl.text = self.userInfo.title
        
        
        self.msgLbl.text = self.userInfo.message
        
        
        if  !self.userInfo.urltext.isEmpty {
            
            if !self.userInfo.url.isEmpty{
                
                urlBtn.isHidden = false
                
                self.urlBtn.setTitle(self.userInfo.urltext, for: UIControlState())
                
            }else{
                
                self.urlBtn.isHidden = true
            }
            
        }else{
            
            self.urlBtn.isHidden = true
        }
        
        self.dateLbl.text = self.userInfo.date_created
        
        let imageUrlStr = "http://52.76.76.250/" + self.userInfo.image
        
        if let imageUrl = URL(string: imageUrlStr){
            
            if !self.userInfo.image.isEmpty{
                
                self.logoImg.isHidden = true
            }
            
            self.imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "splash_bg"))
        }

    }
    
    
    //MARK:- IBActions
    //MARK:- ====================================

    @IBAction func urlBtnTapped(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)

            self.openBrowser(self.userInfo.url)
    }
    
}
