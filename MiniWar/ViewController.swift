//
//  ViewController.swift
//  MiniWar
//
//  Created by Kedan Li on 2/20/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GameBoardDelegate {

    @IBOutlet var board: GameBoard!
    @IBOutlet var player1Score: UILabel!
    @IBOutlet var player0Score: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        board.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func updateScore(playerscore: [Int]) {
        player1Score.text = String(playerscore[1])
        player0Score.text = String(playerscore[0])

    }
    
    override func viewDidAppear(animated: Bool) {
        board.setup()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

