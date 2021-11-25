//
//  PhotosViewController.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 04.10.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit
import Liquid

private let reuseIdentifier = "PhotoCell"

class PhotosViewController: UICollectionViewController {

    var photos: [PhotoInfo] = [PhotoInfo(name: "img1"),
                               PhotoInfo(name: "img2"),
                               PhotoInfo(name: "img3"),
                               PhotoInfo(name: "img4"),
                               PhotoInfo(name: "img5"),
                               PhotoInfo(name: "img6"),
                               PhotoInfo(name: "img7")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let prefferedCellSize = floor((UIScreen.main.bounds.width - 10 * 4) / 3.0)
        let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.itemSize = CGSize(width: prefferedCellSize, height: prefferedCellSize)
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.delegate = Liquid.shared
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? PhotosDetailViewController {
            detailVC.photos = photos
            let idx = self.collectionView?.indexPathsForSelectedItems?.first?.row ?? 0
            detailVC.index = idx
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
    
        cell.display(photo: photos[indexPath.row])
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
