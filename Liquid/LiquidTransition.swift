//
//  LiquidTransition.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 22.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit


public class LiquidTransition: NSObject {

    public static var shared = LiquidTransition()
    
    public struct Direction: OptionSet {
        public let rawValue: UInt
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        public static let present = Direction(rawValue: 1 << 0)
        public static let dismiss = Direction(rawValue: 1 << 1)
        public static let both: Direction = [.present, .dismiss]
    }
    
    public func addTransitions(_ arr: [LiquidTransitionProtocol]) {
        let arrInternal = arr.compactMap({$0 as? LiquidTransitionProtocolInternal})
        transitions.append(contentsOf: arrInternal)
        if arrInternal.count != arr.count {
            print("Error: please inherit from Liquid.TransitionAnimator<VC1, VC2>")
        }
    }
    
    public func addTransition(_ transition: LiquidTransitionProtocol) {
        if let transition = transition as? LiquidTransitionProtocolInternal {
            transitions.append(transition)
        } else {
            print("Error: please inherit from Liquid.TransitionAnimator<VC1, VC2>")
        }
    }
    
    public func update(progress: CGFloat) {
        currentTransition?.progress = progress
    }
    
    public func finish(complete: Bool? = nil, animated: Bool = true) {
        guard let transition = currentTransition else { return }
        
        transition.completeInteractive(complete: complete, animated: animated)
    }
    
    public func transitionForPresent(from: UIViewController, to: UIViewController) -> LiquidTransitionProtocol? {
        let transition = transitions.first(where: {$0.canAnimate(from: from, to: to, direction: .present)})
        transition?.isPresenting = true
        return transition
    }
    
    public func transitionForDismiss(from: UIViewController, to: UIViewController) -> LiquidTransitionProtocol? {
        let transition = transitions.first(where: {$0.canAnimate(from: from, to: to, direction: .dismiss)})
        transition?.isPresenting = false
        return transition
    }
    
    // MARK: - private
    fileprivate override init() {
        super.init()
        
        let sel1 = #selector(UIViewController.viewDidLoad)
        let liSel1 = #selector(UIViewController.li_viewDidLoad)
        LiquidRuntimeHelper.addOrReplaceMethod(class: UIViewController.self, original: sel1, swizzled: liSel1)
    }
    
    internal var currentTransition: LiquidTransitionProtocol?
    fileprivate var transitions: [LiquidTransitionProtocolInternal] = []
}

extension UIViewController {
    @objc func li_viewDidLoad() {
        if self.transitioningDelegate == nil {
            self.transitioningDelegate = LiquidTransition.shared
        }
        if let nav = self as? UINavigationController, nav.delegate == nil {
            nav.delegate = LiquidTransition.shared
        }
        self.li_viewDidLoad()
    }
}

extension LiquidTransition: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LiquidTransition.shared.transitionForPresent(from: presenting, to: presented)
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LiquidTransition.shared.transitionForDismiss(from: dismissed, to: dismissed.presentingViewController!)
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (animator as? LiquidTransitionProtocol)?.interactive
    }

    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (animator as? LiquidTransitionProtocol)?.interactive
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (animationController as? LiquidTransitionProtocol)?.interactive
    }
    
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return LiquidTransition.shared.transitionForPresent(from: fromVC, to: toVC)
        } else if operation == .pop {
            return LiquidTransition.shared.transitionForDismiss(from: fromVC, to: toVC)
        }
        return nil
    }
}
