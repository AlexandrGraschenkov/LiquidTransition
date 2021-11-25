//
//  PhotosDetailViewController.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 06.10.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit
import Liquid

class PhotosDetailViewController: UIPageViewController {

    var photos: [PhotoInfo] = []
    var index: Int = 0
    var animTransition: PhotoOpenTransition?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        dataSource = self
        
        if let vc = getViewController(forIndex: index) {
            setViewControllers([vc], direction: .forward, animated: false, completion: nil)
        }
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(pan:)))
        pan.delegate = self
        view.addGestureRecognizer(pan)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let controllers = self.navigationController?.viewControllers,
            let prev = controllers[controllers.count-2] as? PhotosViewController {
            animTransition = Liquid.shared.transitionForDismiss(from: self, to: prev) as? PhotoOpenTransition
        }
    }
    
    @objc func onPan(pan: UIPanGestureRecognizer) {
        let offset = pan.translation(in: view)
        
        if pan.state == .began {
            if (offset.y < abs(offset.x)) {
                pan.isEnabled = false
                pan.isEnabled = true
                return
            }
            self.animTransition?.isInteractive = true
            if let nav = navigationController {
                nav.popViewController(animated: true)
                transitionCoordinator?.animate(alongsideTransition: nil, completion: { (_) in
                    self.animTransition?.isInteractive = false
                })
            } else {
                dismiss(animated: true) {
                    self.animTransition?.isInteractive = false
                }
            }
            
        } else if pan.state == .changed {
            let progress = min(0.7, max(0, offset.y / 200.0))
            Liquid.shared.update(progress: progress)
            animTransition?.updateInteractive(offset: CGPoint(x: offset.x * 0.7, y: offset.y), progress: progress)
        } else {
            Liquid.shared.complete()
        }
    }
    
}

extension PhotosDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let offset = (gestureRecognizer as? UIPanGestureRecognizer)?.translation(in: view) else {
            return false
        }
        if (offset.y < abs(offset.x)) {
//            gestureRecognizer.isEnabled = false
//            gestureRecognizer.isEnabled = true
            return false
        } else {
            otherGestureRecognizer.isEnabled = false
            otherGestureRecognizer.isEnabled = true
            return true
        }
    }
}

extension PhotosDetailViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func getViewController(forIndex index: Int) -> PhotoPreviewController? {
        if index < 0 || index >= photos.count {
            return nil
        }
        return PhotoPreviewController.controller(photo: photos[index], index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? PhotoPreviewController else {
            return nil
        }
        return getViewController(forIndex: vc.index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? PhotoPreviewController else {
            return nil
        }
        return getViewController(forIndex: vc.index + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let newIndex = (viewControllers?.first as? PhotoPreviewController)?.index {
                index = newIndex
            }
        }
    }
}
