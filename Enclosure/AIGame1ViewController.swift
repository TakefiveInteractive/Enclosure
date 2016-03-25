//
//  Game1ViewController.swift
//  MiniWar
//
//  Created by Kedan Li on 2/20/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class AIGame1ViewController: GameViewController {
    
    override func setPlayerNames() {
        if (board as! AIGameBoard).aiPlayer == 1{
            player0Name.text = Connection.getUserNickName()
            player1Name.text = "Kedan's AI"
        }else{
            player0Name.text = "Kedan's AI"
            player1Name.text = Connection.getUserNickName()
        }
    }

}
