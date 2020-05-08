//
//  ImageCache.swift
//  LoremPicsum
//
//  Created by Ionel Lescai on 08/05/2020.
//  Copyright © 2020 Ionel Lescai. All rights reserved.
//

import UIKit

class ImageCache {
    private var cache = NSCache<NSString, UIImage>()

    init() {
        cache.countLimit = 100
    }

    subscript(id: String) -> UIImage? {
        get {
            cache.object(forKey: NSString(string: id))
        }
        
        set {
            if let image = newValue {
                cache.setObject(image, forKey: NSString(string: id))
            }
        }
    }
}
