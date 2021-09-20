//
//  GITImageExtension.swift
//  GitHub-Users
//
//  Created by S, Aswin (623-Extern) on 17/09/21.
//

import Foundation
import UIKit

class CacheImage {
    
    static let shared = CacheImage()
    private var imageCached = NSCache<NSString, UIImage>()
    
    public func imageFromImageURL(urlString: String, imageView:UIImageView) {

        if let cachedImage = imageCached.object(forKey: urlString as NSString) {        // get cached image
            imageView.image = cachedImage
        } else {
            guard let url = URL(string: urlString) else { return }
            URLSession.shared.dataTask(with:url) { [weak self] (data, response, error) in
                guard let self = self else {return}
                if let response = data, let imageToCache = UIImage(data: response)   {
                    self.imageCached.setObject(imageToCache, forKey: urlString as NSString)     // set cached image
                    DispatchQueue.main.async {
                        imageView.image = imageToCache
                    }
                }
            }.resume()
        }
       }
}
