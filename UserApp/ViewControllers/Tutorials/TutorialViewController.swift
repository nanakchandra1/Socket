//
//  TutorialViewController.swift
//  UserApp
//
//  Created by Aakash Srivastav on 10/6/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    // MARK: IBOutlets
    //MARK:- =================================================

    @IBOutlet weak var tutorialScrollView: UIScrollView!

    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var firstDotView: UIView!
    @IBOutlet weak var centerDotView: UIView!
    @IBOutlet weak var lastDotView: UIView!
    
    
    // MARK: Variables
    //MARK:- =================================================

    var loginMediaVC: LoginWithMediaVC!
    let pageControlDotView = UIView()

    
    //MARK:- View life cycle
    //MARK:- =================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tutorialScrollView.delegate = self
        
        let cornerRadius: CGFloat = IsIPad ? 5:3.5
        
        self.firstDotView.layer.cornerRadius = cornerRadius
        self.centerDotView.layer.cornerRadius = cornerRadius
        self.lastDotView.layer.cornerRadius = cornerRadius
        
        self.pageControlDotView.layer.cornerRadius = cornerRadius
        self.pageControlDotView.clipsToBounds = true
        
        self.dotView.addSubview(self.pageControlDotView)
        self.setDotViewColor(self.pageControlDotView)
        
        UIApplication.shared.setStatusBarHidden(true, with: .none)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.initialSetup()
    }

    // MARK: Private Methods
    //MARK:- =================================================

    func initialSetup() {
        
        self.tutorialScrollView.contentSize = CGSize(width: screenWidth*4, height: 1)
        
        let firstTutorialVC = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "FirstTutorialViewController") as! FirstTutorialViewController
        
        let secondTutorialVC = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "SecondTutorialViewController") as! SecondTutorialViewController
        
        let thirdTutorialVC = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "ThirdTutorialViewController") as! ThirdTutorialViewController
        
        self.loginMediaVC = getStoryboard(StoryboardName.Main).instantiateViewController(withIdentifier: "LoginWithMediaVC") as! LoginWithMediaVC
        
        self.addChildViewController(firstTutorialVC)
        self.tutorialScrollView.addSubview(firstTutorialVC.view)
        firstTutorialVC.willMove(toParentViewController: self)
        
        self.addChildViewController(secondTutorialVC)
        self.tutorialScrollView.addSubview(secondTutorialVC.view)
        secondTutorialVC.willMove(toParentViewController: self)
        
        self.addChildViewController(thirdTutorialVC)
        self.tutorialScrollView.addSubview(thirdTutorialVC.view)
        thirdTutorialVC.willMove(toParentViewController: self)
        
        self.addChildViewController(self.loginMediaVC)
        self.tutorialScrollView.addSubview(self.loginMediaVC.view)
        self.loginMediaVC.willMove(toParentViewController: self)
        
        firstTutorialVC.view.frame.origin = CGPoint.zero
        secondTutorialVC.view.frame.origin = CGPoint(x: screenWidth, y: 0)
        thirdTutorialVC.view.frame.origin = CGPoint(x: 2*screenWidth, y: 0)
        self.loginMediaVC.view.frame.origin = CGPoint(x: 3*screenWidth, y: 0)
        
        self.dotView.setNeedsLayout()
        self.dotView.layoutIfNeeded()
        self.pageControlDotView.frame = self.firstDotView.frame
    }
    
    func setDotViewColor(_ view: UIView) {
        
        self.firstDotView.backgroundColor = UIColor.darkGray
        self.centerDotView.backgroundColor = UIColor.darkGray
        self.lastDotView.backgroundColor = UIColor.darkGray
        
        view.backgroundColor = UIColor.white
    }
    
    func hidePageControlView() {
        
        self.firstDotView.isHidden = true
        self.centerDotView.isHidden = true
        self.lastDotView.isHidden = true
        self.pageControlDotView.isHidden = true
    }
}


//MARK:- ScrollView Delegate 
//MARK:- =================================================

extension TutorialViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let scrollOffset: CGFloat = scrollView.contentOffset.x
        
        if (scrollOffset >= 0) && (scrollOffset < screenWidth) {
            
            let distance = self.centerDotView.center.x - self.firstDotView.center.x
            self.pageControlDotView.center.x = self.firstDotView.center.x + distance*((scrollOffset.truncatingRemainder(dividingBy: screenWidth)) / screenWidth)
        
        } else if (scrollOffset >= screenWidth) && (scrollOffset < 2*screenWidth) {
            
            let distance = self.lastDotView.center.x - self.centerDotView.center.x
            self.pageControlDotView.center.x = self.centerDotView.center.x + distance*((scrollOffset.truncatingRemainder(dividingBy: screenWidth)) / screenWidth)
            
        } else if (scrollOffset > 2*screenWidth) && (scrollOffset < 3*screenWidth) {
            
            let alpha: CGFloat = 1 - ((scrollOffset.truncatingRemainder(dividingBy: screenWidth)) / screenWidth)
                        
            self.firstDotView.alpha = alpha
            self.centerDotView.alpha = alpha
            self.lastDotView.alpha = alpha
            self.pageControlDotView.alpha = alpha
            
        } else if scrollOffset == 3*screenWidth {
            
            scrollView.isScrollEnabled = false
            self.hidePageControlView()
            
            if !(self.navigationController?.topViewController?.isKind(of: LoginWithMediaVC.self))! {
                self.loginMediaVC.isPushed = true
                self.navigationController?.pushViewController(self.loginMediaVC, animated: false)
            }
        }
    }
}
