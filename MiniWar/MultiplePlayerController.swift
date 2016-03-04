//
//  MultiplePlayerController.swift
//  Enclosure
//
//  Created by Kedan Li on 3/3/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

var mpSocket: Socket!


class MultiplePlayerController: UIViewController, SocketSuccessDelegate{
 
    @IBOutlet var createRoom: UIButton!
    @IBOutlet var searchRoom: UIButton!
    @IBOutlet var searchText: UITextField!
    
    var player = 0
    
    override func viewDidLoad() {
        createRoom.addTarget(self, action: "createGameRoom:", forControlEvents: UIControlEvents.TouchUpInside)
        searchRoom.addTarget(self, action: "searchGameRoom:", forControlEvents: UIControlEvents.TouchUpInside)
    }
 
    func createGameRoom(button: UIButton){
        mpSocket = Socket(roomNumber: "")
        mpSocket.startDelegate = self
    }

    func searchGameRoom(button: UIButton){
        if searchText.text != "" {
            mpSocket = Socket(roomNumber: searchText.text!)
            mpSocket.startDelegate = self
        }
    }
    
    func gotRoomNumber(number: String) {
        searchText.text = number
    }
    
    func playerSequence(player: Int) {
        self.player = player
    }
    
    func joinSuccess(success: Bool) {
        print("can starttttttttttTTTTT")
        self.performSegueWithIdentifier("startMPGame", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        // Create a new variable to store the instance of PlayerTableViewController
        let destinationVC = segue.destinationViewController as! MPGame1ViewController
        destinationVC.currentPlayer = self.player
    }
    
}
