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
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var scoreUser: UILabel!
    @IBOutlet weak var scoreMachine: UILabel!
    @IBOutlet weak var labelResult: UILabel!
    
    let buscas = ["AStar", "Busca Gulosa", "Custo Uniforme" ,"Largura"]
    var op = 0
    static var squares = 10
    static let defaults = UserDefaults.standard
    let qtd = GameViewController.defaults.integer(forKey: "stage")
    
    @IBAction func restartGame(_ sender: UIButton) {
        displayWonView(true)
        //GameScene.numberOfSquares = GameViewController.squares
        GameScene.numberOfSquares = Int(qtd/10) + 3
        print(GameScene.numberOfSquares)
        self.initializeGameScene()
    }
    
    static func setNumberSquares(){
        //GameScene.numberOfSquares = squares
        let qtde = GameViewController.defaults.integer(forKey: "stage")
        GameScene.numberOfSquares = (Int(qtde/10)+1) * 3
    }
    
    func displayWonView(_ isHidden : Bool, machineCost: Double, userCost: Double) {
        self.buttonPlayAgain.isHidden = isHidden
        self.blurView.isHidden = isHidden
        self.scoreUser.text = String(format: "%.2f", userCost)
        self.scoreMachine.text = String(format: "%.2f", machineCost)
        if userCost > machineCost {
            self.labelResult.text = "You Lose"
            //let qtd = GameViewController.defaults.integer(forKey: "stage")
            GameViewController.defaults.set(qtd-1, forKey: "stage")
        }
    }
    
    func displayWonView(_ isHidden : Bool) {
        self.buttonPlayAgain.isHidden = isHidden
        self.blurView.isHidden = isHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.picker.delegate = self
        self.picker.dataSource = self
        self.picker.selectRow(10, inComponent: 1, animated: true)
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
                
                sceneNode.search = self.op
                sceneNode.gameViewController = self
                
                // Copy gameplay related content over to the scene
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    let reveal = SKTransition.fade(with: .blue, duration: 0.5)
                    view.presentScene(sceneNode, transition: reveal)
                    view.ignoresSiblingOrder = true
                }
            }
        }
    }
}
extension GameViewController: UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 4
        }else{
            return 49
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            let title = buscas[row]
            return title
        }else{
            return "\(row + 1)"
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
            self.op = row
        }
        if component == 1{
            GameViewController.squares = row + 1
        }
        
    }
}
