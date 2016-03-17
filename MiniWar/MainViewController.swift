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

class MainViewController: UIViewController, UserDataDelegate{
    
    @IBOutlet weak var titleWidth: NSLayoutConstraint!
    @IBOutlet var back: DisplayGameBoard!
    @IBOutlet var board: BoardBack!
    @IBOutlet var beta: UILabel!
    @IBOutlet var enclosure: UILabel!
    @IBOutlet var rank: UIButton!
    @IBOutlet var nickname: UIButton!

    var sudoGame = EnclosureGame()
    
    override func viewDidLoad() {
        Connection.delegate = self
        Connection.getInfo()
        self.rankUpdate(Connection.getUserRank())
        self.nicknameUpdate(Connection.getUserNickName())
    }
    
    func rankUpdate(rank: String){
        self.rank.setTitle("World Rank: \(rank)", forState: UIControlState.Normal)
    }
    
    func nicknameUpdate(name: String){
        nickname.setTitle(name, forState: UIControlState.Normal)
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
        
        if Connection.getUserNickName() == "NOName"{
            board.inputNickName()
        }else{
            board.drawMenu1()
        }
        
    }
    
    @IBAction func backToMain(segue:UIStoryboardSegue) {
        
    }
    
}
