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
let blutOnBoard = UIColor(hexString: "78B4FF")

class MainViewController: UIViewController {
    
    @IBOutlet var back: DisplayGameBoard!
    @IBOutlet var board: BoardBack!
    @IBOutlet var beta: UILabel!
    @IBOutlet var enclosure: UILabel!

    var sudoGame = EnclosureGame()
    
    override func viewDidLoad() {
        if !Connection.hasRegistered() {
            Connection.register(NSUserDefaults.standardUserDefaults().objectForKey("nickName") as! String)
        }
        //add gradient
//        self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.LeftToRight, withFrame:self.view.bounds, andColors:[UIColor.redColor(), UIColor.blueColor()])
    }
    
    override func viewDidAppear(animated: Bool) {
        
        print(self.view.frame.width)
//        enclosure.layer.shadowRadius = 0.8
//        enclosure.layer.shadowOpacity = 0.3
//        beta.layer.shadowRadius = 0.01
//        beta.layer.shadowOpacity = 0.05
        back.buildGame(sudoGame)
        board.board = back
        board.controller = self
        board.drawMenu1()
    }
    
    @IBAction func backToMain(segue:UIStoryboardSegue) {
        
    }
    
}
