//
//  Custom ImageView.swift
//  appContact
//
//  Created by Frans Kurniawan on 6/25/18.
//  Copyright © 2018 Frans Kurniawan. All rights reserved.
//

import Foundation
import UIKit

class CustomImageView: UIImageView {
    
    let imageCache = NSCache<NSString, AnyObject>()
    var imageURLString: String?
    
    //Image Caching
    func downloadImageFrom(urlString: String, imageMode: UIViewContentMode) {
        guard let url = URL(string: urlString) else { return }
        downloadImageFrom(url: url, imageMode: imageMode)
    }
    
    func downloadImageFrom(url: URL, imageMode: UIViewContentMode) {
        contentMode = imageMode
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) as? UIImage {
            self.image = cachedImage
            self.setRounded()
        } else {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    let imageToCache = UIImage(data: data)
                    self.imageCache.setObject(imageToCache!, forKey: url.absoluteString as NSString)
                    self.image = imageToCache
                    self.setRounded()
                }
                }.resume()
        }
    }
}
