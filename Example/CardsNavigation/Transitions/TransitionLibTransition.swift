//
//  TransitionLibTransition.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 20/10/2019.
//  Copyright © 2019 Alex Development. All rights reserved.
//

import UIKit
import Liquid

class TransitionLibTransition: Animator<TransitionExampleVC, TransitionExampleVC> {
    
    init() {
        super.init()
        
        duration = 0.5
    }
    
    override func animation(src: TransitionExampleVC,
                            dst: TransitionExampleVC,
                            container: UIView,
                            duration: Double) {
        dst.view.transform = CGAffineTransform(translationX: 0, y: -container.bounds.height)
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            dst.view.transform = .identity
        })
    }
    
    override func animationDismiss(src: TransitionExampleVC, dst: TransitionExampleVC, container: UIView, duration: Double) {


        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            dst.view.transform = CGAffineTransform(translationX: 0, y: -container.bounds.height)
        }){_ in dst.view.transform = .identity}
    }
}
