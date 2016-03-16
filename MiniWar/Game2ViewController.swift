//
//  Game1ViewController.swift
//  MiniWar
//
//  Created by Kedan Li on 2/20/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class Game2ViewController: GameViewController {
        
    override func viewDidAppear(animated: Bool) {
        game = EnclosureGame2()
        board.buildGame(game)
        baseProgress.build()
    }
    
    override func buildGame() {
        game = EnclosureGame2()
        board.buildGame(game)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
