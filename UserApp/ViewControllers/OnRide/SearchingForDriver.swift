//
//  SearchingForDriver.swift
//  UserApp
//
//  Created by Appinventiv on 03/01/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import UIKit
import PulsingHalo


class SearchingForDriver: UIViewController {

    @IBOutlet weak var animateView: UIView!
    @IBOutlet weak var searchingForLbl: UILabel!
    @IBOutlet weak var crossBtn: UIButton!
    
    
    var info = JSONDictionary()
    var ride_id = ""
    //var timer = Timer()

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.acceptRide), name:.aceeptRequestNotificationName, object: nil)
        self.crossBtn.layer.cornerRadius = 25
        self.crossBtn.layer.borderWidth = 1
        self.crossBtn.layer.borderColor = UIColor.white.cgColor

        self.ride_Cancelled()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchingForDriver.startAnimate), name:NSNotification.Name(rawValue: SATRTANIMATE), object: nil)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SATRTANIMATE), object: nil)
    }
    
    
    override func viewDidLayoutSubviews() {
        
        let halo = PulsingHaloLayer()
        super.viewDidLayoutSubviews()
        halo.position = self.view.center
        self.animateView.layer.addSublayer(halo)
        halo.backgroundColor = UIColor.tabBar.cgColor
        halo.haloLayerNumber = 5
        halo.radius = screenWidth / 3
        halo.animationDuration = 5
        halo.start()
        
    }
    
    

    
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: .aceeptRequestNotificationName, object: nil)

    }
    
    func startAnimate(){
        self.viewDidLayoutSubviews()

    }
    
    func acceptRide(){
        
        self.dismiss(animated: true, completion: nil)

    }
    
    
    func cancelRequest(){
        
        self.dismiss(animated: true, completion: nil)

        var params = JSONDictionary()
        params["ride_id"]        = self.ride_id
        
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
            
            self.dismiss(animated: true, completion: nil)
            
        }) {
            
        }
    }

    
    @IBAction func crossBtnTapped(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.cancelRequest()
        }))
        self.present(alert, animated: true, completion: nil)
    }

}
