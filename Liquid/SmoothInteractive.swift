//
//  SmoothInteractive.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 04.10.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

final class SmoothInteractive: NSObject {
    var isRunning: Bool { return self.cancelable != nil }
    private var cancelable: Cancelable?
    private var lastValue: CGFloat = 0
    private var lastProgress: CGFloat = 0
    
    func run(duration: TimeInterval, update: @escaping (CGFloat)->()) {
        cancelable = DisplayLinkAnimator.animate(duration: duration) {[weak self] (progress) in
            guard let `self` = self else { return }
            if progress == 1.0 { self.cancelable = nil }
            self.lastProgress = progress
            update(self.getValue())
        }
    }
    
    func cancel() {
        cancelable?()
        cancelable = nil
    }
    
    func update(val: CGFloat) {
        self.lastValue = val
    }
    
    func getValue() -> CGFloat {
        return lastValue * lastProgress
    }
}
