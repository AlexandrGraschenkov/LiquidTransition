//
//  CardInfo.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 08.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit


struct CardInfo {
    enum CardType {
        case WebPage, WebTransferServer
    }
    var snapshot: UIImage?
    var controller: CardControllerProtocol?
    var vc: UIViewController? { return controller as? UIViewController }
    var type: CardType
    
    var state: Decodable?
}
