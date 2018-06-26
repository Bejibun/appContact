//
//  Extensions.swift
//  appContact
//
//  Created by Frans Kurniawan on 6/25/18.
//  Copyright © 2018 Frans Kurniawan. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

// MARK: - UIViewController
extension UIViewController {
    
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
    
    func setTitleWithColor (title : String, color : UIColor) {
        self.title = title
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : color]
    }
    
    func showAlertMessage(vc: UIViewController, titleStr:String, messageStr:String) -> Void {
        let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction.init(title: "Ok", style: .cancel, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }

}

// MARK: - UIImageView
extension UIImageView {
    
    func setRounded() {
        self.layer.cornerRadius = self.frame.size.width/2
        self.layer.masksToBounds = true
    }
}

extension String {
    
    enum RegularExpressions: String {
        case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    }
    
    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }
    
    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }

}
