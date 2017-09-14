//
//  GameScene.swift
//  Square Escape
//
//  Created by Alan Rabelo Martins on 04/09/17.
//  Copyright © 2017 alanrabelo. All rights reserved.
//

import SpriteKit
import GameplayKit
import ObjectiveC

class GameScene: SKScene {
    
    var gameViewController : GameViewController!
    var numberOfSquares = 80
    let sizeOfSquaresMinor : CGFloat = 39

    let sizeOfSquares : CGFloat = 40
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var squareNodes = [SKSpriteNode]()
    var width, heigth, startHeight, finalHeight : CGFloat!
    var vertices = [CGPoint]()
    var finalPosition : CGPoint!
    var initialPosition : SKSpriteNode!
    var fringe = Stack<Node>()
    var tempLineNodes = [SKShapeNode]()
    
    override func sceneDidLoad() {
        // -200 is added for a safety distance to initial and final positions
        self.width = self.size.width - 200
        self.heigth = self.size.height - 200
        self.addSquares(withCount: self.numberOfSquares)
    }
    
    func addSquares(withCount count : Int) {
        
        if !squareNodes.isEmpty {
            return
        }
        
        self.squareNodes.removeAll()
        self.vertices.removeAll()
        for node in self.children {
            node.removeFromParent()
        }
        self.startHeight = CGFloat(arc4random_uniform((UInt32(self.heigth - self.heigth/2))))
        self.finalHeight = CGFloat(arc4random_uniform((UInt32(self.heigth - self.heigth/2))))
        self.finalPosition = CGPoint(x: (self.width/2) + 50, y: finalHeight)
        self.vertices.append(self.finalPosition)
        
        print(self.finalPosition)

        self.lastUpdateTime = 0
        
        self.initialPosition = SKSpriteNode(color: .blue, size: CGSize.init(width: sizeOfSquaresMinor/2, height: sizeOfSquaresMinor/2))
        initialPosition.position = CGPoint(x: (-self.width / 2) - 50 , y: startHeight)

        
        let no = Node.init(state: initialPosition.position)
        
        self.fringe.enqueue([no])
        self.addChild(initialPosition)
        
        let finalPosition = SKSpriteNode(color: .blue, size: CGSize.init(width: sizeOfSquaresMinor/2, height: sizeOfSquaresMinor/2))
        finalPosition.position = self.finalPosition
        self.addChild(finalPosition)
        
        //Generating random sprites
        for _ in 0..<numberOfSquares {
            
            let colorSprite = SKSpriteNode(color: .red, size: CGSize.init(width: sizeOfSquaresMinor, height: sizeOfSquaresMinor))
            
            var position : CGPoint = getRandomPosition()
            
            while !self.squareNodes.filter({ (node) -> Bool in
                let currentX = position.x
                let currentY = position.y
                
                let differenceX = abs((node.position.x) - currentX)
                let differenceY = abs((node.position.y) - currentY)
                
                    //.distance(to: node.position) > sizeOfSquares
                return (differenceX > sizeOfSquares + 10 || differenceY > sizeOfSquares + 10) ? false : true
                
            }).isEmpty {
                
                position = getRandomPosition()
            }
            
            colorSprite.position = position
            
            let vertices = [CGPoint(x: colorSprite.position.x - self.sizeOfSquares/2, y: colorSprite.position.y - self.sizeOfSquares/2), CGPoint(x: colorSprite.position.x + self.sizeOfSquares/2, y: colorSprite.position.y - self.sizeOfSquares/2), CGPoint(x: colorSprite.position.x - self.sizeOfSquares/2, y: colorSprite.position.y + self.sizeOfSquares/2), CGPoint(x: colorSprite.position.x + self.sizeOfSquares/2, y: colorSprite.position.y + self.sizeOfSquares/2)]
            
            self.vertices.append(contentsOf: vertices)
            
            //            colorSprite.run(SKAction.fadeIn(withDuration: 2))
            self.addChild(colorSprite)
            self.squareNodes.append(colorSprite)
        }
        
    }
    
    func sucessor(ofPoint newPoint : Node) -> [Node] {
        
        // Removing all nodes in an array of all lines drawn
        for node in tempLineNodes {
            node.removeFromParent()
        }
        tempLineNodes.removeAll()
        
        var selectedDestinations = [CGPoint]()

        
        for var destination in self.vertices {
            
            var intersections = [CGPoint]()
            
            
            for square in squareNodes {
                
                let point1 = CGPoint(x: square.position.x - self.sizeOfSquares/2, y: square.position.y - self.sizeOfSquares/2)
                let point2 = CGPoint(x: square.position.x + self.sizeOfSquares/2, y: square.position.y - self.sizeOfSquares/2)
                let point3 = CGPoint(x: square.position.x - self.sizeOfSquares/2, y: square.position.y + self.sizeOfSquares/2)
                let point4 = CGPoint(x: square.position.x + self.sizeOfSquares/2, y: square.position.y + self.sizeOfSquares/2)
                
                let squareLines = [(point1, point2), (point2, point3), (point3, point4), (point4, point1)]
                
                for line in squareLines {
                    
                    let intersection = getIntersectionOfLines(line1: (newPoint.state, destination), line2: line)
                    
                    if intersection != CGPoint.zero {
                        
                        if !intersections.contains(intersection) {
                            intersections.append(intersection)
                        }
                    }
                }
                
            }
            
            if (intersections.count <= 1 && self.initialPosition.position == newPoint.state && self.finalPosition != destination) || (intersections.count <= 2 && self.initialPosition.position != newPoint.state && self.finalPosition != newPoint.state) && !(destination == self.finalPosition && intersections.count == 2) {
                let path = CGMutablePath()
                path.move(to: newPoint.state)
                path.addLine(to: destination)
                
                let shape = SKShapeNode()
                shape.path = path
                shape.strokeColor = UIColor.green
                shape.lineWidth = 2
                addChild(shape)
                selectedDestinations.append(destination)
                self.tempLineNodes.append(shape)
            }
            
        }
        
        let sortedDestinations = selectedDestinations.sorted(by: { (point1, point2) -> Bool in
            
            let distance1 = pow(point1.x - finalPosition.x, 2) + pow(point1.y - finalPosition.y, 2)
            let distance2 = pow(point2.x - finalPosition.x, 2) + pow(point2.y - finalPosition.y, 2)
            
            return distance1 < distance2
        })
        
        if sortedDestinations.first == self.finalPosition {
            print("You Found it")
        }
        var nodes = [Node]()
        
        for s in sortedDestinations{
            nodes.append(Node.init(state: s, father: newPoint, deep: newPoint.deep+1))
        }
        
        return nodes
        
    }
    
    func clearPaths() {
        for node in self.tempLineNodes {
            node.removeFromParent()
        }
        self.tempLineNodes.removeAll()
    }
    
    
    func restartScene() {
        self.vertices.removeAll()
        
        clearPaths()
        
        for _ in 0..<self.fringe.count {
            _ = self.fringe.dequeue()
        }
        
        self.addSquares(withCount: self.numberOfSquares)
        
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
    
    var found = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if found {
            self.gameViewController.displayWonView(false)
            found = false
        }
        
        if let currentPoint = fringe.dequeue() {
            if currentPoint.state == self.finalPosition{
                for node in tempLineNodes {
                    node.removeFromParent()
                }
                tempLineNodes.removeAll()
                
                self.clearPaths()

                found = true
                self.getAllPath(point: currentPoint)
                
            }else{
                fringe.enqueue(sucessor(ofPoint: currentPoint))
            }
            
        }

    }
    
    func getAllPath(point: Node){
        if point.father != nil {
            
            print(point)
            let path = CGMutablePath()
            path.move(to: point.state)
            path.addLine(to: point.father!.state)
            
            let shape = SKShapeNode()
            shape.path = path
            shape.strokeColor = UIColor.blue
            shape.lineWidth = 5
            addChild(shape)
            //selectedDestinations.append(destination)
            self.tempLineNodes.append(shape)
            getAllPath(point: point.father!)
        }
    }

}

extension CGPoint {
    func distance(toPoint p:CGPoint) -> CGFloat {
        return sqrt(pow((p.x - x), 2) + pow((p.y - y), 2))
    }
}
