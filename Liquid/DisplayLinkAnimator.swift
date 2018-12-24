//
//  DisplayLinkAnimator.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 20.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

/// Timer on **DisplayLink**
public final class DisplayLinkAnimator: NSObject {
    public static func animate(duration: Double, closure: @escaping (CGFloat)->Void) -> Cancelable {
        let anim = DisplayLinkAnimator(duration: duration, closure: closure)
        anim.retainSelf = anim
        return anim.cancel
    }

    // MARK: - private
    private init(duration: Double, closure: @escaping (CGFloat)->Void) {
        self.duration = duration
        self.closure = closure
        super.init()

        link = CADisplayLink.init(target: self, selector: #selector(step(link:)))
        link.add(to: .current, forMode: .default)
    }

    private func cancel() {
        link.invalidate()
    }

    private var closure: (CGFloat)->Void
    private var link: CADisplayLink!
    private var duration: Double
    private var retainSelf: Any?
    private var startTimeStamp: CFTimeInterval = 0

    @objc private func step(link: CADisplayLink) {
        if startTimeStamp == 0 {
            startTimeStamp = link.timestamp - link.duration
        }
        var progress = (link.timestamp - startTimeStamp) / duration

        if progress >= 1 {
            link.invalidate()
            progress = 1
            defer {
                retainSelf = nil
            }
        }

        closure(CGFloat(progress))
    }
}
