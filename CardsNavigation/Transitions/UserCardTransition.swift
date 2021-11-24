//
//  UserCardTransition.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 24.05.2021.
//  Copyright © 2021 Alex Development. All rights reserved.
//

import UIKit
import Liquid


class UserCardTransition: Animator<UserDetailController, UserDetailController> {
    var clipContainer: UIView!
    var scaleFactor: CGFloat = 1.0
    
    
    init() {
        super.init()
        
        direction = .present
        duration = 0.7
        addCustomAnimation(animateCornerRadius)
    }
    
    override func canAnimate(src: UIViewController, dst: UIViewController, direction animDirection: Animator<UserDetailController, UserDetailController>.Direction) -> Bool {
        guard let src = src as? UserDetailController,
              let _ = dst as? UserDetailController else {
            return false
        }
        
        return src.popup != nil
    }
    
    
    override func animation(src: UserDetailController,
                            dst: UserDetailController,
                            container: UIView,
                            duration: Double) {
        // perform your animation
        let restore = TransitionRestorer()
        guard let popup = src.popup else {
            return
        }
        
        restore.addRestore(popup.container!)
        clipContainer = popup.container
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            popup.container?.frame = dst.view.convert(dst.view.bounds, to: dst.view.window)
        }) { (finished) in
            self.clipContainer = nil
            restore.restore()
        }
    }
    
    func animateCornerRadius(_ percent: CGFloat) {
        let fromCorner: CGFloat = 30
        let toCorner: CGFloat = 10
        clipContainer?.layer.cornerRadius = (toCorner - fromCorner) * percent + fromCorner
    }
}
