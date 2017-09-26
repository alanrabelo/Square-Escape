//
//  GameViewController.swift
//  Square 3d
//
//  Created by Alan Rabelo Martins on 25/09/17.
//  Copyright © 2017 alanrabelo. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    var width : CGFloat!
    var heigth : CGFloat!
    var scene : SCNScene!
    
    static var numberOfSquares = 5
    let sizeOfSquaresMinor : Float = 1.9
    let sizeOfSquares : Float = 2
        
    private var lastUpdateTime : TimeInterval = 0
    private var squareNodes = [SCNNode]()
    var startHeight, finalHeight : CGFloat!
    var vertices = [CGPoint]()
    var finalPosition : CGPoint!
    var initialPosition : CGPoint!
    var squareCenters : [CGPoint]!
    var tempLineNodes = [SCNNode]()
    var search = 0
    var currentNode: ANode!
    var astarAux: AStar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        self.scene = SCNScene(named: "art.scnassets/ship.scn")!
        

        self.width = 40
        self.heigth = 25
        
//        // create and add a light to the scene
//        let lightNode = SCNNode()
//        lightNode.light = SCNLight()
//        lightNode.light!.type = .omni
//        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
//        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
//        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        // animate the 3d object
//        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // configure the view
        scnView.backgroundColor = UIColor.init(red: 135/255.0, green: 206/255.0, blue: 250/255.0, alpha: 1.0)
        scnView.allowsCameraControl = true
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        self.squareNodes.removeAll()
        self.vertices.removeAll()
        self.tempLineNodes.removeAll()
        
        self.addSquares(withCount: 10)
        
        
    }
    
    func addSquares(withCount count : Int) {
        
        if !squareNodes.isEmpty {
            return
        }
        
        self.squareNodes.removeAll()
        self.squareCenters = [CGPoint]()
        self.vertices.removeAll()
        for node in self.scene.rootNode.childNodes where node.name == "boxNode" {
            node.removeFromParentNode()
        }
        
        self.startHeight = CGFloat(arc4random_uniform((UInt32(self.heigth - self.heigth / 2))))
        self.initialPosition = CGPoint(x: (-self.width / 2), y: startHeight)
        self.finalHeight = CGFloat(arc4random_uniform((UInt32(self.heigth - self.heigth / 2))))
        self.finalPosition = CGPoint(x: (self.width / 2), y: finalHeight)
        self.vertices.append(self.finalPosition)
        
        self.lastUpdateTime = 0
    
        
        let initialPositionNode = SCNNode(geometry: SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0))
        initialPositionNode.position = SCNVector3Make(Float((-self.width / 2)), 0.5, Float(startHeight))
        
        
        let finalPositionNode = SCNNode(geometry: SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0))
        finalPositionNode.position = SCNVector3Make(Float((self.width / 2)), 0.5, Float(finalHeight))
        
        initialPositionNode.name = "boxNode"
        finalPositionNode.name = "boxNode"



        scene.rootNode.addChildNode(initialPositionNode)
        scene.rootNode.addChildNode(finalPositionNode)
        
        //Generating random sprites
        for _ in 0..<count {
            
            
            
            let boxNode = SCNNode(geometry: SCNBox(width: CGFloat(sizeOfSquaresMinor), height: CGFloat(sizeOfSquaresMinor), length: CGFloat(sizeOfSquaresMinor), chamferRadius: 0))
            boxNode.name = "boxNode"
            boxNode.castsShadow = true
            
            var position : CGPoint = getRandomPosition()
            
            while !self.squareNodes.filter({ (node) -> Bool in
                
                let currentX = position.x
                let currentY = position.y
                
                let differenceX = abs((node.position.x) - Float(currentX))
                let differenceY = abs((node.position.z) - Float(currentY))
                
                //.distance(to: node.position) > sizeOfSquares
                return (differenceX > sizeOfSquares + 2 || differenceY > sizeOfSquares + 2) ? false : true
                
            }).isEmpty {
                
                position = getRandomPosition()
            }
            
            boxNode.position = SCNVector3Make(Float(position.x), 0.5, Float(position.y))
            
            self.squareCenters.append(position)
            
            let vertices = [CGPoint(x: CGFloat(boxNode.position.x - self.sizeOfSquares/2), y: CGFloat(boxNode.position.z - self.sizeOfSquares/2)),
                            CGPoint(x: CGFloat(boxNode.position.x + self.sizeOfSquares/2), y: CGFloat(boxNode.position.z - self.sizeOfSquares/2)),
                            CGPoint(x: CGFloat(boxNode.position.x - self.sizeOfSquares/2), y: CGFloat(boxNode.position.z + self.sizeOfSquares/2)),
                            CGPoint(x: CGFloat(boxNode.position.x + self.sizeOfSquares/2), y: CGFloat(boxNode.position.z + self.sizeOfSquares/2))]
            
            self.vertices.append(contentsOf: vertices)
            
            
            self.scene.rootNode.addChildNode(boxNode)
            self.squareNodes.append(boxNode)
            
        }
        
        self.currentNode = ANode(withPosition: self.initialPosition, andDistanceToFinal: self.initialPosition.distance(toPoint: self.finalPosition))
        let finalNode = ANode(withPosition: self.finalPosition, andDistanceToFinal: 0)
        self.astarAux = AStar(withInitialPosition: self.currentNode, andFinalPosition: finalNode)
        self.astarAux.width = self.width
        self.astarAux.heigth = self.heigth
        self.astarAux.vertices = self.vertices
        self.astarAux.sizeOfSquares = CGFloat(self.sizeOfSquares)
        self.astarAux.squareCenters = self.squareCenters
        
    }
    
    var found = false

    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        if found {
            found = false
            self.viewDidLoad()
            return
        } else {
            self.generateTree()
            found = true
        }
    }
    
    func generateTree() {
        
        let initialNode = ANode(withPosition: self.initialPosition, andDistanceToFinal: self.initialPosition.distance(toPoint: self.finalPosition))
        let finalNode = ANode(withPosition: self.finalPosition, andDistanceToFinal: 0)
        let astar = AStar(withInitialPosition: initialNode, andFinalPosition: finalNode)
        astar.width = self.width
        astar.heigth = self.heigth
        astar.vertices = self.vertices
        astar.sizeOfSquares = CGFloat(self.sizeOfSquares)
        astar.squareCenters = self.squareCenters
        
        let path = astar.findPath(type: self.search)
        
        for node in tempLineNodes {
            node.removeFromParentNode()
        }
        

        
        tempLineNodes.removeAll()
        self.clearPaths()
        
        self.getAllPath(point: path.first!)

    }
    
    func clearPaths() {
        for node in self.tempLineNodes {
            node.removeFromParentNode()
        }
        self.tempLineNodes.removeAll()
    }
    
    
    func restartScene() {
        self.vertices.removeAll()
        
        clearPaths()
        
        self.addSquares(withCount: GameViewController.numberOfSquares)
        
    }
    
    
    func getAllPath(point: ANode){
        
        if point.parent != nil {
            
            let path = CGMutablePath()
            path.move(to: point.position)
            path.addLine(to: point.parent!.position)
            
            if let line = SCNGeometry.drawLine([point.position.asSCNVector3, point.parent!.position.asSCNVector3], color: .black) {
                self.tempLineNodes.append(line)
                self.scene.rootNode.addChildNode(line)
            }
            getAllPath(point: point.parent!)
        }
    }
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    func getRandomPosition() -> CGPoint {
        return CGPoint(
            x: (CGFloat(arc4random_uniform(10 * UInt32(self.width))) - 10 * (self.width / 2)) / 10,
            y: (CGFloat(arc4random_uniform(10 * UInt32(self.heigth))) - 10 * (self.heigth / 2)) / 10)
    }
    
}

extension CGPoint {
    func distance(toPoint p:CGPoint) -> CGFloat {
        return sqrt(pow((p.x - x), 2) + pow((p.y - y), 2))
    }
}

extension CGPoint {
    var asSCNVector3 : SCNVector3 {
        return SCNVector3Make(Float(self.x), 1, Float(self.y))
    }
}

extension SCNGeometry {
    
    static func drawLine(_ verts : [SCNVector3], color : UIColor) -> SCNNode? {
        
        if verts.count < 2 { return nil }
        
        let src = SCNGeometrySource(vertices: verts)
        var indexes: [CInt] = []
        
        for i in 0...verts.count - 1 {
            indexes.append(contentsOf: [CInt(i), CInt(i + 1)])
        }
        
        let dat  = NSData(
            bytes: indexes,
            length: MemoryLayout<CInt>.size * indexes.count
        )
        
        let ele = SCNGeometryElement(
            data: dat as Data,
            primitiveType: .line,
            primitiveCount: verts.count - 1,
            bytesPerIndex: MemoryLayout<CInt>.size
        )
        
        ele.pointSize = 5
        
        let line = SCNGeometry(sources: [src], elements: [ele])
        
        let node = SCNNode(geometry: line)
        
        line.materials.first?.lightingModel = .blinn
        line.materials.first?.diffuse.contents = color
        
        return node
    }
}
