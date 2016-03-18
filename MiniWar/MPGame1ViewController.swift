//
//  Game1ViewController.swift
//  MiniWar
//
//  Created by Kedan Li on 2/20/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class MPGame1ViewController: GameViewController{
    
    var currentPlayer: Int = 0
    var opponentName = ""
    var opponentId = ""
    
    @IBOutlet var waiting: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (board as! MPGameBoard).parent = self
        (board as! MPGameBoard).onlineCurrentPlayer = currentPlayer
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        buildGame()
        (board as! MPGameBoard).changeBoardAvailabiliity()
    }
    
    override func replay(){
        mpSocket.requestRestart()
    }
    
    func requestedRestart(){
        let createAccountErrorAlert: UIAlertView = UIAlertView()
        
        createAccountErrorAlert.delegate = self
        
        createAccountErrorAlert.title = "Restart Request"
        createAccountErrorAlert.message = "your opponent ask to restart the game!"
        createAccountErrorAlert.addButtonWithTitle("Restart")
        createAccountErrorAlert.addButtonWithTitle("Refuse")
        createAccountErrorAlert.show()
    }
    
    override func setPlayerNames() {
        if currentPlayer == 0{
            player0Name.text = Connection.getUserNickName()
            player1Name.text = opponentName
        }else{
            player0Name.text = opponentName
            player1Name.text = Connection.getUserNickName()
        }
    }
    
    override func endGame(winPlayer: Int) {
        if winPlayer == 1{
            player1Score.text = "WIN"
        }else{
            player0Score.text = "WIN"
        }
        mpSocket.gameEnd()
        board.userInteractionEnabled = false
        board.alpha = 0.7
    }
    
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        switch buttonIndex{
        case 1:
            print("refuse")
            mpSocket.refuseRestart()
            break
        case 0:
            print("restart")
            mpSocket.requestRestart()
            break
        default:
            break
            //Some code here..
        }
    }
    
    override func buildGame() {
        game = EnclosureGame()
        (board as! MPGameBoard).buildGame(game, player: currentPlayer, parent: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
