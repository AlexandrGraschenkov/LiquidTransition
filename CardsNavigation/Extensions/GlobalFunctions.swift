//
//  GlobalFunctions.swift
//  TestPlayerSwift
//
//  Created by Alexander Graschenkov on 13.08.17.
//  Copyright © 2017 Alex is the best. All rights reserved.
//

import UIKit

extension DispatchQueue {
    static var background: DispatchQueue { return DispatchQueue.global(qos: .background) }
}

public typealias Cancelable = ()->()

func delay(_ delay: Double,
           queue: DispatchQueue = DispatchQueue.main,
           closure:@escaping ()->()) {
    queue.asyncAfter(deadline: .now() + delay, execute: closure)
}

func performAsyncIn(_ queue: DispatchQueue,
                    closure: @escaping ()->()) {
    queue.async(execute: closure)
}

func performSyncIn(_ queue: DispatchQueue,
                   closure: @escaping ()->()) {
    queue.sync(execute: closure)
}

func performInMain(closure: @escaping ()->()) {
    if Thread.isMainThread {
        closure()
    } else {
        DispatchQueue.main.async(execute: closure)
    }
}

func performInBackground(closure: @escaping ()->()) {
    if Thread.isMainThread {
        DispatchQueue.background.async(execute: closure)
    } else {
        closure()
    }
}


fileprivate var _privateKeys = Set<String>()

func once(file: String = #file, line: Int = #line, col: Int = #column, _ code: ()->()) {
    let key = "\(file)|\(line)|\(col)"
    
    objc_sync_enter(DispatchQueue.main);
    defer { objc_sync_exit(DispatchQueue.main) }
    
    if _privateKeys.contains(key) {
        return
    }
    _privateKeys.insert(key)
    code()
}

