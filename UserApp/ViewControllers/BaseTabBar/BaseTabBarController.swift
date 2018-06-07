//
//  TabBarController.swift
//  DriverApp
//
//  Created by saurabh on 06/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import UIKit

var tabbarSelect = 0

class BaseTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        UITabBar.appearance().tintColor = UIColor.white
        self.view.backgroundColor = UIColor.black
        var frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.size.width/3, height: 55)
        let bgView1 = UIView(frame: frame)

        bgView1.tag = 11211
        
        bgView1.backgroundColor = UIColor(colorLiteralRed: 224/255.0, green: 0/255.0, blue: 83/255.0, alpha: 1)
        self.tabBar.addSubview(bgView1)
        self.tabBar.sendSubview(toBack: bgView1)
        
        frame = CGRect(x: self.view.bounds.size.width/3, y: 0.0, width: self.view.bounds.size.width/3, height: 55)
        let bgView2 = UIView(frame: frame)
        bgView2.tag = 11212
        bgView2.backgroundColor = UIColor(colorLiteralRed: 41/255.0, green: 41/255.0, blue: 41/255.0, alpha: 1)
        self.tabBar.addSubview(bgView2)
        self.tabBar.sendSubview(toBack: bgView2)
        
        frame = CGRect(x: 2*self.view.bounds.size.width/3, y: 0.0, width: self.view.bounds.size.width/3, height: 55)
        let bgView3 = UIView(frame: frame)
        bgView3.tag = 11213
        bgView3.backgroundColor = UIColor(colorLiteralRed: 41/255.0, green: 41/255.0, blue: 41/255.0, alpha: 1)
        self.tabBar.addSubview(bgView3)
        self.tabBar.sendSubview(toBack: bgView3)

        self.tabBar.itemPositioning = UITabBarItemPositioning.fill

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.selectedIndex = tabbarSelect
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
//        super.tabBar(tabBar, didSelectItem: item)
//        //self.selectedIndex = 1
//    }
//    override func transitionFromViewController(fromViewController: UIViewController, toViewController: UIViewController, duration: NSTimeInterval, options: UIViewAnimationOptions, animations: (() -> Void)?, completion: ((Bool) -> Void)?) {
//        
//        super.transitionFromViewController(fromViewController, toViewController: toViewController, duration: duration, options: options, animations: animations, completion: completion)
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
