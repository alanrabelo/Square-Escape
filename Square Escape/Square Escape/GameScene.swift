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
    var numberOfSquares = 50
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
    var initialPosition : SKSpriteNode!
    var fringe = Stack<Node>()
    var squareCenters : [CGPoint]!
    var tempLineNodes = [SKShapeNode]()
    
    override func sceneDidLoad() {
        // -200 is added for a safety distance to initial and final positions
        self.width = self.size.width - 200
        self.heigth = self.size.height - 200
        self.addSquares(withCount: self.numberOfSquares)
    }
    
    public func sortFringe() {
        
        fringe.array.sort { (node1, node2) -> Bool in
            let distance1 = pow(node1.state.x - finalPosition.x, 2) + pow(node1.state.y - finalPosition.y, 2) + node1.fullCost()
            let distance2 = pow(node2.state.x - finalPosition.x, 2) + pow(node2.state.y - finalPosition.y, 2) + node2.fullCost()
            return distance1 < distance2
        }
        
    }
    
    func addSquares(withCount count : Int) {
        
        if !squareNodes.isEmpty {
            return
        }
        
        self.squareNodes.removeAll()
        self.squareCenters = [CGPoint]()
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
            self.squareCenters.append(position)
            let vertices = [CGPoint(x: colorSprite.position.x - self.sizeOfSquares/2, y: colorSprite.position.y - self.sizeOfSquares/2), CGPoint(x: colorSprite.position.x + self.sizeOfSquares/2, y: colorSprite.position.y - self.sizeOfSquares/2), CGPoint(x: colorSprite.position.x - self.sizeOfSquares/2, y: colorSprite.position.y + self.sizeOfSquares/2), CGPoint(x: colorSprite.position.x + self.sizeOfSquares/2, y: colorSprite.position.y + self.sizeOfSquares/2)]
            
            self.vertices.append(contentsOf: vertices)
            
            //            colorSprite.run(SKAction.fadeIn(withDuration: 2))
            self.addChild(colorSprite)
            self.squareNodes.append(colorSprite)
        }
        
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
    
    var found = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if found {
            self.gameViewController.displayWonView(false)
            found = false
            return
        }
        
        
        let initialNode = ANode(withPosition: self.initialPosition.position, andDistanceToFinal: self.initialPosition.position.distance(toPoint: self.finalPosition))
        let finalNode = ANode(withPosition: self.finalPosition, andDistanceToFinal: 0)
        let astar = AStar(withInitialPosition: initialNode, andFinalPosition: finalNode)
        astar.width = self.width
        astar.heigth = self.heigth
        astar.vertices = self.vertices
        astar.sizeOfSquares = self.sizeOfSquares
        astar.squareCenters = self.squareCenters
        
        let path = astar.findPath()
        
        print(path)
        
        for node in tempLineNodes {
            node.removeFromParent()
        }
        
        tempLineNodes.removeAll()
        self.clearPaths()
        
        self.getAllPath(point: path.first!)
        
        found = true
        


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
    
    func getAllPath(point: ANode){
        
        if point.parent != nil {
            
            let path = CGMutablePath()
            path.move(to: point.position)
            path.addLine(to: point.parent!.position)
            
            let shape = SKShapeNode()
            shape.path = path
            shape.strokeColor = UIColor.blue
            shape.lineWidth = 5
            addChild(shape)
            //selectedDestinations.append(destination)
            self.tempLineNodes.append(shape)
            getAllPath(point: point.parent!)
        }
    }
    
    func getRandomPosition() -> CGPoint {
        return CGPoint(x: (CGFloat(arc4random_uniform(UInt32(self.width))) - (self.width / 2)), y: (CGFloat(arc4random_uniform(UInt32(self.heigth))) - self.heigth / 2))
    }

}

extension CGPoint {
    func distance(toPoint p:CGPoint) -> CGFloat {
        return sqrt(pow((p.x - x), 2) + pow((p.y - y), 2))
    }
}
