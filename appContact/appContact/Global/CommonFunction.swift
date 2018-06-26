//
//  CommonFunction.swift
//  appContact
//
//  Created by Frans Kurniawan on 6/24/18.
//  Copyright © 2018 Frans Kurniawan. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class CommonFunction {
    
    //Make Phone Call
    class func makeCall (phoneNumber: String) -> Void {
        guard let number = URL(string: "tel://" + phoneNumber) else { return }
        if CommonFunction.isValidPhone(phoneNumber){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(number, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(number)
            }
        }
    }
    
    // MARK: - Validations
    class func isValidName(_ checkString: String?) -> Bool {
        var checkString = checkString
        //Minimum length is 8 char (excluding +62 prefix)
        if (checkString?.count ?? 0) < 2 {
            return false
        }
    
        return true
    }
    
    class func isValidPhone(_ checkString: String?) -> Bool {
        var checkString = checkString
        if (checkString?.count ?? 0) >= 3 && (((checkString as NSString?)?.substring(to: 3)) == "+62") {
            checkString = (checkString as NSString?)?.substring(from: 3)
        }
        //Minimum length is 8 char (excluding +62 prefix)
        if (checkString?.count ?? 0) < 8 {
            return false
        }
        //Maximum length is 14 char (excluding +62 prefix)
        if (checkString?.count ?? 0) > 14 {
            return false
        }
        //Can only be filled with number (not decimal)
        if Int((checkString as NSString?)?.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted).location ?? 0) != NSNotFound {
            return false
        }
        //only phone start with number 8 is valid
        if !(((checkString as NSString?)?.substring(to: 1)) == "8") {
            return false
        }
        return true
    }
    
    //Verfiy Valid URL
    class func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url  = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    // MARK: - Convertions
    class func dateFromString(input:String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.date(from: input)!
    }
    
    class func stringFromDate(input:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.string(from:input)
    }
    
    //Hex Color
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // MARK: - Web Services
    //URL Request
    class func getURLRequest(urlString : String) -> URLRequest {
        
        var request = URLRequest(url: URL(string: urlString)!)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
}
