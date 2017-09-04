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
    
    var numberOfSquares = 10
    let sizeOfSquaresMinor : CGFloat = 15

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
    var initialPosition : SKSpriteNode!
    
    override func sceneDidLoad() {

        
        self.width = self.size.width - 100
        self.heigth = self.size.height - 100
        
        self.addSquares(withCount: self.numberOfSquares)

    }
    
    func addSquares(withCount count : Int) {
        
        self.squareNodes.removeAll()
        self.vertices.removeAll()
        for node in self.children {
            node.removeFromParent()
        }
        self.startHeight = CGFloat(arc4random_uniform((UInt32(self.heigth - self.heigth/2))))
        self.finalHeight = CGFloat(arc4random_uniform((UInt32(self.heigth - self.heigth/2))))
        self.finalPosition = CGPoint(x: self.width/2, y: finalHeight)
        self.lastUpdateTime = 0
        
        self.initialPosition = SKSpriteNode(color: .blue, size: CGSize.init(width: sizeOfSquaresMinor/2, height: sizeOfSquaresMinor/2))
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
        

            
            for newPoint in self.vertices {
                

                let path = UIBezierPath()
                    
                    //CGMutablePath()
                path.move(to: point)
                path.addLine(to: newPoint)
                
                let intersectionSquares = self.squareNodes.filter({ (node) -> Bool in
                    
                    var triangle = SKShapeNode()
                    triangle.path = path.cgPath
                    triangle.lineWidth = 2.0

                    
                    return node.intersects(triangle)
                })
                
                if !intersectionSquares.isEmpty {
                    print("from \(point) to \(newPoint) passes through \(intersectionSquares.first!.position)")
                    
                }
                
                if intersectionSquares.count <= 0 {
                    let shape = SKShapeNode()
                    shape.path = path.cgPath
                    shape.strokeColor = UIColor.red
                    shape.lineWidth = 1
                    shape.zPosition = 99
                    self.addChild(shape)
                } else {
                    let shape = SKShapeNode()
                    shape.path = path.cgPath
                    shape.strokeColor = UIColor.blue
                    shape.lineWidth = 1
                    shape.zPosition = -1
                    self.addChild(shape)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.addSquares(withCount: 10)
    }
    override func update(_ currentTime: TimeInterval) {
        

    }
}
