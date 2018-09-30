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
    
    func completeInteractive(complete: Bool?, animated: Bool)
    func canAnimate(from: UIViewController, to: UIViewController, direction: LiquidTransition.Direction) -> Bool
}

fileprivate var _animators: [LiquidTransitionProtocol] = []

class TransitionAnimator<VC1, VC2>: NSObject, LiquidTransitionProtocol  {
    
    public typealias CustomAnimation = (_ progress: CGFloat)->()
    public typealias ControllerCheckClosure = (_ vc1: UIViewController, _ vc2: UIViewController, _ dir: Direction) -> Bool
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
    
    
    public init(from: VC1.Type, to: VC2.Type, direction: Direction) {
        self.direction = direction
        fromTypes = [from as! AnyClass]
        toTypes = [to as! AnyClass]
        super.init()
        interactive.delegate = self
    }
    
    public init(from: [AnyClass], to: [AnyClass], direction: Direction) {
        self.direction = direction
        fromTypes = from
        toTypes = to
        super.init()
        interactive.delegate = self
    }
    
    public init(direction: Direction) {
        self.direction = direction
        fromTypes = []
        toTypes = []
        super.init()
        controllerCheck = { (_, _, _) -> Bool in false }
        interactive.delegate = self
    }
    
    public func addCustomAnimation(_ closure: @escaping CustomAnimation) {
        customAnimations.append(closure)
    }
    
    // -------------------------------
    //       MARK: - Overrides
    // -------------------------------
    
    open func prepareAnimation(vc1: VC1, vc2: VC2, isPresenting: Bool) {
        // override to move information between controllers
    }
    
    open func animation(vc1: VC1, vc2: VC2, container: UIView, duration: Double) {
        // perform here you animation
        let className = String(describing: self)
        print("LiquidTransition warning: override \(className).animation(vc1: VC1, vc2: VC2, container: UIView, duration: Double) method")
        
        guard let toView = (vc2 as? UIViewController)?.view else { return }
        
        toView.alpha = 0
        UIView.animate(withDuration: Double(duration), animations: {
            toView.alpha = 1
        }) { (_) in
            toView.alpha = 0
        }
    }
    
    open func completeInteractiveTransition(vc1: VC1, vc2: VC2, isPresenting: Bool, finish: Bool, animationDuration: Double) {
        // override to animate interactive view to destanation location
    }
    
    //// You can override to perform more complex logic
    open func canAnimate(from: UIViewController, to: UIViewController, direction animDirection: Direction) -> Bool {
        if !direction.contains(animDirection) { return false }
        if fromTypes.count == 0 || toTypes.count == 0 {
            let className = String(describing: self)
            print("LiquidTransition warning: override \(className).canAnimate(from: UIViewController, to: UIViewController, direction: Direction) -> Bool method")
            return false
        }
        
        var fromType = type(of: from)
        var toType = type(of: to)
        
        // check is backward
        if direction.contains(.both) && animDirection.contains(.dismiss) {
            swap(&fromType, &toType)
        }
        
        if fromTypes.contains(where: {fromType === $0}) &&
            toTypes.contains(where: {toType === $0}) {
            return true
        }
        return false
    }
    
    
    // -------------------------------
    //    MARK: - Internal methods
    // -------------------------------
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(duration)
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        interactive.context = transitionContext
        interactive.totalDuration = transitionDuration(using: transitionContext)
        if let (vc1, vc2, _) = getControllers(context: transitionContext) {
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
        
        // we need to catch end of the animation, to propertly complete transition
        UIView.animate(withDuration: interactive.totalDuration, animations: {
            self.makeNonVisibleChanges(view: transitionContext.containerView)
        }) { (_) in
            if transitionContext.transitionWasCancelled {
                transitionContext.view(forKey: .to)?.removeFromSuperview()
            } else {
                transitionContext.view(forKey: .from)?.removeFromSuperview()
            }
        }
        
        
        if let (vc1, vc2, backward) = getControllers(context: transitionContext) {
            LiquidTransition.shared.currentTransition = self
            interactive.reset()
            interactive.backward = backward
            
            if backward {
                // fix wrong first frame
                // image flick between end backward animation and it's start
                if let snapshot = transitionContext.containerView.snapshotView(afterScreenUpdates: false) {
                    transitionContext.containerView.superview!.addSubview(snapshot)
                    _ = DisplayLinkAnimator.animate(duration: 0) { (_) in
                        snapshot.removeFromSuperview()
                    }
                }
            }
            
            animation(vc1: vc1, vc2: vc2, container: transitionContext.containerView, duration: Double(duration))
            interactive.update(0)
            interactive.animate(finish: true, speed: 1)
        }
    }
    
    
    func callPrepareInteractive(finish: Bool, animDuration: Double) {
        if let (vc1, vc2, _) = getControllers(context: interactive.context) {
            completeInteractiveTransition(vc1: vc1, vc2: vc2, isPresenting: isPresenting, finish: finish, animationDuration: animDuration)
        }
    }
    
    internal func completeInteractive(complete: Bool?, animated: Bool) {
        if (animated) {
            var finish = true
            var speed: CGFloat = 0
            if let complete = complete {
                finish = complete
                if finish == interactive.needFinish() {
                    speed = abs(interactive.lastSpeed)
                }
            } else {
                finish = interactive.needFinish()
                speed = abs(interactive.lastSpeed)
            }
            let animDuration = Double(interactive.getDurationToState(finish: finish, speed: speed))
            callPrepareInteractive(finish: finish, animDuration: animDuration)
            interactive.animate(finish: finish, speed: speed)
        } else {
            let finish = complete ?? interactive.needFinish()
            progress = finish ? 1 : 0
            interactive.backward = false
            if finish {
                interactive.update(1)
                callPrepareInteractive(finish: finish, animDuration: 0)
                interactive.finish()
            } else {
                interactive.update(0)
                callPrepareInteractive(finish: finish, animDuration: 0)
                interactive.cancel()
            }
        }
    }
    
    
    // MARK: - Fileprivate
    
    fileprivate var customAnimations: [CustomAnimation] = []
    fileprivate var controllerCheck: ControllerCheckClosure!
    fileprivate let fromTypes: [AnyClass]
    fileprivate let toTypes: [AnyClass]
    
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
            toView.alpha = 1
            fromView.removeFromSuperview()
            
            if context.transitionWasCancelled {
                context.cancelInteractiveTransition()
            } else {
                context.finishInteractiveTransition()
            }
        }
    }
    
    fileprivate func getControllers(context: UIViewControllerContextTransitioning?) -> (vc1: VC1, vc2: VC2, backward: Bool)? {
        let to = context?.viewController(forKey: .to)
        let from = context?.viewController(forKey: .from)
        
        if let vc1 = to as? VC1, let vc2 = from as? VC2,
           !isPresenting && direction == .both
        {
            return (vc1, vc2, true)
        } else if let vc1 = from as? VC1, let vc2 = to as? VC2
        {
            return (vc1, vc2, false)
        }
        
        return nil
    }
    
    fileprivate func makeNonVisibleChanges(view: UIView) {
        // change background color a little
        let color = view.backgroundColor ?? UIColor.clear
        var white: CGFloat = 0
        var alpha: CGFloat = 0
        color.getWhite(&white, alpha: &alpha)
        if white == 1 {
            white -= 0.001
        } else {
            white += 0.001
        }
        
        view.backgroundColor = UIColor.init(white: white, alpha: alpha)
    }
}


extension TransitionAnimator: TransitionPercentAnimatorDelegate {
    internal func transitionPercentChanged(_ percent: CGFloat) {
        let isBackwardAnimation = !isPresenting && direction == .both
        let animPercent = isBackwardAnimation ? 1-percent : percent
        for closure in customAnimations {
            closure(animPercent)
        }
    }
}
