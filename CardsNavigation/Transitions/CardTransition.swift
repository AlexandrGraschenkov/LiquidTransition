//
//  LiCardTransition.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 29.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit
import Liquid

private extension CATransform3D {
    static let perspectiveIdentity: CATransform3D = {
        var transform = CATransform3DIdentity
        transform.m34 = -0.006
        return transform
    }()
}

private struct AnimationHelper {
    static func xRotation(_ angle: Double) -> CATransform3D {
        return CATransform3DRotate(.perspectiveIdentity, CGFloat(angle), 1, 0, 0)
    }
    
    static func updateAnchorPoint(_ point: CGPoint, for view: UIView) {
        let frame = view.frame
        view.layer.anchorPoint = point
        view.frame = frame
    }
}

class CardTransition: Animator<CardsNavigationController, WebViewController> {
    var clipContainer: UIView!
    var scaleFactor: CGFloat = 1.0
    
    
    init() {
        super.init()
        
        duration = 0.7
        addCustomAnimation(animateCornerRadius)
    }
    
    
    override func animation(src: CardsNavigationController,
                            dst: WebViewController,
                            container: UIView,
                            duration: Double) {
        // perform your animation
        let restore = TransitionRestorer()
        let content = dst.getContentView()
        let card = src.getTransitionCell()
        let toolbar = dst.toolbar!
        let status = dst.statusBarView!
        let startContentFrame = content.frame
        
        restore.addRestore(content, toolbar, status)
        restore.addRestoreKeyPath(toolbar, keyPaths: \.layer.transform)
        restore.addRestoreKeyPath(status, keyPaths: \.layer.transform)
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
        
        
        AnimationHelper.updateAnchorPoint(CGPoint(x: 0.5, y: 1), for: toolbar)
        toolbar.layer.transform = AnimationHelper.xRotation(.pi * 0.6)
        
        AnimationHelper.updateAnchorPoint(CGPoint(x: 0.5, y: 0), for: status)
        status.layer.transform = AnimationHelper.xRotation(-.pi * 0.6)
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            content.transform = .identity
            self.clipContainer.frame = content.bounds
            content.frame = startContentFrame
            toolbar.layer.transform = CATransform3DIdentity
            status.layer.transform = CATransform3DIdentity
        }) { (finished) in
            content.mask = nil
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
