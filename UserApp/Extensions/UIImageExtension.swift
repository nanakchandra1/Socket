//
//  UIImageExtension.swift
//  UserApp
//
//  Created by Aakash Srivastav on 10/7/16.
//  Copyright © 2016 Appinventiv. All rights reserved.
//

import Foundation


// fix image if image rotate automatically

func fixOrientationforImage(_ image: UIImage) -> UIImage {
    
    if image.imageOrientation == UIImageOrientation.up {
        return image
    }
    var transform: CGAffineTransform = CGAffineTransform.identity
    switch image.imageOrientation {
        
    case .up,.downMirrored:
        transform = transform.translatedBy(x: image.size.width, y: image.size.height)
        transform = transform.rotated(by: CGFloat(Double.pi))
        
    case .left,.leftMirrored:
        transform = transform.translatedBy(x: image.size.width, y: 0)
        transform = transform.rotated(by: CGFloat(Double.pi))
        
    case .right,.rightMirrored:
        transform = transform.translatedBy(x: 0, y: image.size.height)
        transform = transform.rotated(by: CGFloat(-(Double.pi)))

    default:
        ""
    }
    switch image.imageOrientation {
    case .upMirrored,.downMirrored:
        transform = transform.translatedBy(x: image.size.width, y: 0)
        transform = transform.scaledBy(x: -1, y: 1)
    case .leftMirrored,.rightMirrored:
        transform = transform.translatedBy(x: image.size.height, y: 0)
        transform = transform.scaledBy(x: -1, y: 1)
    case .up,.down,.left,.right:
        ""
    }
    let ctx: CGContext = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue)!
    ctx.concatenate(transform)
    switch image.imageOrientation {
    case .left,.leftMirrored,.right,.rightMirrored:
        ctx.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
    default:
        ctx.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
    }
    let cgimg: CGImage = ctx.makeImage()!
    let img: UIImage = UIImage(cgImage: cgimg)
    return img
}
