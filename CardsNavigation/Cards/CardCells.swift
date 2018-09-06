//
//  CardCells.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 18.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

class CardItemCell: UICollectionViewCell {
    let cornerRadius: CGFloat = 20
    @IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        contentView.layer.cornerRadius = cornerRadius
//        contentView.clipsToBounds = true
        imageView.layer.cornerRadius = cornerRadius
        imageView.clipsToBounds = true
    }
}
