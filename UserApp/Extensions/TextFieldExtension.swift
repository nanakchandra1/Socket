//
//  TextFieldExtension.swift
//  DriverApp
//
//  Created by Aakash Srivastav on 9/12/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation

extension UITextField {
    
    func addRightImage (withImageNamed imgName: String) {
        
        self.rightViewMode = .always
        
        guard let image = UIImage(named: imgName) else {
            
            print_debug("No image found with this name.")
            return
        }
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        
        let imageContainerView = UIView(frame: CGRect(x: 0, y: 0, width: imageWidth+8, height: self.frame.height))
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        
        imageContainerView.addSubview(imageView)
        imageContainerView.isUserInteractionEnabled = false
        
        imageView.center.y = imageContainerView.center.y
        
        self.rightView = imageContainerView
        
        self.textAlignment = .center
        
    }
    
}
