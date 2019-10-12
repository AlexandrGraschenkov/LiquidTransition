//
//  LiquidTransition.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 22.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit


public typealias Cancelable = ()->()

public final class Liquid: NSObject {

    public static var shared = Liquid()
    
    public struct Direction: OptionSet {
        public let rawValue: UInt
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        public static let present = Direction(rawValue: 1 << 1)
        public static let dismiss = Direction(rawValue: 1 << 2)
        public static let both: Direction = [.present, .dismiss]
    }
    
    /**
     Automaticly becomes delegate for all transitions, that not defined manually
     
     Performs swizzle **viewDidLoad** for **UIViewController**s
     
     Don't worry, at every time you can ovveride delegate for specific controller to perform animation manually
     */
    public func becomeDelegate() {
        if isSwizzled { return }
        
        isSwizzled = true
        let sel1 = #selector(UIViewController.viewDidLoad)
        let liSel1 = #selector(UIViewController.li_viewDidLoad)
        LiquidRuntimeHelper.addOrReplaceMethod(class: UIViewController.self, original: sel1, swizzled: liSel1)
    }
    
    public func addTransitions(_ arr: [LiquidTransitionProtocol]) {
        let arrInternal = arr.compactMap({$0 as? LiquidTransitionProtocolInternal})
        transitions.append(contentsOf: arrInternal)
        if arrInternal.count != arr.count {
            print("Error: please inherit from Liquid.Animator<Source, Destination>")
        }
    }
    
    public func addTransition(_ transition: LiquidTransitionProtocol) {
        if let transition = transition as? LiquidTransitionProtocolInternal {
            transitions.append(transition)
        } else {
            print("Error: please inherit from Liquid.Animator<Source, Destination>")
        }
    }
    
    public func removeAllTransitions() {
        transitions.removeAll()
    }
    
    /**
     Performs interactive transition
     
     You can call update right after transition was startded
     */
    public func update(progress: CGFloat) {
        currentTransition?.progress = progress
    }
    
    /**
     Completes interactive transition
     
     By default finish or cancel transition desides automaticly
     */
    public func complete(finish: Bool? = nil, animated: Bool = true) {
        guard let transition = currentTransition else { return }
        
        transition.completeInteractive(complete: finish, animated: animated)
    }
    
    
    public func transitionForPresent(from: UIViewController, to: UIViewController) -> LiquidTransitionProtocol? {
        let transition = transitions.first(where: {$0.canAnimate(src: from, dst: to, direction: .present)})
        return transition
    }
    
    public func transitionForDismiss(from: UIViewController, to: UIViewController) -> LiquidTransitionProtocol? {
        let transition = transitions.first(where: {$0.canAnimate(src: from, dst: to, direction: .dismiss)})
        return transition
    }
    
    // MARK: - private
    fileprivate override init() {
        super.init()
    }
    
    func presentTransition(from: UIViewController, to: UIViewController) -> LiquidTransitionProtocol? {
        let transition = transitions.first(where: {$0.canAnimate(src: from, dst: to, direction: .present)})
        transition?.isPresenting = true
        return transition
    }
    
    func dismissTransition(from: UIViewController, to: UIViewController) -> LiquidTransitionProtocol? {
        let transition = transitions.first(where: {$0.isEnabled && $0.canAnimate(src: from, dst: to, direction: .dismiss)})
        transition?.isPresenting = false
        return transition
    }
    
    public internal(set) var currentTransition: LiquidTransitionProtocol?
    fileprivate var transitions: [LiquidTransitionProtocolInternal] = []
    fileprivate var isSwizzled: Bool = false
}

extension UIViewController {
    @objc func li_viewDidLoad() {
        if self.transitioningDelegate == nil {
            self.transitioningDelegate = Liquid.shared
        }
        if let nav = self as? UINavigationController, nav.delegate == nil {
            nav.delegate = Liquid.shared
        }
        self.li_viewDidLoad()
    }
}

extension Liquid: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Liquid.shared.presentTransition(from: presenting, to: presented)
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Liquid.shared.dismissTransition(from: dismissed, to: dismissed.presentingViewController!)
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (animator as? LiquidTransitionProtocol)?.percentAnimator
    }

    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (animator as? LiquidTransitionProtocol)?.percentAnimator
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (animationController as? LiquidTransitionProtocol)?.percentAnimator
    }
    
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return Liquid.shared.presentTransition(from: fromVC, to: toVC)
        } else if operation == .pop {
            return Liquid.shared.dismissTransition(from: fromVC, to: toVC)
        }
        return nil
    }
}
