//
//  PhotoPreviewController.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 06.10.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit



class PhotoPreviewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var index: Int = 0
    var photo: PhotoInfo!
    
    static func controller(photo: PhotoInfo, index: Int) -> PhotoPreviewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PhotoPreviewController") as! PhotoPreviewController
        controller.photo = photo
        controller.index = index
        
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        indicator.startAnimating()
        DispatchQueue.global().async {
            // preload image to remove decoding im main thread
            if let img = UIImage(named: self.photo.assetName)?.preloadedImage() {
                DispatchQueue.main.async {
                    self.imageView.image = img
                    self.indicator.stopAnimating()
                }
            }
        }
    }

}
