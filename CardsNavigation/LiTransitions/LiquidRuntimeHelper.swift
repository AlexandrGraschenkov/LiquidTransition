//
//  LiquidRuntimeHelper.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 29.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

class LiquidRuntimeHelper {
    
    private init() {
    }
    
    static func isSubclass(_ subclass: AnyClass!, superclass: AnyClass!) -> Bool {
        
        guard let superclass = superclass else {
            return false
        }
        
        var eachSubclass: AnyClass! = subclass
        
        while let eachSuperclass: AnyClass = class_getSuperclass(eachSubclass) {
            /* Use ObjectIdentifier instead of `===` to make identity test.
             Because some types cannot respond to `===`, like WKObject in WebKit framework. */
            if ObjectIdentifier(eachSuperclass) == ObjectIdentifier(superclass) {
                return true
            }
            eachSubclass = eachSuperclass
        }
        
        return false
    }
    
    static func subclases(prefix: String) -> [AnyClass] {
        var result = [AnyClass]()
        
        let count: Int32 = objc_getClassList(nil, 0)
        
        guard count > 0 else {
            return result
        }
        
        let classes = UnsafeMutablePointer<AnyClass>.allocate(capacity: Int(count))
        
        defer {
            classes.deallocate()
        }
        
        let buffer = AutoreleasingUnsafeMutablePointer<AnyClass>(classes)
        
        for i in 0..<Int(objc_getClassList(buffer, count)) {
            guard let superClass = class_getSuperclass(classes[i]) else { continue }
            if String(describing: superClass).hasPrefix(prefix) {
                result.append(classes[i])
            }
        }
        
        return result
    }
    
    static func subclasses(_ baseclass: AnyClass!) -> [AnyClass] {
        var result = [AnyClass]()
        
        guard let baseclass = baseclass else {
            return result
        }
        
        let count: Int32 = objc_getClassList(nil, 0)
        
        guard count > 0 else {
            return result
        }
        
        let classes = UnsafeMutablePointer<AnyClass>.allocate(capacity: Int(count))
        
        defer {
            classes.deallocate()
        }
        
        let buffer = AutoreleasingUnsafeMutablePointer<AnyClass>(classes)
        
        for i in 0..<Int(objc_getClassList(buffer, count)) {
            let someclass: AnyClass = classes[i]
            print(someclass)
//            if let kkk = class_getSuperclass(someclass) {
//                print(kkk)
//            }
            if isSubclass(someclass, superclass: baseclass) {
                result.append(someclass)
            }
        }
        
        return result
    }
    
    static func addOrReplaceMethod(class tClass: AnyClass, original: Selector, swizzled: Selector) {
        guard let swizzledMethod = class_getInstanceMethod(tClass, swizzled) else { return }
        
        let isMethodExists: Bool = !class_addMethod(tClass, original, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if isMethodExists {
            if let originalMethod = class_getInstanceMethod(tClass, original) {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    }
}
