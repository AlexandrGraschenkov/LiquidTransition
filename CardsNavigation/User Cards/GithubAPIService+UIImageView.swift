//
//  GithubAPIService+UIImageView.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 04/10/2019.
//  Copyright © 2019 Alex Development. All rights reserved.
//

import UIKit


private var AssociatedObjectHandle: UInt8 = 0

extension UIImageView {
    fileprivate var cancelOper: Cancelable? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as? Cancelable
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

fileprivate class ImageCache {
    static let shared = ImageCache()
    
    // mark: - private
    private let cache: NSCache<NSString, UIImage>
    
    private init() {
        cache = NSCache<NSString, UIImage>()
        cache.countLimit = 50
    }
    
    func getCachedAvatar(url: URL) -> UIImage? {
        return cache.object(forKey: url.absoluteString as NSString)
    }
    
    func setCachedAvatar(img: UIImage, url: URL) {
        cache.setObject(img, forKey: url.absoluteString as NSString)
    }
}
