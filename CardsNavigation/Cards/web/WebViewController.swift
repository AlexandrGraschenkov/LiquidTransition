//
//  WebViewController.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 07.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit
import WebKit
import Liquid

class WebViewController: UIViewController {
    
    var web: WKWebView!
    @IBOutlet weak var statusBarView: UIView!
    @IBOutlet weak var toolbar: UIView!
    
    
    
    var urlToLoad: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *), let statusHeight = UIApplication.shared.keyWindow?.safeAreaInsets.top {
            statusBarView.frame.size.height = statusHeight
        }
        web = WKWebView(frame: view.bounds.inset(top: statusBarView.frame.size.height, bottom: toolbar.bounds.height))
        web.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(web)
        
        if let url = urlToLoad {
            web.load(URLRequest(url: url))
        }
        
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
    
    @objc func onEdgePan(pan: UIScreenEdgePanGestureRecognizer) {
        switch pan.state {
        case .began:
            self.dismiss(animated: true, completion: nil)
        case .changed:
            let v = view.superview!
            let translation = pan.translation(in: v)
            let progress = max(0, min(1, translation.x / 150.0))
            print(progress)
//            _ = pan.location(in: v)
            Liquid.shared.update(progress: progress)
        case .ended:
            Liquid.shared.complete()
        default:
            break
        }
    }

}

extension WebViewController {
    func getContentView() -> UIView {
        return web
    }
    
    func getToolbarView() -> UIView {
        return toolbar
    }
    
    func getStatusView() -> UIView {
        return statusBarView
    }
}
