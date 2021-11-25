//
//  PercentAnimator.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 22.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

protocol PercentAnimatorDelegate: AnyObject {
    func transitionPercentChanged(_ percent: CGFloat)
    func transitionCompleted(context: UIViewControllerContextTransitioning)
}

public class InvertableInteractiveTransition: UIPercentDrivenInteractiveTransition {
    var backward = false
    private(set) var percent: CGFloat = 0
    
    override public var percentComplete: CGFloat {
        get { return backward ? 1.0-super.percentComplete : super.percentComplete }
    }
    override public func update(_ percentComplete: CGFloat) {
        percent = percentComplete
        var val = backward ? 1.0-percent : percent
        val = min(val, 1)
        super.update(val)
    }
}

public class PercentAnimator: InvertableInteractiveTransition {
    
    fileprivate var cancelAnimation: Cancelable?
    fileprivate(set) var lastSpeed: CGFloat = 0
    fileprivate(set) var lastUpdateTime: TimeInterval = 0
    weak var context: UIViewControllerContextTransitioning?
    var totalDuration: Double = 0
    public var maxDurationFactor: Double = 2.0
    lazy var timing: Timing = Timing.default
    var isCanceled: Bool = false
    
    public var enableSmoothInteractive: Bool = false
    fileprivate lazy var smoothInteractive = SmoothInteractive()
    
    /// Max completion speed after interactive transition calls complete
    public var maxCompleteionSpeed: CGFloat = 1.0
    /// Min completion speed after interactive transition calls complete
    public var minCompleteionSpeed: CGFloat = 1.0
    
    weak var delegate: PercentAnimatorDelegate?
    
    func getDurationToState(finish: Bool, speed: CGFloat = 0) -> CGFloat {
        let fromPercent = percent
        let toPercent: CGFloat = finish ? 1.0 : 0.0
        var speedUp: CGFloat = 1.0
        if speed > 0 {
            speedUp = speed
        }
        var animDuration = duration * abs(toPercent - fromPercent) / speedUp
        // duration must be not too long
        animDuration =  min(duration * CGFloat(maxDurationFactor), animDuration)
        return animDuration
    }
    
    func animate(finish: Bool, speed: CGFloat = 0) {
        cancelAnimation?()
        
        let fromPercent = percent
        let toPercent: CGFloat = finish ? 1.0 : 0.0
        let animDuration = getDurationToState(finish: finish, speed:  speed)
        
        cancelAnimation = DisplayLinkAnimator.animate(duration: Double(animDuration), closure: { (percent) in
            var percentMaped = self.timing.getValue(x: percent)
            percentMaped = (toPercent - fromPercent) * percentMaped + fromPercent
            
            if percent == 1 && self.backward && finish {
                // finished backward animation
                // we need move to last step of animation to finish it
                super.update(0)
            } else {
                super.update(percentMaped)
            }
            self.delegate?.transitionPercentChanged(percentMaped)
            
            if (percent == 1) {
                if finish {
                    self.finish()
                } else {
                    self.backward = false
                    super.update(0)
                    self.cancel()
                }
                if let context = self.context {
                    context.completeTransition(finish)
                    self.delegate?.transitionCompleted(context: context)
                }
            }
        })
    }
    
    func pauseAnimation() {
        cancelAnimation?()
        cancelAnimation = nil
    }
    
    override public func update(_ percentComplete: CGFloat) {
        let isAnimated = (cancelAnimation != nil)
        cancelAnimation?()
        cancelAnimation = nil
        
        let isSmoothInteractive = performSmoothInteractive(percent: percentComplete, canInitalize: isAnimated)
        if isSmoothInteractive {
            // animation control take SmoothInteractive class
        } else {
            internalUpdate(percentComplete)
        }
    }
    
    func needFinish() -> Bool {
        if lastSpeed == 0 {
            return percent > 0.4
        } else {
            return lastSpeed > 0
        }
    }
    
    
    // MARK: - private
    
    fileprivate func internalUpdate(_ percentComplete: CGFloat) {
        updateSpeedWith(percentComplete: percentComplete)
        super.update(percentComplete)
        delegate?.transitionPercentChanged(percent)
    }
    
    fileprivate func performSmoothInteractive(percent percentComplete: CGFloat, canInitalize: Bool) -> Bool {
        if !enableSmoothInteractive { return false }
        
        if canInitalize && percentComplete > 0.03 {
            smoothInteractive.run(duration: totalDuration * Double(percentComplete)) {[weak self] (val) in
                self?.internalUpdate(val)
            }
        }
        
        if smoothInteractive.isRunning {
            smoothInteractive.update(val: percentComplete)
            return true
        }
        
        return false
    }
    
    fileprivate func updateSpeedWith(percentComplete: CGFloat) {
        let currTime = CACurrentMediaTime()
        if (percentComplete - self.percentComplete) == 0 {
            return // nothing to update
        }
        if lastUpdateTime == 0 {
            if (percentComplete - self.percentComplete) > 0 {
                lastSpeed = 1.0 / duration
            } else {
                lastSpeed = -1.0 / duration
            }
        } else {
            lastSpeed = (percentComplete - self.percentComplete) / CGFloat(currTime - lastUpdateTime)
        }
        if abs(lastSpeed) > maxCompleteionSpeed {
            lastSpeed = maxCompleteionSpeed * (lastSpeed > 0 ? 1 : -1)
        }
        if abs(lastSpeed) < minCompleteionSpeed {
            lastSpeed = minCompleteionSpeed * (lastSpeed > 0 ? 1 : -1)
        }
        lastUpdateTime = currTime
    }
    
    internal func reset() {
        lastSpeed = 0
        lastUpdateTime = 0
        backward = false
    }
}
