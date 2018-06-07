//
//  PrebookingDetailVC.swift
//  UserApp
//
//  Created by Appinventiv on 23/11/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

protocol GetPrebookingDelegate {
    func getPreBookings()
}

class PrebookingDetailVC: UIViewController {
    
    //MARK:- IBOutlets
    //MARK:- =================================================
    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var navigationTitle: UILabel!
    
    @IBOutlet weak var bookingTimeBtn: UIButton!
    @IBOutlet weak var congratulationsLabel: UILabel!
    @IBOutlet weak var bookingIdLabel: UILabel!
    @IBOutlet weak var estimatedTimelLabel: UILabel!
    @IBOutlet weak var driverDetailView: UIView!
    @IBOutlet weak var driverImageView: UIImageView!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var cancelBookBtn: UIButton!
    @IBOutlet weak var driverMobileNumberLabel: UILabel!
    @IBOutlet weak var termsLbl: UILabel!
    @IBOutlet weak var firstTermsLbl: UILabel!
    @IBOutlet weak var secondTermsLbl: UILabel!
    
    @IBOutlet weak var verticalSpaceBetweenDriverNameLabelAndDriverDetailView: NSLayoutConstraint!
    
    //MARK:- Properties
    //MARK:- =================================================
    
    var rideDetail: PrebookingsModel!
    var ride_id = ""
    var delegate:GetPrebookingDelegate!
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.setMenuButton()
        self.initialSetup()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.driverImageView.layer.cornerRadius = self.driverImageView.frame.size.height/2
        
        if IsIPhone {
            self.verticalSpaceBetweenDriverNameLabelAndDriverDetailView.constant = 10 + self.driverImageView.frame.size.height/2
            self.driverDetailView.frame.size.height = self.verticalSpaceBetweenDriverNameLabelAndDriverDetailView.constant + 51
            
        } else if IsIPad{
            
            self.verticalSpaceBetweenDriverNameLabelAndDriverDetailView.constant = 15 + self.driverImageView.frame.size.height/2
            self.driverDetailView.frame.size.height = self.verticalSpaceBetweenDriverNameLabelAndDriverDetailView.constant + 91
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- Private Methods
    //MARK:- =================================================
    
    
    fileprivate func initialSetup() {
        
        self.bookingTimeBtn.layer.borderColor = UIColor.gray.cgColor
        self.bookingTimeBtn.layer.borderWidth = 1
        self.bookingTimeBtn.layer.cornerRadius = 3
        self.bookingTimeBtn.clipsToBounds = true
        self.cancelBookBtn.layer.cornerRadius = 3
        self.driverImageView.layer.borderColor = UIColor(red: 214/255, green: 0, blue: 84/255, alpha: 1).cgColor
        self.driverImageView.layer.borderWidth = 2
        self.driverImageView.clipsToBounds = true
        
        
        self.bookingIdLabel.text = "Your Booking ID: \(self.rideDetail.last4!)"
        
        self.bookingTimeBtn.setTitle(self.rideDetail.trip_time, for: UIControlState())
        
        
        self.setRideDetail()
        self.ride_Cancelled()
        
    }
    
    
    fileprivate func setRideDetail(){
        
        self.driverNameLabel.text = DRIVER_NOT_ALLOCATED.localized
        self.driverMobileNumberLabel.text = ""
    }
    
    //MARK: IBActions
    //MARK:- =================================================
    
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    @IBAction func cancelBookingBtnTapped(_ sender: UIButton) {
        
        self.cancelRequest()
   
    }
    
    
    func cancelRequest(){
        
        self.dismiss(animated: true, completion: nil)
        
        var params = JSONDictionary()
        params["ride_id"]        = self.rideDetail.rideId
        
        params["action"]        = "cancel"
        params["cancelled_by"]  = "user"
        params["reason"]        = "I want to cancel"
        
        if CommonClass.isConnectedToNetwork{
            CommonClass.startLoader("")
            
            SocketServicesController.cancelRequestRide(params)
            
        }
        
    }
    
    func ride_Cancelled(){
        
        SocketServicesController.rideCancelled({ (success, data) in
            
            self.delegate.getPreBookings()
            
            self.navigationController?.popViewController(animated: true)
            
        }) {
            
        }
    }

    
}
