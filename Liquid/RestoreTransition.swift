//
//  RestoreTransition.swift
//  Liquid
//
//  Created by Alexander Graschenkov on 10.09.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

/**
 Restore `view` state after transition
 # Example:
 ```
 let restore = RestoreTransition()
 restore.addRestore(imgView, label, view)
 restore.moveView(avatarView, to: containerView) // it helps move move view to another superview, and restore it when animation is finished
 restore.addRestore(imgView2, keyPaths: ["layer.cornerRadius"]) // **not works yet, only KVO** you can restore any custom property
 
 UIView.animate(withDuration: 0.2, animations: {
    avatarView.frame.center.y += 200;
    imgView.alpha = 0.0;
    imgView2.layer.cornerRadius = 30.0;
 }) { (_) in
    // restores start state for all added views
    restore.restore()
 }
 ```
 */
public class RestoreTransition: NSObject {
    
    public enum Fields {
        case transform, superview, alpha, frame, isHidden
    }
    
    /**
     - Parameter keyPaths: add custom keys restore for all added views (**Only KVO properties**)
     */
    public init(keyPaths: [String] = []) {
        self.keyPaths = []
    }
    
    /**
     Saves view state, and allow you to restore view state after changes
     - Parameter keyPaths: custom key path that saved for restore
     */
    public func addRestore(_ view: UIView, ignoreFields: [Fields]) {
//        let keyPaths = keyPaths + self.keyPaths
        var state = ViewState.generateWithView(view: view, keyPaths: keyPaths)
        state.ignoreFields = ignoreFields
        restoreViews.append(state)
    }
    
    public func addRestore(_ views: UIView...) {
        for v in views {
            let state = ViewState.generateWithView(view: v, keyPaths: keyPaths)
            restoreViews.append(state)
        }
    }
    
    public func addRestore(_ views: [UIView]) {
        for v in views {
            let state = ViewState.generateWithView(view: v, keyPaths: keyPaths)
            restoreViews.append(state)
        }
    }
    
    public func moveView(_ view: UIView, to container: UIView) {
        addRestore(view)
        let frame = view.convert(view.bounds, to: container)
        if view.frame != frame {
            view.frame = frame
        }
        container.addSubview(view)
    }
    
    /** Generates snapshot of the view and move it to another view (for animation or perform changes)
     
    View becomes hidden
    After restore snapshots will removed from superview
     */
    public func moveSnapshot(_ view: UIView, to container: UIView, afterScreenUpdates: Bool) -> UIView? {
        if view.isHidden { return nil }
        
        addRestore(view)
        let snapshot = view.snapshotView(afterScreenUpdates: afterScreenUpdates)
        snapshot?.frame = view.convert(view.bounds, to: container)
        if let snapshot = snapshot {
            container.addSubview(snapshot)
            removeViews.append(snapshot)
        }
        if afterScreenUpdates {
            performAsyncIn(.main, closure: {
                view.isHidden = true
            })
        } else {
            view.isHidden = true
        }
        return snapshot
    }
    
    public func restore() {
        for v in restoreViews {
            if v.superview == nil && !v.ignoreFields.contains(.superview) {
                v.view.removeFromSuperview()
                continue
            }
            
            if v.view.superview != v.superview && !v.ignoreFields.contains(.superview)  {
                v.superview?.addSubview(v.view)
            }
            if v.view.transform != v.transform && !v.ignoreFields.contains(.transform)  {
                v.view.transform = v.transform
            }
            
            if v.view.frame != v.frame && !v.ignoreFields.contains(.frame)  {
                v.view.frame = v.frame
            }
            if v.view.alpha != v.alpha && !v.ignoreFields.contains(.alpha)  {
                v.view.alpha = v.alpha
            }
            if v.view.isHidden != v.isHidden && !v.ignoreFields.contains(.isHidden)  {
                v.view.isHidden = v.isHidden
            }
            for (path, val) in v.keyPaths {
                v.view.setValue(val, forKey: path)
            }
        }
        for v in removeViews {
            v.removeFromSuperview()
        }
        restoreViews.removeAll()
    }
    // MARK: - private
    
    fileprivate var restoreViews: [ViewState] = []
    fileprivate var removeViews: [UIView] = []
    fileprivate var keyPaths: [String]
}


fileprivate struct ViewState {
    let view: UIView
    let alpha: CGFloat
    let frame: CGRect
    let transform: CGAffineTransform
    let superview: UIView?
    let isHidden: Bool
    var keyPaths: [String: Any?] = [:]
    var ignoreFields: [RestoreTransition.Fields] = []
    
    static func generateWithView(view: UIView, keyPaths: [String]) -> ViewState {
        var dic: [String: Any?] = [:]
        for path in keyPaths {
            dic[path] = view.value(forKeyPath: path)
        }
        return ViewState(view: view,
                         alpha: view.alpha,
                         frame: view.frame,
                         transform: view.transform,
                         superview: view.superview,
                         isHidden: view.isHidden,
                         keyPaths: dic,
                         ignoreFields: [])
    }
}
