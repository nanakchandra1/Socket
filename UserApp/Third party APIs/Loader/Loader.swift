////
////  Loader.swift
////  iHearU
////
////  Created by Appinventiv on 20/07/16.
////  Copyright © 2016 Appinventiv. All rights reserved.
////

import UIKit


class Loader {

    //StartLoader
    class func showLoader(_ withMessage : String = "") {
        DispatchQueue.main.async(execute: {
            loadingMessage = withMessage
            ActivityLoader.start()
        })
    }
    
    class func hideLoader() {
        DispatchQueue.main.async(execute: {
            ActivityLoader.stop()
        })
    }
    
}

var loadingMessage = ""
let ActivityLoader = _Loader(frame: CGRect.zero)

class _Loader : UIView {
    
    fileprivate let spinnerBackView = UIView()
    fileprivate let spinner = JTMaterialSpinner()
    
    var isLoading = false
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        self.isUserInteractionEnabled = true
        
        let messageLabel = UILabel(frame: CGRect(x: 3,y: self.bounds.origin.y + 85,width: 194,height: 30))
        messageLabel.textAlignment = NSTextAlignment.center
        messageLabel.text = loadingMessage
        messageLabel.tag = 857364
        let spinnerBackViewWidth : CGFloat = loadingMessage == "" ? 100 : 194
        let spinnerBackViewHeight : CGFloat = loadingMessage == "" ? 100 : 130
        
        self.spinner.frame = CGRect(x: self.bounds.origin.x + (loadingMessage == "" ? 20 : 67), y: self.bounds.origin.y + 20, width: 60, height: 60)
        self.spinner.circleLayer.lineWidth = 2.0
        self.spinner.circleLayer.strokeColor = UIColor.redButton.cgColor
        
        self.spinnerBackView.frame = CGRect(x: (screenWidth - spinnerBackViewWidth)/2, y: (screenHeight - spinnerBackViewHeight)/2, width: spinnerBackViewWidth, height: spinnerBackViewHeight)
        self.spinnerBackView.backgroundColor = UIColor.clear// (red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.spinnerBackView.layer.cornerRadius = 20.0
        self.spinnerBackView.clipsToBounds = true
        self.spinnerBackView.addSubview(self.spinner)
        self.spinnerBackView.addSubview(messageLabel)
        self.addSubview(self.spinnerBackView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not Loading Properly")
    }
    
    func start() {
        if self.isLoading {
            return
        }
        if let message = self.viewWithTag(857364) as? UILabel {
            message.text = loadingMessage
        }
        sharedAppdelegate.window?.addSubview(self)
        self.spinner.beginRefreshing()
        self.isLoading = true
    }
    
    func stop() {
        self.spinner.endRefreshing()
        self.removeFromSuperview()
        self.isLoading = false
    }
}
