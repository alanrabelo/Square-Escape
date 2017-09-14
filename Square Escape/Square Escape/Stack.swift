//
//  Stack.swift
//  Tree Search
//
//  Created by Vitor Muniz on 07/09/17.
//  Copyright © 2017 alanrabelo. All rights reserved.
//

import Foundation

public struct Stack<T> {
    var array = [T]()
    
    public var count: Int {
        return array.count
    }
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public mutating func push(_ element: [T]) {
        array = element + array
    }
    
    public mutating func enqueue(_ element: [T]) {
        push(element)
    }
    
    public mutating func dequeue() -> T? {
        return pop()
    }
    
    public mutating func pop() -> T? {
        if isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }
    
    public var front: T? {
        return array.first
    }
}
