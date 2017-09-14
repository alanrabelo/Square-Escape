//
//  GameViewController.swift
//  Square Escape
//
//  Created by Alan Rabelo Martins on 04/09/17.
//  Copyright © 2017 alanrabelo. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

protocol GameDelegate {
    func restartGame()
}

class GameViewController: UIViewController {

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var buttonPlayAgain: UIButton!
    
    @IBAction func restartGame(_ sender: UIButton) {
        displayWonView(true)
        self.initializeGameScene()
    }
    
    func displayWonView(_ isHidden : Bool) {
        self.buttonPlayAgain.isHidden = isHidden
        self.blurView.isHidden = isHidden
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        self.initializeGameScene()
    }

    override var shouldAutorotate: Bool {
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

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func initializeGameScene(){
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                sceneNode.gameViewController = self
                
                // Copy gameplay related content over to the scene
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
}
