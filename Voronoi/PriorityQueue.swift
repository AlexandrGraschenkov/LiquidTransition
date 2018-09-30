//
//  PriorityQueue.swift
//  VGen
//
//  Created by Carl Wieland on 4/22/15.
//  Copyright (c) 2015 Carl Wieland. All rights reserved.
//

import Foundation
class PriorityQueue<T: Comparable>: CustomStringConvertible, MutableCollection {
    subscript(position: Int) -> T {
        get {
            return heap[position]
        }
        set(newValue) {
            heap[position] = newValue
        }
    }
    
    func index(after i: Int) -> Int {
        return i+1
    }
    
    private final var heap: [T] = []
    private let contrast: (T, T) -> Bool
    
    convenience init() {
        self.init(ascending: false, startingValues: [])
    }
    
    convenience init(ascending: Bool) {
        self.init(ascending: ascending, startingValues: [])
    }
    
    convenience init(startingValues: [T]) {
        self.init(ascending: false, startingValues: startingValues)
    }
    
    init(ascending: Bool, startingValues: [T]) {
        if ascending {
            contrast = {$0 > $1}
        } else {
            contrast = {$0 < $1}
        }
        
        for value in startingValues {
            push(value)
        }
    }
    
    /// How many elements are in the Priority Queue?
    var count: Int {
        return heap.count
    }
    
    /// Are there any elements in the Priority Queue?
    var isEmpty: Bool {
        return heap.isEmpty
    }
    
    /// Add a new element onto the Priority Queue. O(lg n)
    ///
    /// :param: element The element to be inserted into the Priority Queue.
    func push(_ element: T) {
        heap.append(element)
        swim((heap.count - 1))
    }
    
    /// Remove and return the element with the highest priority (or lowest if ascending). O(lg n)
    ///
    /// :returns: The element with the highest priority in the Priority Queue, or nil if the PriorityQueue is empty.
    func pop() -> T? {
        if heap.isEmpty {
            return nil;
        }
        heap.swapAt(0, (heap.count - 1))
        let temp: T = heap.removeLast()
        sink(0)
        
        return temp
    }
    
    /// Get a look at the current highest priority item, without removing it. O(1)
    ///
    /// :returns: The element with the highest priority in the PriorityQueue, or nil if the PriorityQueue is empty.
    func peek() -> T? {
        if heap.isEmpty {
            return nil;
        }
        return heap[0]
    }
    
    /// Eliminate all of the elements from the Priority Queue.
    func clear() {
        heap.removeAll(keepingCapacity: false)
    }
    
    // Based on example from Sedgewick p 316
    private func sink(_ index: Int) {
        var k: Int = index
        while (((2 * k) + 1) < heap.count) {
            var j: Int = (2 * k) + 1
            if j < (heap.count - 1) && contrast(heap[j], heap[(j + 1)]) {
                j += 1
            }
            if !contrast(heap[k], heap[j]) {
                break;
            }
            heap.swapAt(k, j)
            k = j
        }
    }
    
    // Based on example from Sedgewick p 316
    private func swim(_ index: Int) {
        var k: Int = index
        while k > 0 && contrast(heap[((k - 1) / 2)], heap[k]) {
            heap.swapAt(((k - 1) / 2), k)
            k = ((k - 1) / 2)
        }
    }
    
    //Implement Printable protocol
    var description: String {
        return heap.description
    }
    
    //Implement GeneratorType
    typealias Element = T
    func next() -> Element? {
        if let e = pop() {
            return e
        }
        return nil
    }
    
    //Implement SequenceType
    typealias Generator = PriorityQueue
    func generate() -> Generator {
        return self
    }
    
    //Implement CollectionType
    typealias Index = Int
    
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return count
    }
}
