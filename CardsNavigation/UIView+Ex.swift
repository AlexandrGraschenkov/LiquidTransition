//
//  UIView+Ex.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 08.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

extension UIView {

    func snapshotImage(scale: CGFloat, completion: @escaping (UIImage)->()) {
        let selfSize = bounds.size
        
//        DispatchQueue.global(qos: .background).async {
        
            let size = CGSize(width: floor(selfSize.width * scale),
                              height: floor(selfSize.height * scale))
            UIGraphicsBeginImageContextWithOptions(size, true, 0)
            var img: UIImage? = nil
            
            if let ctx = UIGraphicsGetCurrentContext() {
                ctx.scaleBy(x: scale, y: scale)
                self.layer.render(in: ctx)
                img = UIGraphicsGetImageFromCurrentImageContext()
            }
            UIGraphicsEndImageContext();
            
            DispatchQueue.main.async {
                completion(img ?? UIImage())
            }
//        }
    }
}
