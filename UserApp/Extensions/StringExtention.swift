//
//  StringExtention.swift
//  DriverApp
//
//  Created by saurabh on 07/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation



extension String{
    
    var localized : String {
        
        return  localizedString(lang: "en")
    }
    
    
    func localizedString(lang:String) ->String {
        
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
        
    }
    
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
    
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.width
    }
    
    
    
     func convertTimeWithTimeZone(_ timeZome: String = TimeZoneString.UTC, formate: String) -> String{
        
        if self.isEmpty{
            
            return ""
            
        }else{
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.timeZone = TimeZone(abbreviation: timeZome)
            
            dateFormatter.dateFormat = DateFormate.utcDateWithTime
            
            let date1 = dateFormatter.date(from: self)
            
            dateFormatter.dateFormat = formate
            
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
            
            dateFormatter.locale = Locale.current
            
            let strDate = dateFormatter.string(from: date1!)
            
            return strDate
            
        }
        
    }
}
