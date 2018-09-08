//
//  Utility.swift
//  FirebaseChatApp
//
//  Created by Brandon Hostetter on 9/8/18.
//  Copyright © 2018 Brandon Hostetter. All rights reserved.
//

import UIKit
import Firebase

let imageCache = NSCache<NSString, UIImage>()

class Util {
    var db: Firestore!

    static var shared: Util = {
        return Util()
    }()
    
    init() {
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
}

extension UIImageView {
    func loadImageUsingCacheWith(urlString: String) {
        self.image = nil
        
        // check cache for image
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        // no cached image, download it
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, urlResponse, error) in
                if error != nil || data == nil {
                    print(error ?? "Error")
                    return
                }
                
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async() {
                        self.image = image
                        imageCache.setObject(image, forKey: urlString as NSString)
                    }
                }
            }).resume()
        }
    }
}
