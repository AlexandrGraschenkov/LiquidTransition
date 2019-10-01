//
//  DisplayLinkAnimator.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 20.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

/// Timer on **DisplayLink**
public class DisplayLinkAnimator: NSObject {
    public static func animate(duration: Double, closure: @escaping (CGFloat)->()) -> Cancelable {
        let anim = DisplayLinkAnimator(duration: duration, closure: closure)
        anim.retainSelf = anim
        return anim.cancel
    }
    
    // MARK: - private
    fileprivate init(duration: Double, closure: @escaping (CGFloat)->()) {
        self.duration = duration
        self.closure = closure
        super.init()
        
        link = CADisplayLink.init(target: self, selector: #selector(step(link:)))
        link.add(to: .current, forMode: .default)
    }
    
    fileprivate func cancel() {
        link.invalidate()
    }
    
    fileprivate var closure: (CGFloat)->()
    fileprivate var link: CADisplayLink!
    fileprivate var duration: Double
    fileprivate var retainSelf: Any?
    fileprivate var startTimeStamp: CFTimeInterval = 0
    
    @objc fileprivate func step(link: CADisplayLink) {
        if startTimeStamp == 0 {
            startTimeStamp = link.timestamp - link.duration
        }
        var progress = (link.timestamp - startTimeStamp) / duration
        
        if progress >= 1 {
            link.invalidate()
            progress = 1
            retainSelf = nil
        }
        
        closure(CGFloat(progress))
    }
}
