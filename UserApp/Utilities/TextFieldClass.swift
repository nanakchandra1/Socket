//
//  TextField.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/27/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation

class TextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: IsIPad ? 20:10, bottom: 0, right: IsIPad ? 20:10);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}
