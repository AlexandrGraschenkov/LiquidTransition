//
//  Helpers.swift
//  Liquid
//
//  Created by Alexander Graschenkov on 10.10.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit

extension DispatchQueue {
    static var background: DispatchQueue { return DispatchQueue.global(qos: .background) }
}

public typealias Cancelable = ()->Void

func delay(_ delay: Double,
           queue: DispatchQueue = DispatchQueue.main,
           closure:@escaping ()->Void) {
    queue.asyncAfter(deadline: .now() + delay, execute: closure)
}

func performAsyncIn(_ queue: DispatchQueue,
                    closure: @escaping ()->Void) {
    queue.async(execute: closure)
}

func performSyncIn(_ queue: DispatchQueue,
                   closure: @escaping ()->Void) {
    queue.sync(execute: closure)
}

func performInMain(closure: @escaping ()->Void) {
    if Thread.isMainThread {
        closure()
    } else {
        DispatchQueue.main.async(execute: closure)
    }
}

func performInBackground(closure: @escaping ()->Void) {
    if Thread.isMainThread {
        DispatchQueue.background.async(execute: closure)
    } else {
        closure()
    }
}

private var _privateKeys = Set<String>()

func once(file: String = #file, line: Int = #line, col: Int = #column, _ code: ()->Void) {
    let key = "\(file)|\(line)|\(col)"

    objc_sync_enter(DispatchQueue.main)
    defer { objc_sync_exit(DispatchQueue.main) }

    if _privateKeys.contains(key) {
        return
    }
    _privateKeys.insert(key)
    code()
}
