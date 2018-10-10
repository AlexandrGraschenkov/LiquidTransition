//
//  ThumbCaches.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 05.10.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

class ThumbCaches: NSObject {

    static let shared = ThumbCaches()
    
    fileprivate var cache: NSCache<NSString, UIImage>!
    fileprivate var queue: DispatchQueue!
    
    override init() {
        cache = NSCache<NSString, UIImage>()
        cache.countLimit = 20
        queue = DispatchQueue(label: "Draw Images BG", qos: DispatchQoS.background)
        super.init()
    }
    
    func getImage(name: String, size: CGSize, corners: CGFloat, completion: @escaping (UIImage)->()) -> Cancelable {
        let key = name + "| \(size.width)x\(size.height) \(corners)"
        if let img = cache.object(forKey: key as NSString) {
            completion(img)
            return {}
        }
        var isCanceled = false
        queue.async {
            let img = self.prepareImage(name: name, size: size, corners: corners)
            self.cache.setObject(img, forKey: key as NSString)
            DispatchQueue.main.async {
                if !isCanceled {
                    completion(img)
                }
            }
        }
        return { isCanceled = true }
    }
    
    fileprivate func prepareImage(name: String, size: CGSize, corners: CGFloat) -> UIImage {
        guard let img = UIImage(named: name) else {
            return UIImage()
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: size), cornerRadius: corners).addClip()
        
        let scale = max(size.width / img.size.width, size.height / img.size.height)
        let offset = CGPoint(x: (size.width - img.size.width * scale) / 2.0,
                             y: (size.height - img.size.height * scale) / 2.0)
        img.draw(in: CGRect(x: offset.x,
                            y: offset.y,
                            width: img.size.width * scale,
                            height: img.size.height * scale))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result ?? UIImage()
    }
}
