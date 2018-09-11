//
//  TransitionAnimator.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 20.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

protocol LiquidTransitionProtocol: UIViewControllerAnimatedTransitioning {
    var progress: CGFloat { get set }
    var duration: CGFloat { get set }
    var interactive: TransitionPercentAnimator { get }
    var isPresenting: Bool { get set }
    var key: String { get }
}

fileprivate var _animators: [LiquidTransitionProtocol] = []

class TransitionAnimator<VC1, VC2>: NSObject, LiquidTransitionProtocol  {
    
    public typealias CustomAnim = (_ progress: CGFloat)->()
    public typealias Anim = (_ vc1: VC1, _ vc2: VC2, _ container: UIView, _ duration: Double)->()
    typealias Direction = LiquidTransition.Direction
    
    
    public var progress: CGFloat {
        get { return interactive.percentComplete }
        set { interactive.update(newValue) }
    }
    
    public var duration: CGFloat = 1.0
    public let direction: Direction
    public lazy var timing: LiTiming = LiTiming.default
    public let interactive = TransitionPercentAnimator()
    public internal(set) var isPresenting: Bool = true
    
    internal let key: String
    fileprivate var tempVal: Int = 0
    
    
    public init(from: VC1.Type, to: VC2.Type, direction: Direction) {
        self.direction = direction
        key = LiquidTransition.generateKey(fromVC: from, toVC: to, direction: direction)
        super.init()
        interactive.delegate = self
    }
    
    public func addCustomAnimation(closure: @escaping CustomAnim) {
        customAnimations.append(closure)
    }
    
    public func setAnimation(closure: @escaping Anim) {
        anim = closure
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(duration)
    }
    
    open func prepareAnimation(vc1: VC1, vc2: VC2, isPresenting: Bool) {
        
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        interactive.context = transitionContext
        interactive.totalDuration = transitionDuration(using: transitionContext)
        if let vc1 = transitionContext.viewController(forKey: .to) as? VC1,
            let vc2 = transitionContext.viewController(forKey: .from) as? VC2,
            !isPresenting && direction == .both {
            prepareAnimation(vc1: vc1, vc2: vc2, isPresenting: isPresenting)
        } else if let vc1 = transitionContext.viewController(forKey: .from) as? VC1,
                  let vc2 = transitionContext.viewController(forKey: .to) as? VC2 {
            prepareAnimation(vc1: vc1, vc2: vc2, isPresenting: isPresenting)
        }
        
        if let toView = transitionContext.view(forKey: .to) {
            toView.transform = .identity
            toView.frame = transitionContext.containerView.bounds
            transitionContext.containerView.addSubview(toView)
            if !isPresenting && direction == .both {
                transitionContext.containerView.sendSubview(toBack: toView)
            }
        }
        
        tempVal = (tempVal+1) % 10
        let color = UIColor(white: 0.99 + CGFloat(tempVal) / 1000.0, alpha: 1)
        UIView.animate(withDuration: interactive.totalDuration, animations: {
            transitionContext.containerView.backgroundColor = color
        }) { (_) in
            if transitionContext.transitionWasCancelled {
                transitionContext.view(forKey: .to)?.removeFromSuperview()
            } else {
                transitionContext.view(forKey: .from)?.removeFromSuperview()
            }
        }
        
        if let anim = anim,
            let vc1 = transitionContext.viewController(forKey: .to) as? VC1,
            let vc2 = transitionContext.viewController(forKey: .from) as? VC2,
            !isPresenting && direction == .both
        {
            // reverse animation
            LiquidTransition.shared.currentTransition = self
            interactive.reset()
            interactive.backward = true
            
            // fix wrong first frame
            // image flick between end backward animation and it's start
            if let snapshot = transitionContext.containerView.snapshotView(afterScreenUpdates: false) {
                transitionContext.containerView.superview!.addSubview(snapshot)
                _ = DisplayLinkAnimator.animate(duration: 0) { (_) in
                    snapshot.removeFromSuperview()
                }
            }
            
            anim(vc1, vc2, transitionContext.containerView, Double(duration))
            interactive.update(0)
            transitionContext.containerView.setNeedsDisplay()
            interactive.animate(finish: true, speed: 1)
        } else if let anim = anim,
            let vc1 = transitionContext.viewController(forKey: .from) as? VC1,
            let vc2 = transitionContext.viewController(forKey: .to) as? VC2
        {
            LiquidTransition.shared.currentTransition = self
            interactive.reset()
            interactive.update(0)
            anim(vc1, vc2, transitionContext.containerView, Double(duration))
            interactive.update(0)
            interactive.animate(finish: true, speed: 1)
        } else {
            var errorMsg: String = ""
            if anim == nil { errorMsg = "use TransitionAnimator.setAnimation(closure:) method" }
            print("LiquidTransition error: ", errorMsg)
            interactive.reset()
            runDefaultAnimation(context: transitionContext)
            interactive.animate(finish: true, speed: 1)
        }
        
        
    }
    
    
    // MARK: - fileprivate
    
    fileprivate func runDefaultAnimation(context: UIViewControllerContextTransitioning) {
        guard let toView = context.view(forKey: .to),
            let fromView = context.view(forKey: .from) else {
            context.completeTransition(true)
            return
        }
        
        context.containerView.addSubview(toView)
        toView.frame = context.containerView.bounds
        toView.alpha = 0
        UIView.animate(withDuration: Double(duration), animations: {
            toView.alpha = 1.0
        }) { (_) in
            fromView.removeFromSuperview()
            
            if context.transitionWasCancelled {
                context.cancelInteractiveTransition()
            } else {
                context.finishInteractiveTransition()
            }
        }
    }
    
    fileprivate var customAnimations: [CustomAnim] = []
    fileprivate var anim: Anim?
}

extension TransitionAnimator: TransitionPercentAnimatorDelegate {
    func transitionPercentChanged(_ percent: CGFloat) {
        let isBackwardAnimation = !isPresenting && direction == .both
        let animPercent = isBackwardAnimation ? 1-percent : percent
        for closure in customAnimations {
            closure(animPercent)
        }
    }
}
