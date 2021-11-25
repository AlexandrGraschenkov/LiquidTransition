//
//  TransitionExampleVC.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 20/10/2019.
//  Copyright © 2019 Alex Development. All rights reserved.
//

import UIKit

class TransitionExampleVC: UIViewController {
    
    var magicIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = color(magicIndex)
        title = "Awesomeness".magic(magicIndex)
    }
    
    @IBAction func toNext() {
        guard let newViewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? TransitionExampleVC else { return }
        newViewController.magicIndex = magicIndex + 1
        navigationController?.pushViewController(newViewController, animated: true)
    }
    
}

// • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • //

func color(_ index: Int) -> UIColor {
    let colors = [UIColor(hue:0.588, saturation:0.804, brightness:0.341, alpha:1),
                  UIColor(hue:0.589, saturation:0.809, brightness:0.843, alpha:1),
                  UIColor(hue:0.588, saturation:0.807, brightness:0.592, alpha:1),
                  UIColor(hue:0.588, saturation:0.809, brightness:0.741, alpha:1)]
    return colors[index % colors.count]
}

extension String {
    func magic(_ magicIndex: Int) -> String {
        if magicIndex < self.count {
            let i = index(startIndex, offsetBy: magicIndex)
            return String(self[PartialRangeUpTo(i)])
        } else {
            return padding(toLength: magicIndex, withPad: "!", startingAt: 0)
        }
    }
}
