//
//  LiCardTransition.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 29.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

class LiCardTransition: TransitionAnimator<CardsNavigationController, WebViewController> {
    var clipContainer: UIView!
    var scaleFactor: CGFloat = 1.0
    
    init() {
        super.init(from: CardsNavigationController.self, to: WebViewController.self, direction: .both)
        
        duration = 0.7
        setAnimation(closure: animation(cardsVC:webVC:container:duration:))
        addCustomAnimation(closure: animateCornerRadius)
    }
    
    
    func animation(cardsVC: CardsNavigationController, webVC: WebViewController, container: UIView, duration: Double) {
        let content = webVC.getContentView()
        let startContentFrame = content.frame
        let card = cardsVC.getTransitionCell()
        
        let cardFrame = card.convert(card.bounds, to: container)
        
        let scale = cardFrame.width / content.bounds.width
        scaleFactor = scale
        content.transform = CGAffineTransform(scaleX: scale, y: scale)
        content.center = CGPoint(x: cardFrame.midX, y: cardFrame.midY)
        
        
        clipContainer = UIView(frame: CGRect(x: 0, y: 0, width: cardFrame.width / scale, height: cardFrame.height / scale))
        clipContainer.center = CGPoint(x: content.bounds.midX, y: content.bounds.midY)
        clipContainer.clipsToBounds = true
        clipContainer.backgroundColor = UIColor.white
        content.mask = clipContainer
        
        if let toolbar = webVC.getToolbarView() {
            let frame = toolbar.frame
            toolbar.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
            toolbar.frame = frame
            toolbar.layer.transform = AnimationHelper.xRotation(-.pi / 2.0)
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            content.transform = .identity
            self.clipContainer.frame = content.bounds
            content.frame = startContentFrame
            webVC.getToolbarView()?.layer.transform = CATransform3DIdentity
        }) { (finished) in
            print("Anim " + (finished ? "finished" : "canceled"))
            content.mask = nil
            content.transform = .identity
            content.frame = startContentFrame
            webVC.getToolbarView()?.layer.transform = CATransform3DIdentity
            self.clipContainer = nil
        }
    }
    
    func animateCornerRadius(_ percent: CGFloat) {
        if let clip = clipContainer {
            clip.layer.cornerRadius = 20 / scaleFactor * (1-percent)
        }
    }
}
