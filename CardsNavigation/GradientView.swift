//
//  GradientView.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 08.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

class GradientView: UIView {

    override class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }

    fileprivate var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [
            UIColor(red: 1, green: 0.5764705882, blue: 0.5843137255, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.5764705882, blue: 0.462745098, alpha: 1).cgColor
        ]
    }
    
    func setColors(from: UIColor, to: UIColor) {
        gradientLayer.colors = [from.cgColor, to.cgColor]
    }
}
