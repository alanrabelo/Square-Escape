//
//  Stack.swift
//  Tree Search
//
//  Created by Vitor Muniz on 07/09/17.
//  Copyright © 2017 alanrabelo. All rights reserved.
//

import Foundation
import UIKit

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
    
    func dequeueMin() -> ANode? {
        
        if var array = self.array as? [ANode] {
            
            let minimumValue = array.min(by: { (node1, node2) -> Bool in
                return node1.distanceToFinal + node1.totalCost() < node2.distanceToFinal + node2.totalCost()
            })
            print("The current is: \(minimumValue?.position)")

            let minimum2 = (self.array as! [ANode]).sorted(by: { (node1, node2) -> Bool in
                return node1.distanceToFinal + node1.totalCost() < node2.distanceToFinal + node2.totalCost()
            })
            
            
            print("The correct should be: \(minimum2.first?.position)")
            
            array.remove(at: array.index(where: { (node) -> Bool in
                return node.position == (minimumValue?.position)!
            })!)
            
            
            
            
            return minimumValue
        }
        
        return nil
        
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
