//
//  ViewController.swift
//  Square Escape
//
//  Created by Tiago Queiroz on 04/10/17.
//  Copyright © 2017 alanrabelo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var labelStage: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let defaults = UserDefaults.standard
        let stage = defaults.integer(forKey: "stage")
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "game")
        self.present(viewController, animated: true, completion: nil)
        self.labelStage.text = "Stage \(stage)"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setStage(stage: Int) {
        if let label = self.labelStage{
            label.text = "Stage \(stage)"
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
