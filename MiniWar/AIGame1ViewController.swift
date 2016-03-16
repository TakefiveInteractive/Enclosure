//
//  Game1ViewController.swift
//  MiniWar
//
//  Created by Kedan Li on 2/20/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class AIGame1ViewController: GameViewController {
    override func replay() {
        (board as! AIGameBoard).hasRestart = true
        super.replay()
    }
}
