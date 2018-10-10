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
