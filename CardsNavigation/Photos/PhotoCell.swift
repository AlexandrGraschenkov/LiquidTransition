//
//  PhotoCell.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 04.10.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var indicator: UIActivityIndicatorView!
    var cancelImageLoad: Cancelable?
    let corners: CGFloat = 5.0
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelImageLoad?()
        cancelImageLoad = nil
        imgView.image = nil
    }
    
    func display(photo: PhotoInfo) {
        indicator.startAnimating()
        cancelImageLoad = ThumbCaches.shared.getImage(name: photo.assetName, size: imgView.bounds.size, corners: corners, completion: {[weak self] (img) in
            self?.imgView.image = img
            self?.indicator.stopAnimating()
        })
    }
    
}
