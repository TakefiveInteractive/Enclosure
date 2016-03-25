//
//  AIGame2ViewController.swift
//  Enclosure
//
//  Created by Kedan Li on 3/7/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class AIGame2ViewController: GameViewController {
    
    override func viewDidAppear(animated: Bool) {
        game = EnclosureGame2()
        board.buildGame(game)
        baseProgress.build()
    }
    
    override func replay() {
        super.replay()
    }
    
    override func buildGame() {
        game = EnclosureGame2()
        board.buildGame(game)
    }
    
    override func setPlayerNames() {
        if (board as! AIGameBoard2).aiPlayer == 1{
            player0Name.text = Connection.getUserNickName()
            player1Name.text = "Kedan's AI"
        }else{
            player0Name.text = "Kedan's AI"
            player1Name.text = Connection.getUserNickName()
        }
    }

}
