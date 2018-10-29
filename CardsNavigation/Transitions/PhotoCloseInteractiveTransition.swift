//
//  PhotoCloseInteractiveTransition.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 15.10.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit
import Liquid

class PhotoCloseInteractiveTransition: TransitionAnimator<PhotosDetailViewController, PhotosViewController> {

    fileprivate var animImageView: UIImageView!
    fileprivate var corners: CGFloat = 0
    fileprivate var toFrame: CGRect = .zero
    fileprivate var fromFrame: CGRect = .zero
    
    init() {
        super.init(from: PhotosDetailViewController.self, to: PhotosViewController.self, direction: .dismiss)
        
        duration = 0.4
        timing = Timing.easeOutExpo
        addCustomAnimation { [weak self] (progress) in
            guard let `self` = self else { return }
            self.animImageView?.layer.cornerRadius = self.corners * min(1, 2.0 * progress)
            print("progress", progress)
        }
    }
    
    override func animation(vc1: PhotosDetailViewController, vc2: PhotosViewController, container: UIView, duration: Double) {
        guard let cell = vc2.collectionView?.cellForItem(at: IndexPath(item: vc1.index, section: 0)) as? PhotoCell else {
            print("Something went wrong")
            return
        }
        guard let preview = vc1.viewControllers?.first as? PhotoPreviewController,
            let imgView = preview.imageView else {
            print("Something went wrong")
            return
        }
        toFrame = cell.imgView.convert(cell.imgView.bounds, to: container)
        fromFrame = vc2.view.bounds.getAspectFit(viewSize: imgView.image!.size)
        corners = cell.corners
        
        let restore = RestoreTransition(keyPaths: SaveViewState(path: \.contentMode))
        restore.moveView(imgView, to: container)
        
        animImageView = imgView
        animImageView.frame = fromFrame
        animImageView.contentMode = .scaleAspectFill
        animImageView.layer.masksToBounds = true
        animImageView.layer.cornerRadius = cell.corners
        
        restore.addRestore(cell.imgView)
        restore.addRestore(vc1.view, ignoreFields: [.superview])
        
        cell.imgView.isHidden = true
        
        print("Custom duration", TimeInterval(duration))
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            vc1.view.alpha = 0
        }) { (_) in
            restore.restore()
        }
    }
    
    override func completeInteractiveTransition(vc1: PhotosDetailViewController, vc2: PhotosViewController, isPresenting: Bool, finish: Bool, animationDuration: Double) {
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveLinear], animations: {
            self.animImageView.frame = finish ? self.toFrame : self.fromFrame
        }, completion: nil)
    }
    
    func updateInteractive(offset: CGPoint, progress: CGFloat) {
        let mid = fromFrame.mid.add(offset)
        let size = fromFrame.size.interpolation(to: toFrame.size, progress: progress)
        self.animImageView.frame = CGRect(mid: mid, size: size)
    }
}

fileprivate extension CGSize {
    func interpolation(to: CGSize, progress: CGFloat) -> CGSize {
        return CGSize(width: (to.width - width) * progress + width,
                      height: (to.height - height) * progress + height)
    }
}
