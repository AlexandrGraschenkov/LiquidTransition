//
//  PhotosDetailViewController.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 06.10.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

class PhotosDetailViewController: UIPageViewController {

    var photos: [PhotoInfo] = []
    var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        dataSource = self
        
        if let vc = getViewController(forIndex: index) {
            setViewControllers([vc], direction: .forward, animated: false, completion: nil)
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
