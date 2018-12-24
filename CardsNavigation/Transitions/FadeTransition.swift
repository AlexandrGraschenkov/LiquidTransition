//
//  FadeTransition.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 28.10.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit
import Liquid

class FadeTransition: TransitionAnimator<UIViewController, CardsNavigationController> {

    init() {
        super.init(from: UIViewController.self, to: CardsNavigationController.self, direction: .both)
        
        duration = 0.3
    }
    
    override func animateTransition(from vc1: UIViewController, to vc2: CardsNavigationController, container: UIView, duration: Double) {
        vc2.view.alpha = 0
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            vc2.view.alpha = 1
        }) { _ in
            vc2.view.alpha = 1 // if anim somehow canceled
        }
    }
}
