//
//  PhotoOpenTransition.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 15.10.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit
import Liquid

class PhotoOpenTransition: TransitionAnimator<PhotosViewController, PhotosDetailViewController> {

    fileprivate var animImageView: UIImageView!
    fileprivate var corners: CGFloat = 0
    fileprivate var toFrame: CGRect = .zero
    fileprivate var fromFrame: CGRect = .zero
    var isInteractive = false
    
    init() {
        super.init(from: PhotosViewController.self, to: PhotosDetailViewController.self, direction: .both)
        
        duration = 0.4
        timing = Timing.easeOutSine
        addCustomAnimation { [weak self] (progress) in
            guard let `self` = self else { return }
            self.animImageView?.layer.cornerRadius = self.corners * min(1, 2.0 * progress)
            print("progress", progress)
        }
    }
    
    override func animation(vc1: PhotosViewController, vc2: PhotosDetailViewController, container: UIView, duration: Double) {
        guard let cell = vc1.collectionView?.cellForItem(at: IndexPath(item: vc2.index, section: 0)) as? PhotoCell else {
            print("Something went wrong")
            return
        }
        let photo = vc1.photos[vc2.index]
        let frame = cell.imgView.convert(cell.imgView.bounds, to: container)
        corners = cell.corners
        
        animImageView = UIImageView(frame: frame)
        animImageView.contentMode = .scaleAspectFill
        animImageView.image = UIImage(named: photo.assetName)
        animImageView.layer.masksToBounds = true
        animImageView.layer.cornerRadius = cell.corners
        
        let restore = RestoreTransition()
        let contentVC = vc2.viewControllers?.first as? PhotoPreviewController
        let detailContentView = contentVC?.imageView
        restore.addRestore(animImageView, cell.imgView)
        restore.addRestore(vc2.view, ignoreFields: [.superview])
        if let content = detailContentView {
            restore.addRestore(content)
        }
        
        vc2.view.alpha = 0
        detailContentView?.isHidden = true
        cell.imgView.isHidden = true
        
        container.addSubview(animImageView)
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            self.animImageView.frame = vc2.view.bounds.getAspectFit(viewSize: self.animImageView.image!.size)
            vc2.view.alpha = 1
        }) { (_) in
            restore.restore()
        }
    }
    
    override func animationDismiss(vc1: PhotosViewController, vc2: PhotosDetailViewController, container: UIView, duration: Double) {
        guard let cell = vc1.collectionView?.cellForItem(at: IndexPath(item: vc2.index, section: 0)) as? PhotoCell else {
            print("Something went wrong")
            return
        }
        guard let preview = vc2.viewControllers?.first as? PhotoPreviewController,
            let imgView = preview.imageView else {
            print("Something went wrong")
            return
        }
        toFrame = cell.imgView.convert(cell.imgView.bounds, to: container)
        fromFrame = vc1.view.bounds.getAspectFit(viewSize: imgView.image!.size)
        corners = cell.corners
        
        let restore = RestoreTransition(keyPaths: SaveViewState(path: \.contentMode))
        restore.moveView(imgView, to: container)
        
        animImageView = imgView
        animImageView.frame = fromFrame
        animImageView.contentMode = .scaleAspectFill
        animImageView.layer.masksToBounds = true
        animImageView.layer.cornerRadius = cell.corners
        
        restore.addRestore(cell.imgView)
        restore.addRestore(vc2.view, ignoreFields: [.superview])
        
        cell.imgView.isHidden = true
        
        print("Custom duration", TimeInterval(duration))
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            vc2.view.alpha = 0
            if !self.isInteractive {
                self.animImageView.frame = self.toFrame
            }
        }) { (_) in
            restore.restore()
        }
    }
    
    override func completeInteractiveTransition(vc1: PhotosViewController, vc2: PhotosDetailViewController, isPresenting: Bool, finish: Bool, animationDuration: Double) {
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
