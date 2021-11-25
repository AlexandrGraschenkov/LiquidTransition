//
//  TestBrokenAnimationController.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 01.10.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit
import Liquid

class TestBrokenAnimationController: UIViewController {

    @IBOutlet var imgView: UIImageView!
    var dismissFromPoint: CGPoint = CGPoint(x: 100, y: 100)
    var animator = BrokenViewTransition()
    @IBOutlet var smoothInteractiveSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        transitioningDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onPan(pan: UIPanGestureRecognizer) {
        if pan.state == .began {
            let offset = pan.translation(in: pan.view)
            if (abs(offset.x) > offset.y) {
                pan.isEnabled = false
                pan.isEnabled = true
                // allow only swipe down dismiss
                return
            }
            
            dismissFromPoint = pan.location(in: pan.view)
            animator.percentAnimator.enableSmoothInteractive = true
            
            dismiss(animated: true, completion: nil)
        } else if pan.state == .changed {
            let offset = pan.translation(in: pan.view)
            let progress = min(1, max(offset.y / 300.0, 0))
            Liquid.shared.update(progress: progress)
        } else if pan.state == .ended {
            Liquid.shared.complete()
        }
    }

}

extension TestBrokenAnimationController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.animator.percentAnimator
    }
}

