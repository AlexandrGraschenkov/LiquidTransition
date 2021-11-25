//
//  RootController.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 23.05.2021.
//  Copyright © 2021 Alex Development. All rights reserved.
//

import UIKit
import TouchVisualizer

class RootController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        UIApplication.shared.keyWindow?.swizzle()
//        Visualizer.start()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Root", style: .plain, target: nil, action: nil)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "github", let destVC = segue.destination as? UserDetailController {
            destVC.user = GUser(id: 964601, login: "AlexandrGraschenkov", avatar: URL(string: "https://avatars.githubusercontent.com/u/964601?v=4"))
        }
    }

}
