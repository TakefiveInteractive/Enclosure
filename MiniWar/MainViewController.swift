//
//  MainViewController.swift
//  Enclosure
//
//  Created by Kedan Li on 3/12/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit
import ChameleonFramework

let redOnBoard = UIColor(hexString: "F7959D")
let blueOnBoard = UIColor(hexString: "78B4FF")

class MainViewController: UIViewController {
    
    @IBOutlet weak var titleWidth: NSLayoutConstraint!
    @IBOutlet var back: DisplayGameBoard!
    @IBOutlet var board: BoardBack!
    @IBOutlet var beta: UILabel!
    @IBOutlet var enclosure: UILabel!

    var sudoGame = EnclosureGame()
    
    override func viewDidLoad() {
        !Connection.getInfo()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if view.frame.width < 350{
            enclosure.font = UIFont(name: "AvenirNext-Regular", size: 55.0)
            titleWidth.constant = 250
        }
        
        sudoGame.boardSize = 10
        sudoGame.buildGame()
        back.buildGame(sudoGame)
        board.board = back
        board.controller = self
//        board.drawMenu1()
        board.inputNickName()
    }
    
    @IBAction func backToMain(segue:UIStoryboardSegue) {
        
    }
    
}
