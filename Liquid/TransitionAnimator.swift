//
//  TransitionAnimator.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 20.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

public protocol LiquidTransitionProtocol: UIViewControllerAnimatedTransitioning {
    var progress: CGFloat { get set }
    var duration: CGFloat { get set }
    var percentAnimator: TransitionPercentAnimator { get }
    var isPresenting: Bool { get }
    var isEnabled: Bool { get }
    
    func completeInteractive(complete: Bool?, animated: Bool)
    func canAnimate(from: UIViewController, to: UIViewController, direction: Liquid.Direction) -> Bool
}

internal protocol LiquidTransitionProtocolInternal: LiquidTransitionProtocol {
    var isPresenting: Bool { get set }
}

open class TransitionAnimator<Source: UIViewController, Destination: UIViewController>: MutipleTransitionAnimator {

    public init(from: Source.Type, to: Destination.Type, direction: Direction) {
        super.init(from: [from], to: [to], direction: direction)
    }

    open override func animateTransition(from vc1: UIViewController,
                                         to vc2: UIViewController,
                                         container: UIView,
                                         duration: TimeInterval) {
        guard let vc1 = vc1 as? Source, let vc2 = vc2 as? Destination else {
            assertionFailure("Inconsitent state of the transition animator")
            return
        }
        self.animateTransition(from: vc1, to: vc2, container: container, duration: duration)
    }

    open func animateTransition(from vc1: Source,
                                to vc2: Destination,
                                container: UIView,
                                duration: TimeInterval) {
        super.animateTransition(from: vc1, to: vc2, container: container, duration: duration)
    }

    open override func prepareAnimation(vc1: UIViewController, vc2: UIViewController, isPresenting: Bool) {
        super.prepareAnimation(vc1: vc1, vc2: vc2, isPresenting: isPresenting)
        guard let vc1 = vc1 as? Source, let vc2 = vc2 as? Destination else {
            assertionFailure("Inconsitent state of the transition animator")
            return
        }
        self.prepareAnimation(vc1: vc1, vc2: vc2, isPresenting: isPresenting)
    }

    open func prepareAnimation(vc1: Source, vc2: Destination, isPresenting: Bool) {
        
    }

    open override func completeInteractiveTransition(from vc1: UIViewController,
                                            to vc2: UIViewController,
                                            isPresenting: Bool,
                                            finish: Bool,
                                            animationDuration: Double) {
        guard let vc1 = vc1 as? Source, let vc2 = vc2 as? Destination else {
            assertionFailure("Inconsitent state of the transition animator")
            return
        }
        self.completeInteractiveTransition(from: vc1, to: vc2, isPresenting: isPresenting, finish: finish, animationDuration: animationDuration)
    }

    open func completeInteractiveTransition(from vc1: Source,
                                                     to vc2: Destination,
                                                     isPresenting: Bool,
                                                     finish: Bool,
                                                     animationDuration: Double) {

    }
}

open class MutipleTransitionAnimator: NSObject, LiquidTransitionProtocolInternal {
    
    public typealias Direction = Liquid.Direction
    public typealias CustomAnimation = (_ progress: CGFloat) -> Void
    private typealias ControllerCheckClosure = (_ vc1: UIViewController, _ vc2: UIViewController, _ direction: Direction) -> Bool
    
    public var progress: CGFloat {
        get { return percentAnimator.percentComplete }
        set { percentAnimator.update(newValue) }
    }
    
    public var isEnabled: Bool = true
    public var duration: CGFloat = 1.0
    public var timing: Timing {
        get { return percentAnimator.timing }
        set { percentAnimator.timing = newValue }
    }
    public let percentAnimator = TransitionPercentAnimator()
    public internal(set) var isPresenting: Bool = true

    fileprivate let direction: Direction
    fileprivate var customAnimations: [CustomAnimation] = []
    private var controllerCheck: ControllerCheckClosure!
    private let fromTypes: [AnyClass]
    private let toTypes: [AnyClass]
    
    
    public init(from: [AnyClass], to: [AnyClass], direction: Direction) {
        self.direction = direction
        fromTypes = from
        toTypes = to
        super.init()
        percentAnimator.delegate = self
    }
    /// You can animate non animatable properties
    public func addCustomAnimation(_ closure: @escaping CustomAnimation) {
        customAnimations.append(closure)
    }
    
    // -------------------------------
    //       MARK: - Overrides
    // -------------------------------
    /// Override to move information between controllers
    open func prepareAnimation(vc1: UIViewController, vc2: UIViewController, isPresenting: Bool) {
    }
    
    /// Perform here you animation
    open func animateTransition(from vc1: UIViewController,
                                to vc2: UIViewController,
                                container: UIView,
                                duration: TimeInterval) {
        print("LiquidTransition warning: override \(String(describing: self)).\(#function)")
        
        guard let toView = vc2.view else { return }
        
        toView.alpha = 0
        UIView.animate(withDuration: Double(duration), animations: {
            toView.alpha = 1
        }) { (_) in
            toView.alpha = 0
        }
    }
    
    open func completeInteractiveTransition(from vc1: UIViewController,
                                            to vc2: UIViewController,
                                            isPresenting: Bool,
                                            finish: Bool,
                                            animationDuration: Double) {
        // override to animate interactive view to destanation location
    }
    
    /// You can override to perform more complex logic
    open func canAnimate(from: UIViewController, to: UIViewController, direction animDirection: Direction) -> Bool {
        if fromTypes.isEmpty || toTypes.isEmpty {
            let className = String(describing: self)
            print("LiquidTransition warning: override \(className).\(#function)")
            return false
        }

        var from = from
        var to = to
        // check is backward
        if direction.contains(.both) && animDirection.contains(.dismiss) {
            swap(&from, &to)
        }

        if fromTypes.contains(where: {from.isKind(of: $0)}) &&
            toTypes.contains(where: {to.isKind(of: $0)}) {
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
        percentAnimator.context = transitionContext
        percentAnimator.totalDuration = transitionDuration(using: transitionContext)
        if let (vc1, vc2, _) = getControllers(context: transitionContext) {
            prepareAnimation(vc1: vc1, vc2: vc2, isPresenting: isPresenting)
        }
        
        if let toView = transitionContext.view(forKey: .to) {
            toView.transform = .identity
            toView.frame = transitionContext.containerView.bounds
            transitionContext.containerView.addSubview(toView)
            if !isPresenting {
                transitionContext.containerView.sendSubviewToBack(toView)
            }
        }
        
        if let (vc1, vc2, backward) = getControllers(context: transitionContext) {
            Liquid.shared.currentTransition = self
            percentAnimator.reset()
            percentAnimator.backward = backward
            
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
            
            animateTransition(from: vc1, to: vc2, container: transitionContext.containerView, duration: TimeInterval(duration))
            percentAnimator.update(0)
            percentAnimator.animate(finish: true, speed: 1)
        }
    }
    
    
    func callPrepareInteractive(finish: Bool, animDuration: Double) {
        if let (vc1, vc2, _) = getControllers(context: percentAnimator.context) {
            completeInteractiveTransition(from: vc1, to: vc2, isPresenting: isPresenting, finish: finish, animationDuration: animDuration)
        }
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
    
    
    // MARK: - Private
    
    private func runDefaultAnimation(context: UIViewControllerContextTransitioning) {
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
    
    private func getControllers(context: UIViewControllerContextTransitioning?) -> (vc1: UIViewController, vc2: UIViewController, backward: Bool)? {
        let to = context?.viewController(forKey: .to)
        let from = context?.viewController(forKey: .from)

        if let vc1 = to, let vc2 = from, !isPresenting && direction == .both {
            return (vc1, vc2, true)
        } else if let vc1 = from, let vc2 = to {
            return (vc1, vc2, false)
        }

        return nil
    }
    
    private func makeNonVisibleChanges(view: UIView) {
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


extension MutipleTransitionAnimator: TransitionPercentAnimatorDelegate {
    func transitionPercentChanged(_ percent: CGFloat) {
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
