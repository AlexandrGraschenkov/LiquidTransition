//
//  CardsAnimationTransition.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 14.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit


extension CATransform3D {
    static let perspectiveIdentity: CATransform3D = {
        var transform = CATransform3DIdentity
        transform.m34 = -0.015
        return transform
    }()
}

struct AnimationHelper {
    static func xRotation(_ angle: Double) -> CATransform3D {
        let rot = CATransform3DMakeRotation(CGFloat(angle), 1.0, 0.0, 0.0)
        return CATransform3DConcat(.perspectiveIdentity, rot)
    }
    
    static func perspectiveTransform(for containerView: UIView) {
        containerView.layer.sublayerTransform = .perspectiveIdentity
    }
}


class CardsAnimationTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if let cardsVC = transitionContext.viewController(forKey: .from) as? CardsNavigationController,
            let contentVC = transitionContext.viewController(forKey: .to) as? CardControllerProtocol {
            animateToContent(context: transitionContext, cardsVC: cardsVC, contentVC: contentVC)
        } else if let cardsVC = transitionContext.viewController(forKey: .to) as? CardsNavigationController,
            let contentVC = transitionContext.viewController(forKey: .from) as? CardControllerProtocol {
            animateDismissContent(context: transitionContext, cardsVC: cardsVC, contentVC: contentVC)
        }
    }
    
    func animateToContent(context: UIViewControllerContextTransitioning, cardsVC: CardsNavigationController, contentVC: CardControllerProtocol) {
        let container = context.containerView
        
        let contentView: UIView = (contentVC as! UIViewController).view
        contentView.frame = container.bounds
        container.addSubview(contentView)
        
        let content = contentVC.getContentView()
        let startContentFrame = content.frame
        let card = cardsVC.getTransitionCell()
        
        let cardFrame = card.convert(card.bounds, to: container)
        
        let scale = cardFrame.width / content.bounds.width
        content.transform = CGAffineTransform(scaleX: scale, y: scale)
        content.center = CGPoint(x: cardFrame.midX, y: cardFrame.midY)
        
        
        let clipContainer = UIView(frame: CGRect(x: 0, y: 0, width: cardFrame.width / scale, height: cardFrame.height / scale))
        clipContainer.center = CGPoint(x: content.bounds.midX, y: content.bounds.midY)
        clipContainer.clipsToBounds = true
        clipContainer.backgroundColor = UIColor.white
        clipContainer.layer.cornerRadius = 20
        content.mask = clipContainer
        
        if let toolbar = contentVC.getToolbarView() {
            let frame = toolbar.frame
            toolbar.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
            toolbar.frame = frame
            toolbar.layer.transform = AnimationHelper.xRotation(-.pi / 2.0)
        }
        
        let duration = transitionDuration(using: context)
        UIView.animate(withDuration: duration, animations: {
            content.transform = .identity
            clipContainer.layer.cornerRadius = 0
            clipContainer.frame = content.bounds
            content.frame = startContentFrame
            contentVC.getToolbarView()?.layer.transform = CATransform3DIdentity
            
        }) { (_) in
            content.mask = nil
            cardsVC.view.removeFromSuperview()
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
    
    func animateDismissContent(context: UIViewControllerContextTransitioning, cardsVC: CardsNavigationController, contentVC: CardControllerProtocol) {
        let container = context.containerView
        
        let cardsView: UIView = cardsVC.view
        cardsView.frame = container.bounds
        container.insertSubview(cardsView, at: 0)
        
        let content = contentVC.getContentView()
        let contentStartFrame = content.frame
        let card = cardsVC.getTransitionCell()
        
        let cardFrame = card.convert(card.bounds, to: container)
        
        
        
        let clipContainer = UIView(frame: content.bounds)
        clipContainer.clipsToBounds = true
        clipContainer.backgroundColor = UIColor.white
        clipContainer.layer.cornerRadius = 0
        content.mask = clipContainer
        
        
        let duration = transitionDuration(using: context)
        UIView.animate(withDuration: duration, animations: {
            let scale = cardFrame.width / content.bounds.width
            content.transform = CGAffineTransform(scaleX: scale, y: scale)
            content.center = CGPoint(x: cardFrame.midX, y: cardFrame.midY)
            
            clipContainer.layer.cornerRadius = 20
            clipContainer.frame = CGRect(x: 0, y: 0, width: cardFrame.width / scale, height: cardFrame.height / scale)
            clipContainer.center = CGPoint(x: content.bounds.midX, y: content.bounds.midY)

            contentVC.getToolbarView()?.layer.transform = AnimationHelper.xRotation(-.pi / 2.0)
            
        }) { (_) in
            content.mask = nil
            content.transform = .identity
            content.frame = contentStartFrame
            contentVC.getToolbarView()?.layer.transform = CATransform3DIdentity
            (contentVC as? UIViewController)?.view.removeFromSuperview()
            context.completeTransition(!context.transitionWasCancelled)
        }
    }
}
