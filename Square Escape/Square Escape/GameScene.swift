//
//  GameScene.swift
//  Square Escape
//
//  Created by Alan Rabelo Martins on 04/09/17.
//  Copyright © 2017 alanrabelo. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var numberOfSquares = 8
    let sizeOfSquaresMinor : CGFloat = 49

    let sizeOfSquares : CGFloat = 50
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var squareNodes = [SKSpriteNode]()
    var width, heigth, startHeight, finalHeight : CGFloat!
    var vertices = [CGPoint]()
    var finalPosition : CGPoint!
    
    override func sceneDidLoad() {

        
        self.width = self.size.width - 100
        self.heigth = self.size.height - 100
        self.startHeight = CGFloat(arc4random_uniform((UInt32(self.heigth - self.heigth/2))))
        self.finalHeight = CGFloat(arc4random_uniform((UInt32(self.heigth - self.heigth/2))))
        self.finalPosition = CGPoint(x: self.width/2, y: finalHeight)
        self.lastUpdateTime = 0
        
        let initialPosition = SKSpriteNode(color: .blue, size: CGSize.init(width: sizeOfSquaresMinor/2, height: sizeOfSquaresMinor/2))
        initialPosition.position = CGPoint(x: -self.width / 2, y: startHeight)
        self.addChild(initialPosition)
        
        let finalPosition = SKSpriteNode(color: .blue, size: CGSize.init(width: sizeOfSquaresMinor/2, height: sizeOfSquaresMinor/2))
        finalPosition.position = CGPoint(x: self.width / 2, y: finalHeight)
        self.addChild(finalPosition)

        
        
        //Generating random sprites
        for _ in 0..<numberOfSquares {
            let colorSprite = SKSpriteNode(color: .red, size: CGSize.init(width: sizeOfSquaresMinor, height: sizeOfSquaresMinor))
            
            var position : CGPoint = getRandomPosition()
            
            while !self.squareNodes.filter({ (node) -> Bool in
                let currentX = position.x + self.width / 2
                let currentY = position.y + self.heigth / 2
                
                let differenceX = abs((node.position.x + self.width / 2) - currentX)
                let differenceY = abs((node.position.y + self.heigth / 2) - currentY)
                
                return (differenceX > sizeOfSquares && differenceY > sizeOfSquares) ? false : true
                
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
        
        self.sucessor(ofPoint: initialPosition.position)
        
        
    
    }
    
    func sucessor(ofPoint point : CGPoint) -> CGPoint {
        
        for square in self.squareNodes {
            
            let vertices = [
                CGPoint(x: square.position.x - self.sizeOfSquares/2, y: square.position.y - self.sizeOfSquares/2),
                CGPoint(x: square.position.x + self.sizeOfSquares/2, y: square.position.y - self.sizeOfSquares/2),
                CGPoint(x: square.position.x - self.sizeOfSquares/2, y: square.position.y + self.sizeOfSquares/2),
                CGPoint(x: square.position.x + self.sizeOfSquares/2, y: square.position.y + self.sizeOfSquares/2)]
            
            for newPoint in vertices {
                
                let path = CGMutablePath()
                path.move(to: point)
                path.addLine(to: newPoint)
                
                let shape = SKShapeNode()
                shape.path = path
                shape.strokeColor = UIColor.red
                shape.lineWidth = 1
                
                let intersectionSquares = self.squareNodes.filter({ (node) -> Bool in
                    return node.intersects(SKShapeNode(path: path))
                })
                
                if intersectionSquares.isEmpty {
                    shape.zPosition = 99
                    self.addChild(shape)
                }
                

                
            }
        }
        
//        for newPoint in self.vertices {
//            
//            
//            let intersectionSquares = self.squareNodes.filter({ (node) -> Bool in
//                
//                
//                
//            })
//                
//            if intersectionSquares.count <= 0 {
//               
//            } else {
//                
////                if intersectionSquares.count == 1 {
////                    shape.strokeColor = .yellow
////                } else if intersectionSquares.count == 2 {
////                    shape.strokeColor = .cyan
////                } else if intersectionSquares.count >= 3 {
////                    shape.strokeColor = .blue
////                }
////                shape.zPosition = -1
////                self.addChild(shape)
//
//            }
//
//            
//            
//        }
//        
//        
//        
        return CGPoint(x: 500, y: 500)

    }
    
    func getRandomPosition() -> CGPoint {
        return CGPoint(x: CGFloat(arc4random_uniform(UInt32(self.width))) - self.width / 2, y: CGFloat(arc4random_uniform(UInt32(self.heigth))) - self.heigth / 2)
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
