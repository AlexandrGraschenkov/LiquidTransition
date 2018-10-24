//
//  CardControllerProtocol.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 08.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

protocol CardControllerProtocol {

    func getContentView() -> UIView
    
    func getToolbarView() -> UIView
    
    func getState() -> Codable?
    
    func restoreFromState(state: Codable)

}

