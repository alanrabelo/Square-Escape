//
//  Node.swift
//  AlgoritmosBusca
//
//  Created by Tiago Queiroz on 13/07/17.
//  Copyright © 2017 Tiago Queiroz. All rights reserved.
//

import UIKit

class Node: NSObject {
    
    var state: CGPoint
    var father: Node?
    //var sucessors: [Node]?
    var action: Int?
    var cost: Double?
    var deep: Int
    var desc:String
    
    init(state: CGPoint) {
        self.state = state
        self.deep = 0
        self.desc = "state: \(self.state), deep: \(self.deep)"
    }
    
    init(state: CGPoint, father: Node, deep: Int){
        self.state = state
        self.father = father
        self.deep = deep
        self.desc = "state: \(self.state), deep: \(self.deep)"
    }
    
}
