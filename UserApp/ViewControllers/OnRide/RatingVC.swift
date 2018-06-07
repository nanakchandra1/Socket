//
//  RatingVC.swift
//  DriverApp
//
//  Created by Appinventiv on 17/11/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//


import UIKit
import SDWebImage
import MFSideMenu


class RatingVC: UIViewController {

    //MARK:- IBOutletes
    //MARK:- =================================================

    @IBOutlet weak var paymentLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var floatRatingView: FloatRatingView!
    @IBOutlet weak var ratingParamLbl: UILabel!
    @IBOutlet weak var sendRatingBtn: UIButton!
    @IBOutlet weak var firstBtn: UIButton!
    @IBOutlet weak var secondBtn: UIButton!
    @IBOutlet weak var thirdBtn: UIButton!
    @IBOutlet weak var fourthBtn: UIButton!
    @IBOutlet weak var fifthBtn: UIButton!
    @IBOutlet weak var sixthBtn: UIButton!
    @IBOutlet weak var parameterQuesLbl: UILabel!
    
    //MARK:- Properties
    //MARK:- =================================================

    
    var tripDetail = RideDetailModel()
    var ratingParams = [String]()
    var ride_id:String!
    
    //MARK:- View life cycle
    //MARK:- =================================================

    override func viewDidLoad() {
        
        super.viewDidLoad()
        printlnDebug(self.tripDetail)
        self.view.endEditing(true)
        self.floatRatingView.delegate = self
        self.userImgView.layer.cornerRadius = 35
        self.userImgView.layer.masksToBounds = true
        self.userImgView.layer.borderColor = UIColor.ratingParams.cgColor
        self.userImgView.layer.borderWidth = 3
        self.ratingParamLbl.text = ""
        self.parameterQuesLbl.text = ""
        self.setUpInitialView()
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
    

    //MARK:- IBActions
    //MARK:- =================================================

    
    @IBAction func firstBtnTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        setRatingParametersColor(sender)
        
    }
    
    @IBAction func secondBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        setRatingParametersColor(sender)
    }
    
    @IBAction func thirdBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        setRatingParametersColor(sender)
    }
    
    @IBAction func fourthBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        setRatingParametersColor(sender)
    }
    
    @IBAction func fifthbtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        setRatingParametersColor(sender)
    }
    
    @IBAction func sixthBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        setRatingParametersColor(sender)
    }
    
    @IBAction func sendRatingTapped(_ sender: UIButton) {
        
        var ratingParam = ""
        
        if self.floatRatingView.rating == 0{
            
            showToastWithMessage(ProfileStrings.rating)
            
        }else{
            
        var params = JSONDictionary()
            
        CommonClass.startLoader("")
            
        params["rating"] = self.floatRatingView.rating
            
        params["ride_id"] = CurrentUser.ride_id!
        
        if !self.ratingParams.isEmpty{
        
            for res in self.ratingParams{
                
                ratingParam = ratingParam + res + ","
                
            }
            
            params["rating_params"] = ratingParam
            
        }
        
        printlnDebug(params)
        
        ServiceController.rateApi(params, SuccessBlock: { (success,json) in
            
            if success{
                
            UserDefaults.removeFromUserDefaultForKey(NSUserDefaultsKeys.RIDE_ID)
            hideContentController(self)
            tabbarSelect = 0
            CommonClass.gotoLandingPage()
                
            }
        }) { (error) in
            
        }
    }
    }
    
    //MARK:- Methods
    //MARK:- =================================================

    func setUpInitialView(){
    
            let imageUrlStr = imgUrl + self.tripDetail.driver_image
            if let imageUrl = URL(string: imageUrlStr){
                self.userImgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_place_holder"))
        }
        
        self.dateLbl.text = self.tripDetail.date_created
        
        self.paymentLbl.text = "Last Ride Fare: $" + self.tripDetail.p_amount
}
    
    

    
    func setRatingParametersColor(_ sender: UIButton){
        var filtered = [String]()
        if sender.isSelected{
            sender.backgroundColor = .ratingParams
            self.ratingParams.append((sender.titleLabel?.text)!)
        }
        else{
            sender.backgroundColor = UIColor.white
            filtered = self.ratingParams.filter({$0 != sender.titleLabel!.text})
            self.ratingParams = filtered
        }
    }
}


//MARK:- FloatingRateView Delegate
//MARK:- ==================================================================


extension RatingVC: FloatRatingViewDelegate{

    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        if rating == 1{
            self.ratingParamLbl.text = RatingParameters.terrible
            self.parameterQuesLbl.text = RatingDescription.rate1
        }else if rating == 2{
            self.ratingParamLbl.text = RatingParameters.bad
            self.parameterQuesLbl.text = RatingDescription.rate2

        }else if rating == 3{
            self.ratingParamLbl.text = RatingParameters.ok
            self.parameterQuesLbl.text = RatingDescription.rate3

        }else if rating == 4{
            self.ratingParamLbl.text = RatingParameters.good
            self.parameterQuesLbl.text = RatingDescription.rate4

        }else if rating == 5{
            self.ratingParamLbl.text = RatingParameters.excellent
            self.parameterQuesLbl.text = RatingDescription.rate5
        }
    }
    
}
