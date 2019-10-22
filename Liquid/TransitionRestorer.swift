//
//  TransitionRestorer.swift
//  Liquid
//
//  Created by Alexander Graschenkov on 10.09.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit


public protocol StateRestoreViewProtocol {
    func restore()
    func cloneAndSet(view: UIView?) -> StateRestoreViewProtocol
    func setObject(_ obj: UIView)
}

public final class SaveViewState<Value> : StateRestoreViewProtocol {
    public init(path: ReferenceWritableKeyPath<UIView, Value>) {
        self.keyPath = path
    }
    
    public func setObject(_ obj: UIView) {
        self.obj = obj
        self.value = obj[keyPath: keyPath]
    }
    
    public func restore() {
        if let obj = obj, let value = value {
            obj[keyPath: keyPath] = value
        }
    }
    
    public func cloneAndSet(view: UIView?) -> StateRestoreViewProtocol {
        let state = SaveViewState(path: keyPath)
        if let view = view {
            state.setObject(view)
        }
        return state
    }
    
    var obj: UIView? = nil
    var value: Value? = nil
    let keyPath: ReferenceWritableKeyPath<UIView, Value>
}

protocol RestoreProtocol {
    func restore()
}

class SaveState<Root, Value>: RestoreProtocol {
    init(_ obj: Root, keyPath: ReferenceWritableKeyPath<Root, Value>) {
        self.obj = obj
        self.val = obj[keyPath: keyPath]
        self.keyPath = keyPath
    }
    
    func restore() {
        obj[keyPath: keyPath] = val
    }
    
    let obj: Root
    let val: Value
    let keyPath: ReferenceWritableKeyPath<Root, Value>
}

/**
 Restore `view` state after transition
 # Example:
 ```
 let restorer = TransitionRestorer()
 restorer.addRestore(imgView, label, view)
 restorer.moveView(avatarView, to: containerView) // it helps move move view to another superview, and restore it when animation is finished
 restorer.addRestore(imgView2, keyPaths: [SaveViewState(path: \.layer.cornerRadius)]) // you can restore any custom property from UIView
 
 UIView.animate(withDuration: 0.2, animations: {
    avatarView.frame.center.y += 200;
    imgView.alpha = 0.0;
    imgView2.layer.cornerRadius = 30.0;
 }) { (_) in
    // restores start state for all added views
    restorer.restore()
 }
 ```
 */
public class TransitionRestorer: NSObject {
    
    public enum Fields {
        case transform, superview, alpha, frame, isHidden
    }
    
    /**
     - Parameter keyPaths: add custom keys restore for all added views (**Only KVO properties**)
     */
    public init(keyPaths: StateRestoreViewProtocol...) {
        self.keyPaths = keyPaths
    }
    
    public override init() {
        self.keyPaths = []
    }
    
    /**
     Saves view state, and allow you to restore view state after changes
     - Parameter keyPaths: custom key path that saved for restore
     */
    public func addRestore(_ view: UIView, ignoreFields: [Fields]) {
        restoreViews.append(ViewState.generateWithView(view: view,
                                                       keyPaths: keyPaths,
                                                       ignoreFields: ignoreFields))
    }
    
    public func addRestore(_ view: UIView, keyPaths: [StateRestoreViewProtocol], ignoreFields: [Fields] = []) {
        restoreViews.append(ViewState.generateWithView(view: view,
                                                       keyPaths: self.keyPaths + keyPaths,
                                                       ignoreFields: ignoreFields))
    }
    
    /**
     Save state only specific field and restores only this field
     */
    public func addRestoreKeyPath<Root, Value>(_ view: Root, keyPaths: ReferenceWritableKeyPath<Root, Value>...) {
        for k in keyPaths {
            customSavedValues.append(SaveState(view, keyPath: k))
        }
    }
    
    public func addRestore(_ views: UIView...) {
        for v in views {
            restoreViews.append(ViewState.generateWithView(view: v, keyPaths: keyPaths))
        }
    }
    
    public func addRestore(_ views: [UIView]) {
        for v in views {
            restoreViews.append(ViewState.generateWithView(view: v, keyPaths: keyPaths))
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
            DispatchQueue.main.async {
                view.isHidden = true
            }
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
            
            v.keyPaths.forEach({$0.restore()})
        }
        
        for v in removeViews {
            v.removeFromSuperview()
        }
        restoreViews.removeAll()
        
        for r in customSavedValues {
            r.restore()
        }
        customSavedValues.removeAll()
    }
    // MARK: - private
    
    fileprivate var restoreViews: [ViewState] = []
    fileprivate var removeViews: [UIView] = []
    fileprivate var keyPaths: [StateRestoreViewProtocol]
    fileprivate var customSavedValues: [RestoreProtocol] = []
}


fileprivate struct ViewState {
    let view: UIView
    let alpha: CGFloat
    let frame: CGRect
    let transform: CGAffineTransform
    let superview: UIView?
    let isHidden: Bool
    var keyPaths: [StateRestoreViewProtocol] = []
    var ignoreFields: [TransitionRestorer.Fields] = []
    
    static func generateWithView(view: UIView,
                                 keyPaths: [StateRestoreViewProtocol] = [],
                                 ignoreFields: [TransitionRestorer.Fields] = []) -> ViewState {
        return ViewState(view: view,
                         alpha: view.alpha,
                         frame: view.frame,
                         transform: view.transform,
                         superview: view.superview,
                         isHidden: view.isHidden,
                         keyPaths: keyPaths.map({$0.cloneAndSet(view: view)}),
                         ignoreFields: ignoreFields)
    }
}
