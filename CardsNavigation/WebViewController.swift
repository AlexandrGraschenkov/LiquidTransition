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
    
    
    
    var urlToLoad: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        web = WKWebView(frame: view.bounds.inset(top: 20, bottom: toolbar.bounds.height))
        web.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(web)
        
        if let url = urlToLoad {
            web.load(URLRequest(url: url))
        }
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
