//
//  MainViewController.swift
//  Enclosure
//
//  Created by Kedan Li on 3/12/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit
import ChameleonFramework

class MainViewController: UIViewController {
    
    @IBOutlet var back: DisplayGameBoard!
    @IBOutlet var board: BoardBack!
    @IBOutlet var beta: UILabel!
    @IBOutlet var enclosure: UILabel!

    var sudoGame = EnclosureGame()
    
    override func viewDidLoad() {
        
        //add gradient
//        self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.LeftToRight, withFrame:self.view.bounds, andColors:[UIColor.redColor(), UIColor.blueColor()])
    }
    
    override func viewDidAppear(animated: Bool) {
        back.buildGame(sudoGame)
        board.board = back
        board.controller = self
        
        board.drawMenu1()
    }
}
