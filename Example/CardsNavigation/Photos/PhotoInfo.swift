//
//  PhotoInfo.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 05.10.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit


class PhotoInfo {
    let assetName: String
    var cachedThumbImage: UIImage?
    
    init(name: String) {
        assetName = name
        cachedThumbImage = nil
    }
}
