//
//  WebViewController.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 07.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var web: WKWebView!
    @IBOutlet weak var toolbar: UIView!
    @IBOutlet weak var testLabel: UILabel!
    
    
    
    var urlToLoad: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        web = WKWebView(frame: view.bounds.inset(top: 20, bottom: toolbar.bounds.height))
        web.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(web)
        
        if let url = urlToLoad {
            web.load(URLRequest(url: url))
        }
        view.bringSubview(toFront: testLabel)
        
        let pan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(onEdgePan(pan:)))
        pan.edges = .left
        view.addGestureRecognizer(pan)
    }
    
    func loadURL(url: URL) {
        if (isViewLoaded) {
            web.load(URLRequest(url: url))
        } else {
            urlToLoad = url
        }
    }

    @IBAction func prevPagePressed() {
        web.goBack()
    }
    
    @IBAction func nextPagePressed() {
        web.goForward()
    }
    
    @IBAction func showCards() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func testFunc() {
        toolbar.layer.masksToBounds = true
        _ = DisplayLinkAnimator.animate(duration: 2.0) { (progress) in
            self.toolbar.layer.cornerRadius = 20.0 * progress
        }
    }
    
    @objc func onEdgePan(pan: UIScreenEdgePanGestureRecognizer) {
        switch pan.state {
        case .began:
            self.dismiss(animated: true, completion: nil)
        case .changed:
            let v = view.superview!
            let translation = pan.translation(in: v)
            let progress = max(0, min(1, translation.x / 150.0))
            print(progress)
            let pos = pan.location(in: v)
            testLabel.center = pos
            LiquidTransition.shared.update(progress: progress)
        case .ended:
            LiquidTransition.shared.finish()
        default:
            break
        }
    }

}

extension WebViewController: CardControllerProtocol {
    
    func getState() -> Codable? {
        return nil
    }
    
    func restoreFromState(state: Codable) {
        
    }
    func getContentView() -> UIView {
        return web
    }
    
    func getToolbarView() -> UIView? {
        return toolbar
    }
}
