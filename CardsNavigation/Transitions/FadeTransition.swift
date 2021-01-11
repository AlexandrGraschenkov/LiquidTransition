//
//  FadeTransition.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 28.10.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit
import Liquid

class FadeTransition: Animator<UIViewController, CardsNavigationController> {

    init() {
        super.init()
        
        duration = 0.3
    }
    
    override func animation(src: UIViewController, dst: CardsNavigationController, container: UIView, duration: Double) {
        dst.view.alpha = 0
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            dst.view.alpha = 1
        }) { _ in
            dst.view.alpha = 1 // if anim somehow canceled
        }
    }
}
