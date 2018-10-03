//
//  TestBrokenViewController.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 22.09.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit
import Voronoi

class TestBrokenViewController: UIViewController {

    let voronoi = Voronoi()
    
    @IBOutlet var brokeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTap(tap: UITapGestureRecognizer) {
        let p = tap.location(in: self.view)
        let custView = self.view as! CustomView
        
        if brokeSwitch.isOn {
            custView.geneareBorenWindow(fromPoint: p)
        } else if !custView.points.contains(p) {
            custView.points.append(p)
        }
    }
    
    @IBAction func onRefresh() {
        (self.view as! CustomView).pointsUpdated()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
