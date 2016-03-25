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
        setPlayerNames()
    }
    
    override func buildGame() {
        game = EnclosureGame2()
        board.buildGame(game)
    }
    
    override func setPlayerNames() {
        let random = Int(arc4random_uniform(2))
        if random == 0{
            player0Name.text = Connection.getUserNickName()
            player1Name.text = "Visitor"
        }else{
            player0Name.text = "Visitor"
            player1Name.text = Connection.getUserNickName()
        }
    }
}
