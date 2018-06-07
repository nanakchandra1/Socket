//
//  PostQueryViewController.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/19/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

class PostQueryViewController: UIViewController {

    // IBOutlets
    //MARK:- =================================================
    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var navigationTitle: UILabel!

    @IBOutlet weak var postQueryBtn: UIButton!
    @IBOutlet weak var queryTextView: UITextView!
    @IBOutlet weak var writeQueryHereLbl: UILabel!
    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialSetup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
    // Private methods
    //MARK:- =================================================

    func initialSetup() {
        
        self.queryTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.queryTextView.layer.borderWidth = 1
        self.queryTextView.layer.cornerRadius = 2
        
        self.queryTextView.text = "Write here..."
        self.queryTextView.textColor = UIColor.darkGray
        self.queryTextView.autocapitalizationType = .sentences
        
        self.queryTextView.delegate = self
    }
    
    
    func postQueryApi() {
        
        guard CommonClass.isConnectedToNetwork else{
            
            showToastWithMessage(NO_INTERNET)
            return
        }
        
        CommonClass.startLoader("")
        
        let test = String(self.queryTextView.text.characters.filter { !"\n".characters.contains($0) })
        
        let params: JSONDictionary = ["action": "add" ,"title": test]
        
        ServiceController.postQueryService(params, SuccessBlock: { (success,json) in
            
            CommonClass.stopLoader()

            if success{
                
                self.navigationController?.popViewController(animated: true)

            }
            
        }) { (error) in
            
            CommonClass.stopLoader()
        }
        
    }
    
    // IBActions
    //MARK:- =================================================

    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func postQueryBtnTapped(_ sender: UIButton) {
        
        if (self.queryTextView.text != nil) && !(self.queryTextView.text!.isEmpty) && (self.queryTextView.text != "Write here...") {
            
            self.postQueryApi()
            
        } else {
            
            showToastWithMessage(LoginPageStrings.enter_query)
        }
        self.view.endEditing(true)
    }
}

// MARK: Text View Delegate life cycle methods
//MARK:- =================================================

extension PostQueryViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.darkGray {
            
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            
            textView.text = "Write here..."
            textView.textColor = UIColor.darkGray
        }
    }
}
