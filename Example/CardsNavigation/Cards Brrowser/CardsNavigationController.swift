//
//  CardsNavigationController.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 07.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit



class CardsNavigationController: UIViewController {

    var cards: [CardInfo] = []
    var lastOpenedCardIdx: Int = -1
    var scaleDown: CGFloat = 0.7
    var layout: CenteredCollectionViewFlowLayout!
    var selectedIndex = IndexPath(row: 0, section: 0)
    @IBOutlet var collection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        transitioningDelegate = self
        layout = collection.collectionViewLayout as? CenteredCollectionViewFlowLayout
        layout.itemSize = CGSize(
            width: view.bounds.width * scaleDown,
            height: view.bounds.height * scaleDown * 0.9
        )
        layout.minimumLineSpacing = 20
        layout.scrollDirection = .horizontal
        
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (lastOpenedCardIdx >= 0) {
            let idx = lastOpenedCardIdx
            if let img = cards[idx].controller?.getContentView().snapshotImage(scale: scaleDown) {
                self.updateSnapshot(idx: idx, img: img)
            }
            
            lastOpenedCardIdx = -1
        }
    }
    
    @IBAction func closePressed() {
        dismiss(animated: true, completion: nil)
    }
    
    func addNewPage() {
        let vc = WebViewController()
//        vc.transitioningDelegate = self
        let url = URL(string: "https://ya.ru/")!
        vc.loadURL(url: url)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true) {
            self.collection.insertItems(at: [IndexPath(item: self.cards.count, section: 0)])
        }
        
        let newInfo = CardInfo(snapshot: nil, controller: vc)
        cards.append(newInfo)
        lastOpenedCardIdx = cards.count-1
    }
    
    func openPage() {
        lastOpenedCardIdx = selectedIndex.item
        if let vc = cards[lastOpenedCardIdx].controller {
//            vc.transitioningDelegate = self
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
    }
    
    func updateSnapshot(idx: Int, img: UIImage) {
        self.cards[idx].snapshot = img
        self.collection.reloadItems(at: [IndexPath(row: idx, section: 0)])
    }
    
    func getTransitionCell() -> UIView {
        if let cell = collection.cellForItem(at: selectedIndex) {
            return cell.contentView
        } else if collection.visibleCells.count > 0 {
            let cells = collection.visibleCells
            return cells[cells.count / 2].contentView
        } else {
            let layouts = collection.collectionViewLayout.layoutAttributesForElements(in: collection.bounds)
            var frame = CGRect.zero
            for l in layouts ?? [] {
                if l.indexPath == selectedIndex {
                    frame = l.frame
                }
            }
            if frame == CGRect.zero {
                frame = collection.subviews.first?.frame ?? CGRect.zero
            }
            frame = view.convert(frame, from: collection)
            let tempView = UIView(frame: frame)
            view.addSubview(tempView)
            DispatchQueue.main.async {
                tempView.removeFromSuperview()
            }
            return tempView
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let dst = segue.destination as? WebViewController {
//            dst.transitioningDelegate = self
//        }
    }
}

extension CardsNavigationController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == cards.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddNew", for: indexPath)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Page", for: indexPath) as! CardItemCell
        cell.imageView.image = cards[indexPath.row].snapshot
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        print("Current centered index: \(String(describing: centeredCollectionViewFlowLayout.currentCenteredPage ?? nil))")
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        print("Current centered index: \(String(describing: centeredCollectionViewFlowLayout.currentCenteredPage ?? nil))")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected Cell #\(indexPath.row)")
        selectedIndex = indexPath
        if indexPath.row == cards.count {
            addNewPage()
            return
        }
        openPage()
    }
}
