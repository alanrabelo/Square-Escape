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
    static var numberOfSquares = 10
    let sizeOfSquaresMinor : CGFloat = 99
    let sizeOfSquares : CGFloat = 100
    
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
    var squareCenters : [CGPoint]!
    var tempLineNodes = [SKShapeNode]()
    var search = 0
    var count = 0
    var currentNode: ANode!
    var astarAux: AStar!
    let defaults = UserDefaults.standard
    var currentCost = 0.0
    static var machineCost = 0.0
    
    override func sceneDidLoad() {
        let stage = defaults.integer(forKey: "stage")
        self.count = stage
        //defaults.set(0, forKey: "stage")
        
        // -200 is added for a safety distance to initial and final positions
        self.width = self.size.width - 200
        self.heigth = self.size.height - 200
        GameViewController.setNumberSquares()
        self.addSquares(withCount: GameScene.numberOfSquares)
        
    }
    
    func addSquares(withCount count : Int) {
        
        if !squareNodes.isEmpty {
            return
        }
        
        self.squareNodes.removeAll()
        self.squareCenters = [CGPoint]()
        self.vertices.removeAll()
        for node in self.children where node.name != "background" {
            node.removeFromParent()
        }
        self.startHeight = CGFloat(arc4random_uniform((UInt32(self.heigth - self.heigth/2))))
        self.finalHeight = CGFloat(arc4random_uniform((UInt32(self.heigth - self.heigth/2))))
        self.finalPosition = CGPoint(x: (self.width/2) + 50, y: finalHeight)
        self.vertices.append(self.finalPosition)

        self.lastUpdateTime = 0
        
        self.initialPosition = SKSpriteNode(color: .blue, size: CGSize.init(width: sizeOfSquaresMinor/2, height: sizeOfSquaresMinor/2))
        initialPosition.position = CGPoint(x: (-self.width / 2) - 50 , y: startHeight)

        self.addChild(initialPosition)
        
        let finalPosition = SKSpriteNode(color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), size: CGSize.init(width: sizeOfSquaresMinor/2, height: sizeOfSquaresMinor/2))
        finalPosition.position = self.finalPosition
        self.addChild(finalPosition)
        
        for _ in 0..<GameScene.numberOfSquares {
            
            let colorSprite = SKSpriteNode(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), size: CGSize.init(width: sizeOfSquaresMinor, height: sizeOfSquaresMinor))
            
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
            self.addChild(colorSprite)
            self.squareNodes.append(colorSprite)
        }
        
        self.vertices.append(self.finalPosition)
        self.currentNode = ANode(withPosition: self.initialPosition.position, andDistanceToFinal: self.initialPosition.position.distance(toPoint: self.finalPosition))
        let finalNode = ANode(withPosition: self.finalPosition, andDistanceToFinal: 0)
        self.astarAux = AStar(withInitialPosition: self.currentNode, andFinalPosition: finalNode)
        self.astarAux.width = self.width
        self.astarAux.heigth = self.heigth
        self.astarAux.vertices = self.vertices
        self.astarAux.sizeOfSquares = self.sizeOfSquares
        self.astarAux.squareCenters = self.squareCenters
        
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
        
        self.addSquares(withCount: GameScene.numberOfSquares)
        
    }
    
    var found = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
        if found {
            found = false

            DispatchQueue.main.async {
                print(self.currentCost)
                self.gameViewController.displayWonView(false, machineCost: GameScene.machineCost, userCost: self.currentCost)
            }
            self.gameViewController.initializeGameScene()
            return
        }

    }
    var shapes = [SKShapeNode]()
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for node in self.shapes {
            node.removeFromParent()
        }
        self.shapes.removeAll()
        
        let tap = touches.first?.location(in: self)
        let path = CGMutablePath()
        path.move(to: self.currentNode.position)
        path.addLine(to: tap!)
        
        let shape = SKShapeNode()
        shape.path = path
        shape.strokeColor = UIColor.blue
        shape.lineWidth = 5
        addChild(shape)
        shapes.append(shape)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let sucessors = self.astarAux.sucessorPoint(ofPoint: self.currentNode)
        if let tap = touches.first?.location(in: self){
            
            
            let sortedSuc = sucessors.sorted(by: { (node1, node2) -> Bool in
                return node1.distance(toPoint: tap) < node2.distance(toPoint: tap)
            })
            
            
            for node in self.shapes {
                node.removeFromParent()
            }
            self.shapes.removeAll()
            
            let path = CGMutablePath()
            path.move(to: self.currentNode.position)
            
            if let suc = sortedSuc.first {
                path.addLine(to: suc)
                self.currentCost = self.currentCost + Double(self.currentNode.position.distance(toPoint: suc))
                let shape = SKShapeNode()
                shape.path = path
                shape.strokeColor = UIColor.blue
                shape.lineWidth = 5
                addChild(shape)
            }
            
            self.currentNode = ANode(withPosition: sortedSuc.first!, andDistanceToFinal: 0, andCost: 0)
            
            if self.currentNode.position == finalPosition{
                
                if found {
                    found = false
                    
                    DispatchQueue.main.async {
                        print(self.currentCost)
                        self.gameViewController.displayWonView(false, machineCost: GameScene.machineCost, userCost: self.currentCost)
                        
                    }
                    self.gameViewController.initializeGameScene()
                    return
                }
                
                self.generateTree()
                defaults.set(self.count+1, forKey: "stage")
                print(self.count)
                found = true
            }
            
        }
    }
    
    func generateTree() {
        
        let initialNode = ANode(withPosition: self.initialPosition.position, andDistanceToFinal: self.initialPosition.position.distance(toPoint: self.finalPosition))
        let finalNode = ANode(withPosition: self.finalPosition, andDistanceToFinal: 0)
        let astar = AStar(withInitialPosition: initialNode, andFinalPosition: finalNode)
        astar.width = self.width
        astar.heigth = self.heigth
        astar.vertices = self.vertices
        astar.sizeOfSquares = self.sizeOfSquares
        astar.squareCenters = self.squareCenters
        
        let path = astar.findPath(type: self.count%4)
        
        for node in tempLineNodes {
            node.removeFromParent()
        }
        
        tempLineNodes.removeAll()
        self.clearPaths()
        
        self.getAllPath(point: path.first!)
    }
    
    func getAllPath(point: ANode){
        
        if point.parent != nil {
            
            let path = CGMutablePath()
            path.move(to: point.position)
            path.addLine(to: point.parent!.position)
            
            let shape = SKShapeNode()
            shape.path = path
            shape.strokeColor = UIColor.green
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
