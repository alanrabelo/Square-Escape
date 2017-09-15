//
//  Node.swift
//  AlgoritmosBusca
//
//  Created by Tiago Queiroz on 13/07/17.
//  Copyright © 2017 Tiago Queiroz. All rights reserved.
//

import UIKit
import SpriteKit

class Node: NSObject {
    
    var state: CGPoint
    var father: Node?
    //var sucessors: [Node]?
    var action: Int?
    var cost: CGFloat
    var totalCost: CGFloat?
    var deep: Int
    var desc:String
    
    init(state: CGPoint) {
        self.state = state
        self.deep = 0
        self.cost = 0
        self.desc = "state: \(self.state), deep: \(self.deep)"
    }
    
    init(state: CGPoint, father: Node, deep: Int, cost: CGFloat){
        self.state = state
        self.father = father
        self.deep = deep
        self.cost = cost + father.cost
        self.desc = "state: \(self.state), deep: \(self.deep)"
    }
    
    func fullCost() -> CGFloat {
        
        guard let father = self.father else { return self.cost }
        return self.cost + father.fullCost()
    }

    
}
