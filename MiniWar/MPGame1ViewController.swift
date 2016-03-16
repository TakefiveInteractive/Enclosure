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
    
    @IBOutlet var waiting: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (board as! MPGameBoard).onlineCurrentPlayer = currentPlayer
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
    
    override func viewDidAppear(animated: Bool) {
        game = EnclosureGame()
        (board as! MPGameBoard).buildGame(game, player: currentPlayer, parent: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
