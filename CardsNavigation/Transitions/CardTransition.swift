//
//  LiCardTransition.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 29.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit
import Liquid

extension CATransform3D {
    static let perspectiveIdentity: CATransform3D = {
        var transform = CATransform3DIdentity
        transform.m34 = -0.006
        return transform
    }()
}

struct AnimationHelper {
    static func xRotation(_ angle: Double) -> CATransform3D {
        return CATransform3DRotate(.perspectiveIdentity, CGFloat(angle), 1, 0, 0)
    }
}

class CardTransition: TransitionAnimator<CardsNavigationController, WebViewController> {
    var clipContainer: UIView!
    var scaleFactor: CGFloat = 1.0
    
    init() {
        super.init(from: CardsNavigationController.self, to: WebViewController.self, direction: .both)
        
        duration = 0.7
        addCustomAnimation(animateCornerRadius)
    }
    
    
    override func animateTransition(from vc1: CardsNavigationController,
                            to vc2: WebViewController,
                            container: UIView,
                            duration: Double) {
        let restore = TransitionRestorer()
        let content = vc2.getContentView()
        let startContentFrame = content.frame
        let card = vc1.getTransitionCell()
        
        restore.addRestoreViews(content)
        let cardFrame = card.convert(card.bounds, to: container)
        
        let scale = max(cardFrame.width / content.bounds.width,
                        cardFrame.height / content.bounds.height)
        scaleFactor = scale
        content.transform = CGAffineTransform(scaleX: scale, y: scale)
        content.center = CGPoint(x: cardFrame.midX, y: cardFrame.midY)
        
        
        clipContainer = UIView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: cardFrame.width / scale,
                                             height: cardFrame.height / scale))
        clipContainer.center = CGPoint(x: content.bounds.midX, y: content.bounds.midY)
        clipContainer.clipsToBounds = true
        clipContainer.backgroundColor = UIColor.white
        content.mask = clipContainer
        
        let toolbar = vc2.toolbar!
        restore.addRestoreViews(toolbar)
        let toolbarFrame = toolbar.frame
        toolbar.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        toolbar.frame = toolbarFrame
        toolbar.layer.transform = AnimationHelper.xRotation(.pi * 0.6)
        
        let status = vc2.statusBarView!
        restore.addRestoreViews(status)
        let statusFrame = status.frame
        status.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        status.frame = statusFrame
        status.layer.transform = AnimationHelper.xRotation(-.pi * 0.6)
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            content.transform = .identity
            self.clipContainer.frame = content.bounds
            content.frame = startContentFrame
            toolbar.layer.transform = CATransform3DIdentity
            status.layer.transform = CATransform3DIdentity
        }) { (finished) in
            content.mask = nil
            toolbar.layer.transform = CATransform3DIdentity
            status.layer.transform = CATransform3DIdentity
            self.clipContainer = nil
            restore.restore()
        }
    }
    
    func animateCornerRadius(_ percent: CGFloat) {
        if let clip = clipContainer {
            clip.layer.cornerRadius = 20 / scaleFactor * (1-percent)
        }
    }
}
