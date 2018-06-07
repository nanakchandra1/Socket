//
//  UIViewExtension.swift
//  UserApp
//
//  Created by Appinventiv on 27/09/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore



// Mark: UIView extension to create traingle
extension UIView {
    
    func addSlope(withColor color: UIColor, ofWidth width: CGFloat = 50, ofHeight height: CGFloat = 50) {
        
        // Make path to draw traingle
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        
        // Add path to the mask
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath
        
        self.layer.mask = mask
        
        // Adding shape to view's layer
        let shape = CAShapeLayer()
        shape.frame = self.bounds
        shape.path = path.cgPath
        shape.fillColor = color.cgColor
        
        self.layer.insertSublayer(shape, at: 1)
    }
}
