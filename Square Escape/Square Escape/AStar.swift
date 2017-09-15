//
//  AStar.swift
//  Square Escape
//
//  Created by Alan Rabelo Martins on 15/09/17.
//  Copyright © 2017 alanrabelo. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class ANode {
    
    var parent : ANode?
    var distanceToFinal, cost : CGFloat
    var position : CGPoint
    var totalCostValue : CGFloat = 0
    
    init(withPosition position : CGPoint, andDistanceToFinal distanceToFinal : CGFloat, andCost cost : CGFloat = 0) {
        
        self.position = position
        self.distanceToFinal = distanceToFinal
        self.cost = cost
        
    }
    
    func summedCost() -> CGFloat {
        return self.cost + self.totalCost()
    }
    
    func totalCost() -> CGFloat {
        
        if self.totalCostValue != 0 {
            return self.totalCostValue
        }
        
        guard let parent = self.parent else {
            return 0
        }
       
        return self.position.distance(toPoint: parent.position) + parent.totalCost()
        
    }
  
    
    func sucessors() -> [ANode] {
        
        let nextNodes = [ANode]()
        
        return nextNodes.map({ (node) -> ANode in
            
            node.parent = self
            return node
            
        })
    }
    
    
    
    func isObjective(node : ANode) -> Bool {
        return node.position == self.position
    }
    
}

class AStar {
    
    var nodes = [ANode]()
    
    var vertices : [CGPoint]!
    var squareCenters : [CGPoint]!
    var sizeOfSquares : CGFloat!
    
    var initialPosition, finalPosition : ANode
    
    var width, heigth : CGFloat!
    
    init(withInitialPosition initialPosition : ANode, andFinalPosition finalPosition : ANode) {
        self.initialPosition = initialPosition
        self.finalPosition = finalPosition
    }

    
    var fringe = Stack<ANode>()
    
    
    
    func findPath() -> [ANode] {
        
        self.fringe.enqueue(self.sucessor(ofPoint: initialPosition))
        
        self.fringe.array.sort { (node1, node2) -> Bool in
            return node1.cost + node1.distanceToFinal < node2.cost + node2.distanceToFinal
        }
        
        while fringe.count != 0 {
            
            fringe.array.sort(by: { (node1, node2) -> Bool in
                return node1.distanceToFinal + node1.totalCost() < node2.distanceToFinal + node2.totalCost()
            })
            
            if let selectedNode = self.fringe.dequeue() {
                // Verifica se o nó é objetivo para procurar algum outro nó com valor menor que ele
                
                if selectedNode.isObjective(node: self.finalPosition) {
                    
                        var currentNode : ANode? = selectedNode
                        var path = [ANode]()
                        
                        while currentNode != nil {
                            path.append(currentNode!)
                            currentNode = currentNode!.parent
                        }
                        
                        print("Found with cost \(selectedNode.totalCost())")

                        return path
                        
                        

                } else {
                    self.fringe.enqueue(self.sucessor(ofPoint: selectedNode))
                }
                
            }
            
        }
        
        
        return [ANode]()
    }
    
    func sucessor(ofPoint newPoint : ANode) -> [ANode] {
        var nodes = [ANode]()
        // Removing all nodes in an array of all lines drawn
        
        for destination in self.vertices {
            
            var intersections = [CGPoint]()
            
            
            for square in squareCenters {
                
                let point1 = CGPoint(x: square.x - self.sizeOfSquares/2, y: square.y - self.sizeOfSquares/2)
                let point2 = CGPoint(x: square.x + self.sizeOfSquares/2, y: square.y - self.sizeOfSquares/2)
                let point3 = CGPoint(x: square.x - self.sizeOfSquares/2, y: square.y + self.sizeOfSquares/2)
                let point4 = CGPoint(x: square.x + self.sizeOfSquares/2, y: square.y + self.sizeOfSquares/2)
                
                let squareLines = [(point1, point2), (point2, point3), (point3, point4), (point4, point1)]
                
                for line in squareLines {
                    
                    let intersection = getIntersectionOfLines(line1: (newPoint.position, destination), line2: line)
                    
                    if intersection != CGPoint.zero {
                        
                        if !intersections.contains(intersection) {
                            intersections.append(intersection)
                        }
                    }
                }
                
            }
            
            if (intersections.count <= 1 && self.initialPosition.position == newPoint.position && self.finalPosition.position != destination) || (intersections.count <= 2 && self.initialPosition.position != newPoint.position && self.finalPosition.position != newPoint.position) && !(destination == self.finalPosition.position && intersections.count == 2) {
                if destination != newPoint.position {
                    
                    let nodeToBeAdded = ANode(withPosition: destination, andDistanceToFinal: destination.distance(toPoint: self.finalPosition.position))
                    nodeToBeAdded.parent = newPoint
                    nodeToBeAdded.cost = newPoint.position.distance(toPoint: nodeToBeAdded.position)
                    nodes.append(nodeToBeAdded)
                    
                }
            }
            
        }
        
        return nodes
        
    }

    
    func getIntersectionOfLines(line1: (a: CGPoint, b: CGPoint), line2: (a: CGPoint, b: CGPoint)) -> CGPoint {
        
        let line1Translated = (a: CGPoint(x: line1.a.x + (self.width / 2), y: line1.a.y + (self.heigth / 2)),
                               b: CGPoint(x: line1.b.x + (self.width / 2), y: line1.b.y + (self.heigth / 2)))
        
        let line2Translated = (a: CGPoint(x: line2.a.x + (self.width / 2), y: line2.a.y + (self.heigth / 2)),
                               b: CGPoint(x: line2.b.x + (self.width / 2), y: line2.b.y + (self.heigth / 2)))
        
        let distance = (line1Translated.b.x - line1Translated.a.x) * (line2Translated.b.y - line2Translated.a.y) - (line1Translated.b.y - line1Translated.a.y) * (line2Translated.b.x - line2Translated.a.x)
        if distance == 0 {
            return CGPoint.zero
        }
        
        let u = ((line2Translated.a.x - line1Translated.a.x) * (line2Translated.b.y - line2Translated.a.y) - (line2Translated.a.y - line1Translated.a.y) * (line2Translated.b.x - line2Translated.a.x)) / distance
        let v = ((line2Translated.a.x - line1Translated.a.x) * (line1Translated.b.y - line1Translated.a.y) - (line2Translated.a.y - line1Translated.a.y) * (line1Translated.b.x - line1Translated.a.x)) / distance
        
        if (u < 0.0 || u > 1.0) {
            return CGPoint.zero
        }
        if (v < 0.0 || v > 1.0) {
            return CGPoint.zero
        }
        
        return CGPoint(x: line1Translated.a.x + u * (line1Translated.b.x - line1Translated.a.x), y: line1Translated.a.y + u * (line1Translated.b.y - line1Translated.a.y))
    }
    
    func getRandomPosition() -> CGPoint {
        return CGPoint(x: (CGFloat(arc4random_uniform(UInt32(self.width))) - (self.width / 2)), y: (CGFloat(arc4random_uniform(UInt32(self.heigth))) - self.heigth / 2))
    }

    
}
