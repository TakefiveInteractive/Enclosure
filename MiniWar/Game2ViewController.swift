//
//  Game1ViewController.swift
//  MiniWar
//
//  Created by Kedan Li on 2/20/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class Game2ViewController: UIViewController, GameBoardDelegate {
    
    @IBOutlet var board: GameBoard2!
    @IBOutlet var player1Score: UILabel!
    @IBOutlet var player0Score: UILabel!

    @IBOutlet var player1row: Rows!
    @IBOutlet var player0row: Rows!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        board.layer.shadowOpacity = 0.3
        board.layer.shadowRadius = 1.5
        board.delegate = self
        
        player0row.color = player0Score.textColor
        player1row.color = player1Score.textColor
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func updateScore(playerscore: [Int]) {
        player1Score.text = String(playerscore[1])
        player0Score.text = String(playerscore[0])
    }
    
    func showTotalRow(player: Int, row: Int) {
        if player == 0{
            player0row.changeBarNum(row)
        }else if player == 1{
            player1row.changeBarNum(row)
        }
    }
    
    func setTotalRow(player: Int, row: Int) {
        if player == 0{
            player0row.changeBarNum(row)
        }else if player == 1{
            player1row.changeBarNum(row)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        board.setup()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
