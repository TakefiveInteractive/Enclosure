//
//  EnclosureGame.swift
//  Enclosure
//
//  Created by Kedan Li on 2/25/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

// The GAME LOGIC

class EnclosureGame2: EnclosureGame{
    
    override init() {
        super.init()
        lands = [[Land]]()
        neutralLand = [Land]()
        playerLand = [[Land]](count: playerNum, repeatedValue: [Land]())
    
        //create lands
        for var x = 0; x <  boardSize; x++ {
            if x < boardSize - 1{
                lands.append([Land]())
                for var y = 0; y < boardSize; y++ {
                    if x < boardSize - 1 && y < boardSize - 1{
                        let land = Land2(player: -1, x: x, y: y)
                        lands[x].append(land)
                        neutralLand.append(land)
                    }
                }
            }
        }
    }
    
}

class Land2: Land {
    
    override init(player: Int, x:Int, y:Int) {
        super.init(player: player, x: x, y: y)
        let x = Int(arc4random_uniform(100))
        let y = Int(arc4random_uniform(100))
        let tempScore = (x * y)/1500
        if tempScore == 0{
            score = 1
        }else{
            score = tempScore
        }
    }
    
}
