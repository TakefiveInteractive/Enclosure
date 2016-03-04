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
    
    func joinSuccess(success: Bool) {
        print("can starttttttttttTTTTT")
        self.performSegueWithIdentifier("startMPGame", sender: self)
    }
    
}
