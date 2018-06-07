//
//  GTToastAnimation.swift
//  Pods
//
//  Created by Grzegorz Tatarzyn on 05/10/2015.
//
//

import UIKit

public enum GTToastAnimation: Int {
    case alpha
    case scale
    case bottomSlideIn
    case leftSlideIn
    case rightSlideIn
    case leftInRightOut
    case rightInLeftOut
    
    public func animations(_ view: UIView) -> GTAnimations {
        let screenSize = UIScreen.main.bounds
        var showAnimations = {}
        var hideAnimations = {}
        var before = {}
        
        switch self{
        case .alpha:
            before = { view.alpha = 0 }
            showAnimations = { view.alpha = 1 }
            hideAnimations = before
        case .bottomSlideIn:
            before = { view.transform = CGAffineTransform(translationX: 0, y: screenSize.height - view.frame.origin.y)}
            showAnimations = { view.transform = CGAffineTransform.identity }
            hideAnimations = before
        case .leftSlideIn :
            before = { view.transform = CGAffineTransform(translationX: -view.frame.origin.x-view.frame.width, y: 0)}
            showAnimations = { view.transform = CGAffineTransform.identity }
            hideAnimations = before
        case .rightSlideIn :
            before = { view.transform = CGAffineTransform(translationX: screenSize.width - view.frame.origin.x, y: 0)}
            showAnimations = { view.transform = CGAffineTransform.identity }
            hideAnimations = before
        case .scale :
            before = { view.transform = CGAffineTransform(scaleX: 0.00000001, y: 0.00000001)}
            showAnimations = { view.transform = CGAffineTransform.identity }
            hideAnimations = before
        case .leftInRightOut:
            before = { view.transform = CGAffineTransform(translationX: -view.frame.origin.x-view.frame.width, y: 0)}
            showAnimations = { view.transform = CGAffineTransform.identity }
            hideAnimations = { view.transform = CGAffineTransform(translationX: screenSize.width - view.frame.origin.x, y: 0)}
        case .rightInLeftOut:
            before = { view.transform = CGAffineTransform(translationX: screenSize.width - view.frame.origin.x, y: 0)}
            showAnimations = { view.transform = CGAffineTransform.identity }
            hideAnimations = { view.transform = CGAffineTransform(translationX: -view.frame.origin.x-view.frame.width, y: 0)}
            break
        }
        
        return GTAnimations(before: before, show: showAnimations, hide: hideAnimations)
    }
}

public struct GTAnimations {
    public let before: () -> Void
    public let show: () -> Void
    public let hide: () -> Void
}
