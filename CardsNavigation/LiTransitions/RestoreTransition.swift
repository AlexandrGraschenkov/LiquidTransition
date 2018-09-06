//
//  RestoreTransition.swift
//  Salam
//
//  Created by Alexander on 27.03.17.
//
//

import UIKit


fileprivate struct ViewState {
    let view: UIView
    let alpha: CGFloat
    let frame: CGRect
    let transform: CGAffineTransform
    let superview: UIView?
    
    static func generateWithView(view: UIView) -> ViewState {
        return ViewState(view: view,
                         alpha: view.alpha,
                         frame: view.frame,
                         transform: view.transform,
                         superview: view.superview)
    }
}

public class RestoreTransition: NSObject {
    
    fileprivate var restoreViews: [ViewState] = []
    fileprivate var removeViews: [UIView] = []
    
    public func addRestore(_ views: UIView...) {
        for v in views {
            let state = ViewState.generateWithView(view: v)
            restoreViews.append(state)
        }
    }
    
    public func addRestore(_ views: [UIView]) {
        for v in views {
            let state = ViewState.generateWithView(view: v)
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
    
    public func moveSnapshot(_ view: UIView, to container: UIView, afterScreenUpdates: Bool) -> UIView? {
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
            if v.superview == nil {
                v.view.removeFromSuperview()
                continue
            }
            
            if v.superview != v.view.superview {
                v.superview?.addSubview(v.view)
            }
            if v.view.transform != v.transform {
                v.view.transform = v.transform
            }
            
            if v.view.frame != v.frame {
                v.view.frame = v.frame
            }
            if v.view.alpha != v.alpha {
                v.view.alpha = v.alpha
            }
            if v.view.isHidden {
                v.view.isHidden = false
            }
        }
        for v in removeViews {
            v.removeFromSuperview()
        }
        restoreViews.removeAll()
    }
}
