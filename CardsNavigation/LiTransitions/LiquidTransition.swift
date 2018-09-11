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
    
    public enum Direction: String {
        case present = ">"
        case dismiss = "<"
        case both = "◇"
    }
    
    static func generateKey(fromVC: Any, toVC: Any, direction: Direction) -> String {
        return String(describing: fromVC) + " -> " + String(describing: toVC) + " |" + direction.rawValue
    }
    
    func update(progress: CGFloat) {
        currentTransition?.progress = progress
    }
    
    func finish(complete: Bool? = nil, animated: Bool = true) {
        guard let transition = currentTransition else { return }
        
        if (animated) {
            var finish = true
            var speed: CGFloat = 0
            if let complete = complete {
                finish = complete
            } else {
                finish = transition.interactive.needFinish()
                speed = abs(transition.interactive.lastSpeed)
            }
            transition.interactive.animate(finish: finish, speed: speed)
        } else {
            let finish = complete ?? transition.interactive.needFinish()
            transition.progress = finish ? 1 : 0
            if finish {
                transition.interactive.finish()
            } else {
                transition.interactive.cancel()
            }
        }
    }
    
    func addTransition(transition: LiquidTransitionProtocol) {
        transitions[transition.key] = transition
    }
    
    func transitionForPresent(from: UIViewController, to: UIViewController) -> LiquidTransitionProtocol? {
        let key = LiquidTransition.generateKey
        let fromType = type(of: from)
        let toType = type(of: to)
        let transition = transitions[key(fromType, toType, .present)] ??
                transitions[key(fromType, toType, .both)]
        transition?.isPresenting = true
        return transition
    }
    
    func transitionForDismiss(from: UIViewController, to: UIViewController) -> LiquidTransitionProtocol? {
        let key = LiquidTransition.generateKey
        let fromType = type(of: from)
        let toType = type(of: to)
        let transition = transitions[key(fromType, toType, .dismiss)] ??
                transitions[key(toType, fromType, .both)]
        transition?.isPresenting = false
        return transition
    }
    
    // MARK: - private
    fileprivate override init() {
        super.init()
        
        let sel1 = #selector(UIViewControllerTransitioningDelegate.animationController(forPresented:presenting:source:))
        let liSel1 = #selector(UIViewController.li_animationController(forPresented:presenting:source:))
        LiquidRuntimeHelper.addOrReplaceMethod(class: UIViewController.self, original: sel1, swizzled: liSel1)
        
        let sel2 = #selector(UIViewControllerTransitioningDelegate.animationController(forDismissed:))
        let liSel2 = #selector(UIViewController.li_animationController(forDismissed:))
        LiquidRuntimeHelper.addOrReplaceMethod(class: UIViewController.self, original: sel2, swizzled: liSel2)
        
        let sel3 = #selector(UIViewControllerTransitioningDelegate.interactionControllerForDismissal(using:))
        let liSel3 = #selector(UIViewController.li_interactionControllerForDismissal(using:))
        LiquidRuntimeHelper.addOrReplaceMethod(class: UIViewController.self, original: sel3, swizzled: liSel3)
        
        let sel4 = #selector(UIViewControllerTransitioningDelegate.interactionControllerForPresentation(using:))
        let liSel4 = #selector(UIViewController.li_interactionControllerForPresentation(using:))
        LiquidRuntimeHelper.addOrReplaceMethod(class: UIViewController.self, original: sel4, swizzled: liSel4)
    }
    
    internal var currentTransition: LiquidTransitionProtocol?
    fileprivate var transitions: [String: LiquidTransitionProtocol] = [:]
}

extension UIViewController {
    @objc func li_animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("test")
//        return nil
        return LiquidTransition.shared.transitionForPresent(from: presenting, to: presented)
    }
    
    @objc func li_animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("test2")
        return LiquidTransition.shared.transitionForDismiss(from: dismissed, to: self)
    }
    
    @objc func li_interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        print("test3")
//        return nil
        return (animator as? LiquidTransitionProtocol)?.interactive
    }
    
    @objc func li_interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        print("test4")
        return (animator as? LiquidTransitionProtocol)?.interactive
    }
}
