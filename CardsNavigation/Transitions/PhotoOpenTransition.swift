//
//  PhotoOpenController.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 09.10.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit
import Liquid

class PhotoOpenTransition: TransitionAnimator<PhotosViewController, PhotosDetailViewController> {
    
    fileprivate var animImageView: UIImageView!
    fileprivate var corners: CGFloat = 0
    
    init() {
        super.init(from: PhotosViewController.self, to: PhotosDetailViewController.self, direction: .both)
        
        duration = 0.35
        timing = Timing.easeOutSine
        addCustomAnimation { [weak self] (progress) in
            guard let `self` = self else { return }
            self.animImageView?.layer.cornerRadius = self.corners * 2.0 * max(0, 0.5 - progress)
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
}
