//
//  Animator.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 20.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

public protocol LiquidTransitionProtocol: UIViewControllerAnimatedTransitioning {
    var progress: CGFloat { get set }
    var duration: CGFloat { get set }
    var percentAnimator: PercentAnimator { get }
    var isPresenting: Bool { get }
    var isEnabled: Bool { get }
    
    func completeInteractive(complete: Bool?, animated: Bool)
    func canAnimate(src: UIViewController, dst: UIViewController, direction: Liquid.Direction) -> Bool
}

internal protocol LiquidTransitionProtocolInternal: LiquidTransitionProtocol {
    var isPresenting: Bool { get set }
}

open class Animator<Source: UIViewController, Destination: UIViewController>: NSObject, LiquidTransitionProtocolInternal  {
    
    public typealias CustomAnimation = (_ progress: CGFloat)->()
    public typealias Direction = Liquid.Direction
    
    
    public var progress: CGFloat {
        get { return percentAnimator.percentComplete }
        set { percentAnimator.update(newValue) }
    }
    
    public var isEnabled: Bool = true
    open var duration: CGFloat = 1.0
    open var direction: Direction = .both
    public var timing: Timing {
        get { return percentAnimator.timing }
        set { percentAnimator.timing = newValue }
    }
    public let percentAnimator = PercentAnimator()
    public internal(set) var isPresenting: Bool = true
    public var context: UIViewControllerContextTransitioning? {
        return percentAnimator.context
    }
    
    /// Use this initialization to allow multiple controllers
    public init(from: [AnyClass], to: [AnyClass], direction: Direction = .both) {
        self.direction = direction
        fromTypes = from
        toTypes = to
        super.init()
        setup()
    }
    
    
    public init(direction: Direction = .both) {
        self.direction = direction
        fromTypes = [Source.self]
        toTypes = [Destination.self]
        super.init()
        setup()
    }
    
    /// You can animate non animatable properties
    public func addCustomAnimation(_ closure: @escaping CustomAnimation) {
        customAnimations.append(closure)
    }
    
    // -------------------------------
    //       MARK: - Overrides
    // -------------------------------
    /// Override to move information between controllers
    open func prepare(src: Source, dst: Destination, isPresenting: Bool) {
    }
    
    /// Perform here you animation
    open func animation(src: Source, dst: Destination, container: UIView, duration: Double) {
        flagOverrideAnim = false
    }
    
    open func animationDismiss(src: Source, dst: Destination, container: UIView, duration: Double) {
        flagOverrideAnim = false
    }
    
    open func completeInteractiveTransition(src: Source, dst: Destination, isPresenting: Bool, finish: Bool, animationDuration: Double) {
        // override to animate interactive view to destanation location
    }
    
    /// You can override to perform more complex logic
    open func canAnimate(src: UIViewController, dst: UIViewController, direction animDirection: Direction) -> Bool {
        if !direction.contains(animDirection) { return false }
        if fromTypes.count == 0 || toTypes.count == 0 {
            let className = String(describing: self)
            print("LiquidTransition warning: override \(className).canAnimate(from: UIViewController, to: UIViewController, direction: Direction) -> Bool method")
            return false
        }
//        print("From")
//        for f in fromTypes {
//            print(String(describing: f))
//        }
//        print("To")
//        for f in toTypes {
//            print(String(describing: f))
//        }
        
        var from = src
        var to = dst
        // check is backward
        if animDirection.contains(.dismiss) {
            swap(&from, &to)
        }
        
        if fromTypes.contains(where: {from.isKind(of: $0)}) &&
            toTypes.contains(where: {to.isKind(of: $0)}) {
            return true
        }
        return false
    }
    
    
    // -------------------------------
    //    MARK: - Public methods
    // -------------------------------
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(duration)
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        percentAnimator.context = transitionContext
        percentAnimator.totalDuration = transitionDuration(using: transitionContext)
        guard let (src, dst, isPresenting) = getControllers(context: transitionContext) else {
            assert(false, "Can't resolve source and destination controller")
            return
        }
        prepare(src: src, dst: dst, isPresenting: isPresenting)
        
        if let toView = transitionContext.view(forKey: .to) {
            toView.transform = .identity
            toView.frame = transitionContext.containerView.bounds
            transitionContext.containerView.addSubview(toView)
            if !isPresenting {
                transitionContext.containerView.sendSubviewToBack(toView)
            }
        }
        
        
        Liquid.shared.currentTransition = self
        percentAnimator.reset()
        
        flagOverrideAnim = true
        if isPresenting {
            animation(src: src, dst: dst, container: transitionContext.containerView, duration: Double(duration))
        } else {
            animationDismiss(src: src, dst: dst, container: transitionContext.containerView, duration: Double(duration))
        }
        
        if flagOverrideAnim == false {
            // without snapshot first frame animation is fliching
            showSnapshotOnStartAnimation(transitionContext: transitionContext)
            
            // try to use animation in backward direction
            percentAnimator.backward = true
            flagOverrideAnim = true
            if isPresenting {
                animationDismiss(src: src, dst: dst, container: transitionContext.containerView, duration: Double(duration))
            } else {
                animation(src: src, dst: dst, container: transitionContext.containerView, duration: Double(duration))
            }
            assert(flagOverrideAnim == true, "You must override animation(src:dst:container:duration) or animationDismiss(src:dst:container:duration)")
        }
        flagOverrideAnim = nil
        
        percentAnimator.update(0)
        percentAnimator.animate(finish: true, speed: 1)
    }
    
    public func completeInteractive(complete: Bool?, animated: Bool) {
        if (animated) {
            var finish = true
            var speed: CGFloat = 0
            if let complete = complete {
                finish = complete
                if finish == percentAnimator.needFinish() {
                    speed = abs(percentAnimator.lastSpeed)
                }
            } else {
                finish = percentAnimator.needFinish()
                speed = abs(percentAnimator.lastSpeed)
            }
            let animDuration = Double(percentAnimator.getDurationToState(finish: finish, speed: speed))
            callPrepareInteractive(finish: finish, animDuration: animDuration)
            percentAnimator.animate(finish: finish, speed: speed)
        } else {
            let finish = complete ?? percentAnimator.needFinish()
            progress = finish ? 1 : 0
            percentAnimator.backward = false
            if finish {
                percentAnimator.update(1)
                callPrepareInteractive(finish: finish, animDuration: 0)
                percentAnimator.finish()
            } else {
                percentAnimator.update(0)
                callPrepareInteractive(finish: finish, animDuration: 0)
                percentAnimator.cancel()
            }
        }
    }
    
    // -------------------------------
    //    MARK: - Internal methods
    // -------------------------------
    
    func callPrepareInteractive(finish: Bool, animDuration: Double) {
        if let (src, dst, _) = getControllers(context: percentAnimator.context) {
            completeInteractiveTransition(src: src, dst: dst, isPresenting: isPresenting, finish: finish, animationDuration: animDuration)
        }
    }
    
    
    // fix wrong first frame
    // image flick between end backward animation and it's start
    func showSnapshotOnStartAnimation(transitionContext: UIViewControllerContextTransitioning) {
        if let snapshot = transitionContext.containerView.snapshotView(afterScreenUpdates: false) {
            transitionContext.containerView.superview!.addSubview(snapshot)
            _ = DisplayLinkAnimator.animate(duration: 0) { (_) in
                snapshot.removeFromSuperview()
            }
        }
    }
    
    // -------------------------------
    //    MARK: - Fileprivate methods
    // -------------------------------
    
    fileprivate var customAnimations: [CustomAnimation] = []
    fileprivate let fromTypes: [AnyClass]
    fileprivate let toTypes: [AnyClass]
    fileprivate var flagOverrideAnim: Bool?
    
    fileprivate func setup() {
        percentAnimator.delegate = self
        
        if direction.contains(.dismiss) && !direction.contains(.present) {
            isPresenting = false
        }
    }
    
    fileprivate func getControllers(context: UIViewControllerContextTransitioning?) -> (src: Source, dst: Destination, isPresenting: Bool)? {
        let to = context?.viewController(forKey: .to)
        let from = context?.viewController(forKey: .from)
        
        if let src = from as? Source, let dst = to as? Destination, isPresenting
        {
            return (src, dst, true)
        } else if let src = to as? Source, let dst = from as? Destination, !isPresenting
        {
            return (src, dst, false)
        }
        
        return nil
    }
}


extension Animator: PercentAnimatorDelegate {
    internal func transitionPercentChanged(_ percent: CGFloat) {
        let isBackwardAnimation = !isPresenting && direction == .both
        let animPercent = isBackwardAnimation ? 1-percent : percent
        for closure in customAnimations {
            closure(animPercent)
        }
    }
    
    func transitionCompleted(context: UIViewControllerContextTransitioning) {
        if context.transitionWasCancelled {
            context.view(forKey: .to)?.removeFromSuperview()
        } else {
            context.view(forKey: .from)?.removeFromSuperview()
        }
    }
}
