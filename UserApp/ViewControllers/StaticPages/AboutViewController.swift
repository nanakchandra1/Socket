//
//  AboutViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/20/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit


enum StaticPagesNavigationBarButton{
    
    case back,burger
}

class AboutViewController: UIViewController {

    // MARK: IBOutlets
    //MARK:- =================================================
    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var navigationTitle: UILabel!
    
    
    var str = ""
    var action = ""
    var naviBtnState = StaticPagesNavigationBarButton.burger
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialSetup()
    }

    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: Private Methods
    //MARK:- =================================================

    func initialSetup() {

        if self.naviBtnState != StaticPagesNavigationBarButton.back{
            
                navigationView.setMenuButton()
                self.backBtn.isHidden = true
        }
        
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        self.navigationTitle.text = self.str
        
        self.showTermAndConditions()
        
    }
    
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    //MARK:- Functions
    //MARK:- =================================================
    
    func showTermAndConditions() {
        let params = ["action": self.action]
        
        CommonClass.startLoader("")

        ServiceController.staticPagesService(params, SuccessBlock: { (success,json) in
            
            if success{
            
                let html = json["result"]["pg_content"].string ?? ""
                let str1 = html.replacingOccurrences(of: "&lt;", with: "<")
                let str2 = str1.replacingOccurrences(of: "&gt;", with: ">")
                let str3 = str2.replacingOccurrences(of: "&amp;nbsp;", with: " ")
                let str4 = str3.replacingOccurrences(of: "&amp;rsquo;", with: "'")
                let str5 = str4.replacingOccurrences(of: "&amp;ldquo;", with: "\"")
                let str6 = str5.replacingOccurrences(of: "&amp;rdquo;", with: "\"")
                
                self.webView.loadHTMLString(str6, baseURL: nil)

            }

            CommonClass.stopLoader()

        }) { (error) in
            
                CommonClass.stopLoader()
        }
        
    }
}

    
