//
//  LiquidTransition.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 22.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit


class LiquidTransition: NSObject {

    static var shared = LiquidTransition()
    
    public struct Direction: OptionSet {
        let rawValue: UInt
        
        static let present = Direction(rawValue: 1 << 0)
        static let dismiss = Direction(rawValue: 1 << 1)
        static let both: Direction = [.present, .dismiss]
    }
    
    func update(progress: CGFloat) {
        currentTransition?.progress = progress
    }
    
    func finish(complete: Bool? = nil, animated: Bool = true) {
        guard let transition = currentTransition else { return }
        
        transition.completeInteractive(complete: complete, animated: animated)
    }
    
    func addTransition(transition: LiquidTransitionProtocol) {
        transitions.append(transition)
    }
    
    func transitionForPresent(from: UIViewController, to: UIViewController) -> LiquidTransitionProtocol? {
        let transition = transitions.first(where: {$0.canAnimate(from: from, to: to, direction: .present)})
        transition?.isPresenting = true
        return transition
    }
    
    func transitionForDismiss(from: UIViewController, to: UIViewController) -> LiquidTransitionProtocol? {
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
//        let sel1 = #selector(UIViewControllerTransitioningDelegate.animationController(forPresented:presenting:source:))
//        let liSel1 = #selector(UIViewController.li_animationController(forPresented:presenting:source:))
//        LiquidRuntimeHelper.addOrReplaceMethod(class: UIViewController.self, original: sel1, swizzled: liSel1)
//
//        let sel2 = #selector(UIViewControllerTransitioningDelegate.animationController(forDismissed:))
//        let liSel2 = #selector(UIViewController.li_animationController(forDismissed:))
//        LiquidRuntimeHelper.addOrReplaceMethod(class: UIViewController.self, original: sel2, swizzled: liSel2)
//
//        let sel3 = #selector(UIViewControllerTransitioningDelegate.interactionControllerForDismissal(using:))
//        let liSel3 = #selector(UIViewController.li_interactionControllerForDismissal(using:))
//        LiquidRuntimeHelper.addOrReplaceMethod(class: UIViewController.self, original: sel3, swizzled: liSel3)
//
//        let sel4 = #selector(UIViewControllerTransitioningDelegate.interactionControllerForPresentation(using:))
//        let liSel4 = #selector(UIViewController.li_interactionControllerForPresentation(using:))
//        LiquidRuntimeHelper.addOrReplaceMethod(class: UIViewController.self, original: sel4, swizzled: liSel4)
    }
    
    internal var currentTransition: LiquidTransitionProtocol?
    fileprivate var transitions: [LiquidTransitionProtocol] = []
}

extension UIViewController {
    @objc func li_viewDidLoad() {
        if self.transitioningDelegate == nil {
            self.transitioningDelegate = LiquidTransition.shared
        }
        self.li_viewDidLoad()
    }
}

extension LiquidTransition: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LiquidTransition.shared.transitionForPresent(from: presenting, to: presented)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LiquidTransition.shared.transitionForDismiss(from: dismissed, to: dismissed.presentingViewController!)
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (animator as? LiquidTransitionProtocol)?.interactive
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return (animator as? LiquidTransitionProtocol)?.interactive
    }
}
